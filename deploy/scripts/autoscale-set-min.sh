#!/usr/bin/env bash
# Set min_instances on a Droplet Autoscale pool (keeps other config fields).
# Usage: autoscale-set-min.sh <pool_id> <min_instances>
set -euo pipefail

POOL_ID="${1:-}"
MIN="${2:-}"
TOKEN="${DIGITALOCEAN_TOKEN:-}"

if [[ -z "$POOL_ID" || -z "$MIN" || -z "$TOKEN" ]]; then
  echo "usage: DIGITALOCEAN_TOKEN=... autoscale-set-min.sh <pool_id> <min_instances>" >&2
  exit 2
fi

current="$(curl -fsS \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  "https://api.digitalocean.com/v2/droplets/autoscale/${POOL_ID}")"

payload="$(jq -c --argjson min "$MIN" '
  .autoscale_pool
  | {
      name,
      config: (.config + {min_instances: $min}),
      droplet_template
    }
' <<<"$current")"

curl -fsS -X PUT \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d "$payload" \
  "https://api.digitalocean.com/v2/droplets/autoscale/${POOL_ID}" \
  | jq -r '.autoscale_pool | "pool \(.name) min=\(.config.min_instances) max=\(.config.max_instances) active=\(.active_resources_count)"'
