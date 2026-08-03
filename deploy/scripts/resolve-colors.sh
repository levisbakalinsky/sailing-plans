#!/usr/bin/env bash
# Resolve active/inactive blue-green colors from the Load Balancer tag.
# Prints KEY=value lines suitable for GITHUB_OUTPUT or eval.
#
# Env: DIGITALOCEAN_TOKEN, LOADBALANCER_ID, BLUE_TAG, GREEN_TAG, POOL_TAG (shared),
#      AUTOSCALE_POOL_ID_BLUE, AUTOSCALE_POOL_ID_GREEN, BASELINE_MIN (optional),
#      POOL_NAME_BLUE (default sailing-plans-app-dev),
#      POOL_NAME_GREEN (default sailing-plans-app-dev-green)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

BLUE_TAG="${BLUE_TAG:-sailing-plans-app-dev-pool-blue}"
GREEN_TAG="${GREEN_TAG:-sailing-plans-app-dev-pool-green}"
POOL_TAG="${POOL_TAG:-sailing-plans-app-dev-pool}"
BASELINE_MIN="${BASELINE_MIN:-2}"
POOL_NAME_BLUE="${POOL_NAME_BLUE:-sailing-plans-app-dev}"
POOL_NAME_GREEN="${POOL_NAME_GREEN:-sailing-plans-app-dev-green}"

if [[ -z "${LOADBALANCER_ID:-}" || -z "${DIGITALOCEAN_TOKEN:-}" ]]; then
  echo "LOADBALANCER_ID and DIGITALOCEAN_TOKEN are required" >&2
  exit 2
fi

active="$("$SCRIPT_DIR/lb-get-tag.sh")"
if [[ -z "$active" || "$active" == "$POOL_TAG" ]]; then
  echo "LB tag empty/shared; treating as blue" >&2
  active="$BLUE_TAG"
fi

if [[ "$active" == "$BLUE_TAG" ]]; then
  inactive="$GREEN_TAG"
  active_pool="${AUTOSCALE_POOL_ID_BLUE:-}"
  inactive_pool="${AUTOSCALE_POOL_ID_GREEN:-}"
  active_name="$POOL_NAME_BLUE"
  inactive_name="$POOL_NAME_GREEN"
elif [[ "$active" == "$GREEN_TAG" ]]; then
  inactive="$BLUE_TAG"
  active_pool="${AUTOSCALE_POOL_ID_GREEN:-}"
  inactive_pool="${AUTOSCALE_POOL_ID_BLUE:-}"
  active_name="$POOL_NAME_GREEN"
  inactive_name="$POOL_NAME_BLUE"
else
  echo "Unexpected LB tag '$active' (expected $BLUE_TAG or $GREEN_TAG)" >&2
  exit 1
fi

# Prefer live pool ids by name (GitHub vars go stale after delete/recreate).
if [[ -n "${DIGITALOCEAN_TOKEN:-}" ]]; then
  listed="$(curl -fsS -H "Authorization: Bearer ${DIGITALOCEAN_TOKEN}" \
    "https://api.digitalocean.com/v2/droplets/autoscale?per_page=200" || echo '{}')"
  by_name() {
    jq -r --arg n "$1" '.autoscale_pools[]? | select(.name==$n) | .id' <<<"$listed" | head -n1
  }
  found_active="$(by_name "$active_name")"
  found_inactive="$(by_name "$inactive_name")"
  [[ -n "$found_active" ]] && active_pool="$found_active"
  [[ -n "$found_inactive" ]] && inactive_pool="$found_inactive"
fi

echo "active_tag=$active"
echo "inactive_tag=$inactive"
echo "active_pool_id=${active_pool:-}"
echo "inactive_pool_id=${inactive_pool:-}"
echo "active_pool_name=$active_name"
echo "inactive_pool_name=$inactive_name"
echo "baseline_min=$BASELINE_MIN"
