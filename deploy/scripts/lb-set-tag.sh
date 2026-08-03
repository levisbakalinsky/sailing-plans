#!/usr/bin/env bash
# Point the Load Balancer at a droplet tag (blue/green cutover).
# Usage: lb-set-tag.sh <tag>
set -euo pipefail

TAG="${1:-}"
LB_ID="${LOADBALANCER_ID:-}"
TOKEN="${DIGITALOCEAN_TOKEN:-}"

if [[ -z "$TAG" || -z "$LB_ID" || -z "$TOKEN" ]]; then
  echo "usage: LOADBALANCER_ID=... DIGITALOCEAN_TOKEN=... lb-set-tag.sh <tag>" >&2
  exit 2
fi

current="$(curl -fsS \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  "https://api.digitalocean.com/v2/load_balancers/${LB_ID}")"

# Preserve required fields; only change droplet_tag.
payload="$(jq -c --arg tag "$TAG" '
  .load_balancer
  | {
      name,
      region: .region.slug,
      size: (.size // "lb-small"),
      size_unit,
      vpc_uuid,
      forwarding_rules,
      health_check,
      sticky_sessions,
      redirect_http_to_https,
      enable_proxy_protocol,
      enable_backend_keepalive,
      http_idle_timeout_seconds,
      disable_lets_encrypt_dns_records,
      project_id,
      droplet_tag: $tag
    }
  | with_entries(select(.value != null))
' <<<"$current")"

curl -fsS -X PUT \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d "$payload" \
  "https://api.digitalocean.com/v2/load_balancers/${LB_ID}" \
  | jq -r '.load_balancer | "LB \(.name) -> droplet_tag=\(.droplet_tag) status=\(.status)"'
