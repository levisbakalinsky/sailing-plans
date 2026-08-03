#!/usr/bin/env bash
# Activate a specific release onto the inactive color, then cut over.
# Usage: release-activate.sh <release-id-or-sha> [--finalize]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_REF="${1:-}"
FINALIZE=false
shift || true
while [[ $# -gt 0 ]]; do
  case "$1" in
    --finalize) FINALIZE=true; shift ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

if [[ -z "$TARGET_REF" ]]; then
  echo "usage: release-activate.sh <release-id-or-sha> [--finalize]" >&2
  exit 2
fi

: "${DIGITALOCEAN_TOKEN:?}"
: "${LOADBALANCER_ID:?}"
: "${DROPLET_USER:?}"
: "${DROPLET_SSH_KEY:?}"
: "${LB_HOST:?}"
: "${GITHUB_TOKEN:?}"
: "${GITHUB_ACTOR:?}"

BLUE_TAG="${BLUE_TAG:-sailing-plans-app-dev-pool-blue}"
GREEN_TAG="${GREEN_TAG:-sailing-plans-app-dev-pool-green}"
SHARED_POOL_TAG="${SHARED_POOL_TAG:-sailing-plans-app-dev-pool}"
BASELINE_MIN="${BASELINE_MIN:-2}"
POOL_TAG="$SHARED_POOL_TAG"

release="$("$SCRIPT_DIR/release-ledger.sh" get "$TARGET_REF")"
rel_id="$(jq -r '.id' <<<"$release")"
api_image="$(jq -r '.api_image' <<<"$release")"
web_image="$(jq -r '.web_image' <<<"$release")"
git_sha="$(jq -r '.git_sha // empty' <<<"$release")"

if [[ -z "$api_image" || -z "$web_image" || "$api_image" == "null" || "$web_image" == "null" ]]; then
  echo "Release $rel_id missing api_image/web_image" >&2
  exit 1
fi

echo "Activating release:"
jq . <<<"$release"

"$SCRIPT_DIR/resolve-colors.sh" > /tmp/colors.env
# shellcheck disable=SC1091
set -a; source /tmp/colors.env; set +a

inactive="$inactive_tag"
inactive_pool="$inactive_pool_id"
inactive_name="$inactive_pool_name"
active="$active_tag"
active_name="$active_pool_name"
active_pool="$active_pool_id"
clone_from="$active_pool_id"

if [[ -z "$clone_from" ]]; then
  echo "Active pool missing; cannot clone template for $inactive_name" >&2
  exit 1
fi

echo "Active=$active → deploy $rel_id onto $inactive"

out="$("$SCRIPT_DIR/autoscale-ensure.sh" \
  "${inactive_pool:-}" "$inactive_name" "$inactive" "$SHARED_POOL_TAG" "$clone_from" "$BASELINE_MIN")"
echo "$out"
new_id="$(sed -n 's/^pool_id=//p' <<<"$out" | tail -n1)"

export POOL_TAG="$inactive"
"$SCRIPT_DIR/ssh-pool.sh" -- "$(cat <<EOF
set -euo pipefail
cd /opt/sailing-plans
echo "${GITHUB_TOKEN}" | docker login ghcr.io -u "${GITHUB_ACTOR}" --password-stdin
grep -vE '^(API_IMAGE|WEB_IMAGE)=' .env > .env.tmp || true
{ cat .env.tmp; echo "API_IMAGE=${api_image}"; echo "WEB_IMAGE=${web_image}"; } > .env
rm -f .env.tmp
chmod 600 .env
docker compose pull api web
docker compose up -d --remove-orphans
for i in \$(seq 1 60); do
  if curl -fsS http://127.0.0.1/health >/dev/null; then exit 0; fi
  sleep 2
done
docker compose logs --tail=100
exit 1
EOF
)"

"$SCRIPT_DIR/wait-pool-hosts.sh" "$inactive" "$BASELINE_MIN" 600
"$SCRIPT_DIR/lb-set-tag.sh" "$inactive"
for i in $(seq 1 36); do
  if curl -fsS "http://${LB_HOST}/health" >/dev/null; then
    echo "LB healthy on $inactive"
    break
  fi
  sleep 5
  if [[ "$i" -eq 36 ]]; then
    echo "LB unhealthy after activating $rel_id" >&2
    exit 1
  fi
done

"$SCRIPT_DIR/release-ledger.sh" set-current "$rel_id"

state="$(jq -nc \
  --arg id "$rel_id" \
  --arg api "$api_image" \
  --arg web "$web_image" \
  --arg sha "$git_sha" \
  --arg color "$inactive" \
  --arg prev "$active" \
  '{
    active_color: $color,
    previous_color: $prev,
    active: {id:$id, api_image:$api, web_image:$web, git_sha:$sha, color:$color},
    updated_at: (now|todate),
    last_action: "activate"
  }')"
tmp="$(mktemp)"
echo "$state" >"$tmp"
export POOL_TAG="$inactive"
"$SCRIPT_DIR/release-state.sh" put "$tmp"
rm -f "$tmp"

gh variable set ACTIVE_COLOR_TAG --env development --body "$inactive" || true
if [[ "$inactive" == "$GREEN_TAG" ]]; then
  gh variable set AUTOSCALE_POOL_ID_GREEN --env development --body "$new_id" || true
else
  gh variable set AUTOSCALE_POOL_ID_BLUE --env development --body "$new_id" || true
fi

if [[ "$FINALIZE" == "true" ]]; then
  if [[ -n "$active_pool" ]]; then
    "$SCRIPT_DIR/autoscale-delete.sh" "$active_pool" "$active" "$inactive"
  fi
else
  echo "Idle color $active kept. Use Ops (Development) → teardown-idle when done."
fi

echo "Activated $rel_id on $inactive"
