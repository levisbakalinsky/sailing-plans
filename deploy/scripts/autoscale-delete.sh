#!/usr/bin/env bash
# Delete a Droplet Autoscale pool, then destroy leftover droplets for the idle color.
# Usage: autoscale-delete.sh <pool_id> <idle_color_tag> [keep_color_tag]
#
# Safety:
# - Idle-only leftovers are destroyed.
# - Dual-tagged droplets (idle + keep) that are NOT members of any remaining
#   autoscale pool are destroyed (orphans left by earlier teardowns).
# - Dual-tagged droplets that ARE members of a remaining pool are kept;
#   the stale idle tag is removed so they stop appearing in idle-color listings.
# - Never destroys a keep-tagged host that still belongs to a live pool.
set -euo pipefail

POOL_ID="${1:-}"
IDLE_TAG="${2:-}"
KEEP_TAG="${3:-}"
TOKEN="${DIGITALOCEAN_TOKEN:-}"

if [[ -z "$POOL_ID" || -z "$TOKEN" ]]; then
  echo "usage: DIGITALOCEAN_TOKEN=... autoscale-delete.sh <pool_id> [idle_tag] [keep_tag]" >&2
  exit 2
fi

api_code() {
  local method="$1" path="$2" out="$3"
  shift 3
  curl -sS -o "$out" -w '%{http_code}' -X "$method" \
    -H "Authorization: Bearer ${TOKEN}" \
    -H "Content-Type: application/json" \
    "$@" \
    "https://api.digitalocean.com/v2${path}"
}

code="$(api_code DELETE "/droplets/autoscale/${POOL_ID}" /tmp/autoscale-delete.json)"

# 202 = accepted (async delete), 204 = gone, 404 = already gone.
if [[ "$code" != "202" && "$code" != "204" && "$code" != "404" ]]; then
  echo "Failed to delete pool ${POOL_ID} (http=${code})" >&2
  cat /tmp/autoscale-delete.json >&2 || true
  exit 1
fi

echo "pool ${POOL_ID} delete accepted (http=${code})"
for i in $(seq 1 60); do
  get_code="$(curl -sS -o /dev/null -w '%{http_code}' \
    -H "Authorization: Bearer ${TOKEN}" \
    "https://api.digitalocean.com/v2/droplets/autoscale/${POOL_ID}" || true)"
  if [[ "$get_code" == "404" ]]; then
    echo "pool ${POOL_ID} gone"
    break
  fi
  sleep 5
done

if [[ -z "$IDLE_TAG" ]]; then
  exit 0
fi

# Droplet IDs still owned by any remaining autoscale pool (fail closed → empty set).
MEMBER_IDS_FILE="$(mktemp)"
trap 'rm -f "$MEMBER_IDS_FILE"' EXIT
: >"$MEMBER_IDS_FILE"
members_ok=false
if listed="$(curl -fsS -H "Authorization: Bearer ${TOKEN}" \
  "https://api.digitalocean.com/v2/droplets/autoscale?per_page=200")"; then
  members_ok=true
  while IFS= read -r pid; do
    [[ -n "$pid" ]] || continue
    page=1
    while true; do
      if ! members="$(curl -fsS -H "Authorization: Bearer ${TOKEN}" \
        "https://api.digitalocean.com/v2/droplets/autoscale/${pid}/members?page=${page}&per_page=200")"; then
        echo "warning: could not list members for pool ${pid}; skipping dual-tag orphan destroy" >&2
        members_ok=false
        break 2
      fi
      jq -r '.droplets[]?.droplet_id // empty' <<<"$members" >>"$MEMBER_IDS_FILE"
      pages="$(jq -r '.meta.pagination.pages // 1' <<<"$members")"
      if [[ "$page" -ge "$pages" ]]; then
        break
      fi
      page=$((page + 1))
    done
  done < <(jq -r '.autoscale_pools[]?.id // empty' <<<"$listed")
fi

if [[ "$members_ok" != "true" ]]; then
  echo "warning: remaining pool membership unknown; dual-tagged hosts will be left alone" >&2
fi

mapfile -t ROWS < <(curl -fsS \
  -H "Authorization: Bearer ${TOKEN}" \
  "https://api.digitalocean.com/v2/droplets?tag_name=${IDLE_TAG}&per_page=200" \
  | jq -r --arg keep "$KEEP_TAG" '
      .droplets[]?
      | . as $d
      | (($keep != "") and ((($d.tags // []) | index($keep)) != null)) as $has_keep
      | "\($d.id)\t\($d.name)\t\($has_keep)"
    ')

for row in "${ROWS[@]:-}"; do
  [[ -n "$row" ]] || continue
  id="${row%%$'\t'*}"
  rest="${row#*$'\t'}"
  name="${rest%%$'\t'*}"
  has_keep="${rest##*$'\t'}"

  if [[ "$has_keep" == "true" ]]; then
    if [[ "$members_ok" != "true" ]]; then
      echo "skipped dual-tag droplet ${id} (${name}); membership unknown (fail closed)"
      continue
    fi
    if ! grep -qx "$id" "$MEMBER_IDS_FILE"; then
      dcode="$(curl -sS -o /dev/null -w '%{http_code}' -X DELETE \
        -H "Authorization: Bearer ${TOKEN}" \
        "https://api.digitalocean.com/v2/droplets/${id}")"
      echo "destroyed dual-tag orphan droplet ${id} (${name}) http=${dcode}"
      continue
    fi
    # Live pool member with a stale idle tag: strip idle tag; never destroy.
    utag_code="$(curl -sS -o /tmp/autoscale-untag.json -w '%{http_code}' -X DELETE \
      -H "Authorization: Bearer ${TOKEN}" \
      -H "Content-Type: application/json" \
      -d "$(jq -nc --arg id "$id" '{resources:[{resource_id:$id,resource_type:"droplet"}]}')" \
      "https://api.digitalocean.com/v2/tags/$(printf %s "$IDLE_TAG" | jq -sRr @uri)/resources" || true)"
    echo "kept dual-tag live droplet ${id} (${name}); removed stale tag ${IDLE_TAG} http=${utag_code}"
    continue
  fi

  dcode="$(curl -sS -o /dev/null -w '%{http_code}' -X DELETE \
    -H "Authorization: Bearer ${TOKEN}" \
    "https://api.digitalocean.com/v2/droplets/${id}")"
  echo "destroyed leftover droplet ${id} (${name}) http=${dcode}"
done
