#!/usr/bin/env bash
# List public IPv4 addresses for Droplets with a given tag (autoscale pool members).
set -euo pipefail

TAG="${1:-${POOL_TAG:-}}"
TOKEN="${DIGITALOCEAN_TOKEN:-}"

if [[ -z "$TAG" ]]; then
  echo "usage: pool-hosts.sh <tag>  (or set POOL_TAG)" >&2
  exit 2
fi
if [[ -z "$TOKEN" ]]; then
  echo "DIGITALOCEAN_TOKEN is required" >&2
  exit 2
fi

page=1
while true; do
  resp="$(curl -fsS \
    -H "Authorization: Bearer ${TOKEN}" \
    -H "Content-Type: application/json" \
    "https://api.digitalocean.com/v2/droplets?tag_name=$(printf %s "$TAG" | jq -sRr @uri)&page=${page}&per_page=50")"

  count="$(jq '.droplets | length' <<<"$resp")"
  if [[ "$count" -eq 0 ]]; then
    break
  fi

  jq -r '
    .droplets[]
    | .networks.v4[]
    | select(.type == "public")
    | .ip_address
  ' <<<"$resp"

  pages="$(jq -r '.meta.pagination.pages // 1' <<<"$resp")"
  if [[ "$page" -ge "$pages" ]]; then
    break
  fi
  page=$((page + 1))
done
