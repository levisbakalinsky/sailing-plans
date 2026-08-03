#!/usr/bin/env bash
# Delete a Droplet Autoscale pool (and its Droplets).
# Usage: autoscale-delete.sh <pool_id>
set -euo pipefail

POOL_ID="${1:-}"
TOKEN="${DIGITALOCEAN_TOKEN:-}"

if [[ -z "$POOL_ID" || -z "$TOKEN" ]]; then
  echo "usage: DIGITALOCEAN_TOKEN=... autoscale-delete.sh <pool_id>" >&2
  exit 2
fi

code="$(curl -sS -o /tmp/autoscale-delete.json -w '%{http_code}' -X DELETE \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  "https://api.digitalocean.com/v2/droplets/autoscale/${POOL_ID}")"

if [[ "$code" == "204" || "$code" == "404" ]]; then
  echo "pool ${POOL_ID} deleted (http=${code})"
  exit 0
fi

echo "Failed to delete pool ${POOL_ID} (http=${code})" >&2
cat /tmp/autoscale-delete.json >&2 || true
exit 1
