#!/usr/bin/env bash
# Ensure an autoscale pool exists (create by cloning another pool if needed), then set min.
# Prints: pool_id=<uuid>
# Usage:
#   autoscale-ensure.sh <pool_id> <pool_name> <color_tag> <shared_pool_tag> <clone_from_pool_id> <min>
set -euo pipefail

POOL_ID="${1:-}"
POOL_NAME="${2:-}"
COLOR_TAG="${3:-}"
SHARED_TAG="${4:-}"
CLONE_FROM="${5:-}"
MIN="${6:-2}"
TOKEN="${DIGITALOCEAN_TOKEN:-}"

if [[ -z "$POOL_NAME" || -z "$COLOR_TAG" || -z "$SHARED_TAG" || -z "$CLONE_FROM" || -z "$TOKEN" ]]; then
  echo "usage: DIGITALOCEAN_TOKEN=... autoscale-ensure.sh <pool_id> <pool_name> <color_tag> <shared_tag> <clone_from_pool_id> <min>" >&2
  exit 2
fi

api() {
  local method="$1" path="$2"
  shift 2
  curl -sS -X "$method" \
    -H "Authorization: Bearer ${TOKEN}" \
    -H "Content-Type: application/json" \
    "$@" \
    "https://api.digitalocean.com/v2${path}"
}

exists=false
if [[ -n "$POOL_ID" ]]; then
  code="$(curl -sS -o /tmp/autoscale-get.json -w '%{http_code}' \
    -H "Authorization: Bearer ${TOKEN}" \
    "https://api.digitalocean.com/v2/droplets/autoscale/${POOL_ID}")"
  if [[ "$code" == "200" ]]; then
    exists=true
  fi
fi

if [[ "$exists" != "true" ]]; then
  # Look up by name (ID may be stale after a prior finalize delete).
  listed="$(api GET "/droplets/autoscale?per_page=200")"
  POOL_ID="$(jq -r --arg n "$POOL_NAME" '.autoscale_pools[]? | select(.name==$n) | .id' <<<"$listed" | head -n1)"
  if [[ -n "$POOL_ID" && "$POOL_ID" != "null" ]]; then
    exists=true
    echo "Found pool by name ${POOL_NAME} -> ${POOL_ID}" >&2
  fi
fi

if [[ "$exists" != "true" ]]; then
  echo "Creating pool ${POOL_NAME} by cloning ${CLONE_FROM}" >&2
  source_json="$(api GET "/droplets/autoscale/${CLONE_FROM}")"
  # Strip every color tag before adding the new one — never ship dual-tagged templates.
  create_payload="$(jq -c --arg name "$POOL_NAME" --arg color "$COLOR_TAG" --arg shared "$SHARED_TAG" --argjson min "$MIN" '
    .autoscale_pool as $p
    | ($p.droplet_template.tags // []) as $tags
    | (
        $tags
        | map(select((. != $color) and (. | endswith("-blue") | not) and (. | endswith("-green") | not)))
        + [$shared, $color]
        | unique
      ) as $new_tags
    | {
        name: $name,
        config: ($p.config + {min_instances: $min}),
        droplet_template: (
          $p.droplet_template
          | del(.name)
          | .tags = $new_tags
        )
      }
  ' <<<"$source_json")"
  echo "clone tags -> $(jq -rc '.droplet_template.tags' <<<"$create_payload")" >&2
  created="$(api POST "/droplets/autoscale" -d "$create_payload")"
  POOL_ID="$(jq -r '.autoscale_pool.id // empty' <<<"$created")"
  if [[ -z "$POOL_ID" ]]; then
    echo "Failed to create pool ${POOL_NAME}" >&2
    echo "$created" | jq . >&2 || echo "$created" >&2
    exit 1
  fi
  echo "Created pool ${POOL_NAME} id=${POOL_ID}" >&2
fi

# Destroy dual-tagged leftovers for this color that are not members of this pool
# or the clone source (live) pool. Fail closed if live-pool membership cannot be listed.
member_file="$(mktemp)"
trap 'rm -f "$member_file"' EXIT
: >"$member_file"
live_members_ok=false
for pid in "$CLONE_FROM" "$POOL_ID"; do
  [[ -n "$pid" ]] || continue
  page=1
  pool_listed=false
  while true; do
    code="$(curl -sS -o /tmp/autoscale-members.json -w '%{http_code}' \
      -H "Authorization: Bearer ${TOKEN}" \
      "https://api.digitalocean.com/v2/droplets/autoscale/${pid}/members?page=${page}&per_page=200" || true)"
    if [[ "$code" != "200" ]]; then
      echo "warning: members list failed for pool ${pid} (http=${code})" >&2
      pool_listed=false
      break
    fi
    pool_listed=true
    jq -r '.droplets[]?.droplet_id // empty' /tmp/autoscale-members.json >>"$member_file"
    pages="$(jq -r '.meta.pagination.pages // 1' /tmp/autoscale-members.json)"
    if [[ "$page" -ge "$pages" ]]; then
      break
    fi
    page=$((page + 1))
  done
  if [[ "$pid" == "$CLONE_FROM" && "$pool_listed" == "true" ]]; then
    live_members_ok=true
  fi
done

if [[ "$live_members_ok" != "true" ]]; then
  echo "warning: skipping dual-tag orphan GC; could not list live pool members" >&2
else
  while IFS=$'\t' read -r id name tags; do
    [[ -n "$id" ]] || continue
    case "$tags" in
      *-pool-blue*-pool-green*|*-pool-green*-pool-blue*) ;;
      *) continue ;;
    esac
    if grep -qx "$id" "$member_file"; then
      continue
    fi
    dcode="$(curl -sS -o /dev/null -w '%{http_code}' -X DELETE \
      -H "Authorization: Bearer ${TOKEN}" \
      "https://api.digitalocean.com/v2/droplets/${id}")"
    echo "destroyed dual-tag orphan ${id} (${name}) before scale http=${dcode}" >&2
  done < <(curl -fsS -H "Authorization: Bearer ${TOKEN}" \
    "https://api.digitalocean.com/v2/droplets?tag_name=$(printf %s "$COLOR_TAG" | jq -sRr @uri)&per_page=200" \
    | jq -r '.droplets[]? | "\(.id)\t\(.name)\t\((.tags // []) | join(","))"')
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$SCRIPT_DIR/autoscale-set-min.sh" "$POOL_ID" "$MIN"
echo "pool_id=${POOL_ID}"
