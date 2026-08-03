#!/usr/bin/env bash
# Print the Load Balancer active droplet tag (blue/green color).
set -euo pipefail

LB_ID="${LOADBALANCER_ID:-}"
TOKEN="${DIGITALOCEAN_TOKEN:-}"

if [[ -z "$LB_ID" || -z "$TOKEN" ]]; then
  echo "LOADBALANCER_ID and DIGITALOCEAN_TOKEN are required" >&2
  exit 2
fi

curl -fsS \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  "https://api.digitalocean.com/v2/load_balancers/${LB_ID}" \
  | jq -r '.load_balancer.tag // .load_balancer.droplet_tag // empty'
