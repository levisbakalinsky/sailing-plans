#!/usr/bin/env bash
# Delete a Droplet Autoscale pool, then destroy leftover droplets for the idle color.
# Usage: autoscale-delete.sh <pool_id> <idle_color_tag> [keep_color_tag]
#
# Droplets that still have keep_color_tag (the live color) are left alone — they may
# carry a stale idle tag from earlier cutovers.
set -euo pipefail

POOL_ID="${1:-}"
IDLE_TAG="${2:-}"
KEEP_TAG="${3:-}"
TOKEN="${DIGITALOCEAN_TOKEN:-}"

if [[ -z "$POOL_ID" || -z "$TOKEN" ]]; then
  echo "usage: DIGITALOCEAN_TOKEN=... autoscale-delete.sh <pool_id> [idle_tag] [keep_tag]" >&2
  exit 2
fi

code="$(curl -sS -o /tmp/autoscale-delete.json -w '%{http_code}' -X DELETE \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  "https://api.digitalocean.com/v2/droplets/autoscale/${POOL_ID}")"

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

mapfile -t ROWS < <(curl -fsS \
  -H "Authorization: Bearer ${TOKEN}" \
  "https://api.digitalocean.com/v2/droplets?tag_name=${IDLE_TAG}&per_page=200" \
  | jq -r --arg keep "$KEEP_TAG" '
      .droplets[]?
      | select(($keep == "") or (((.tags // []) | index($keep)) | not))
      | "\(.id)\t\(.name)"
    ')

for row in "${ROWS[@]:-}"; do
  [[ -n "$row" ]] || continue
  id="${row%%$'\t'*}"
  name="${row#*$'\t'}"
  dcode="$(curl -sS -o /dev/null -w '%{http_code}' -X DELETE \
    -H "Authorization: Bearer ${TOKEN}" \
    "https://api.digitalocean.com/v2/droplets/${id}")"
  echo "destroyed leftover droplet ${id} (${name}) http=${dcode}"
done
