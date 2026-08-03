#!/usr/bin/env bash
# Point the Load Balancer at a droplet tag (blue/green cutover).
# Usage: lb-set-tag.sh <tag>
#
# DO Load Balancer PUT expects the assign-by-tag field named `tag`
# (not `droplet_tag`). Omitting it clears backends.
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

# Full representation required; use `tag` (API write field). Do not send droplet_ids.
payload="$(jq -c --arg tag "$TAG" '
  .load_balancer as $lb
  | ($lb.region | if type == "object" then .slug else . end) as $region
  | {
      name: $lb.name,
      region: $region,
      size: ($lb.size // "lb-small"),
      size_unit: $lb.size_unit,
      vpc_uuid: $lb.vpc_uuid,
      forwarding_rules: $lb.forwarding_rules,
      health_check: $lb.health_check,
      sticky_sessions: $lb.sticky_sessions,
      redirect_http_to_https: $lb.redirect_http_to_https,
      enable_proxy_protocol: $lb.enable_proxy_protocol,
      enable_backend_keepalive: $lb.enable_backend_keepalive,
      http_idle_timeout_seconds: $lb.http_idle_timeout_seconds,
      disable_lets_encrypt_dns_records: $lb.disable_lets_encrypt_dns_records,
      project_id: $lb.project_id,
      tag: $tag
    }
  | with_entries(select(.value != null))
' <<<"$current")"

updated="$(curl -fsS -X PUT \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d "$payload" \
  "https://api.digitalocean.com/v2/load_balancers/${LB_ID}")"

active="$(jq -r '.load_balancer.tag // .load_balancer.droplet_tag // empty' <<<"$updated")"
status="$(jq -r '.load_balancer.status // empty' <<<"$updated")"
name="$(jq -r '.load_balancer.name // empty' <<<"$updated")"
echo "LB ${name} -> tag=${active} status=${status}"
if [[ "$active" != "$TAG" ]]; then
  echo "ERROR: expected tag=$TAG but API returned tag=${active:-null}" >&2
  echo "$updated" | jq '.load_balancer | {name, tag, droplet_tag, droplet_ids, status}' >&2 || true
  exit 1
fi
