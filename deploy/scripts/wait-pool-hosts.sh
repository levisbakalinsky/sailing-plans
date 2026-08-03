#!/usr/bin/env bash
# Wait until at least N pool hosts respond 200 on /health.
# Usage: wait-pool-hosts.sh <tag> <min_hosts> [timeout_seconds] [pool_id]
#
# When pool_id is set, only members of that autoscale pool are counted (tag-only
# orphans / dual-tagged leftovers are ignored). New Ubuntu clones often need
# several minutes of cloud-init/Docker before :80/health works — that is expected.
set -euo pipefail

TAG="${1:-}"
MIN_HOSTS="${2:-1}"
TIMEOUT="${3:-600}"
POOL_ID="${4:-}"
TOKEN="${DIGITALOCEAN_TOKEN:-}"

if [[ -z "$TAG" ]]; then
  echo "usage: wait-pool-hosts.sh <tag> <min_hosts> [timeout_seconds] [pool_id]" >&2
  exit 2
fi

list_member_ids() {
  local pool_id="$1" page=1 members pages
  while true; do
    members="$(curl -fsS -H "Authorization: Bearer ${TOKEN}" \
      "https://api.digitalocean.com/v2/droplets/autoscale/${pool_id}/members?page=${page}&per_page=200")"
    jq -r '.droplets[]?.droplet_id // empty' <<<"$members"
    pages="$(jq -r '.meta.pagination.pages // 1' <<<"$members")"
    if [[ "$page" -ge "$pages" ]]; then
      break
    fi
    page=$((page + 1))
  done
}

list_host_rows() {
  # Prints: id<TAB>ip<TAB>tags_csv
  local page=1 resp count pages
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
      | . as $d
      | ($d.networks.v4 // [] | map(select(.type=="public")) | .[0].ip_address // empty) as $ip
      | select($ip != "")
      | "\($d.id)\t\($ip)\t\(($d.tags // []) | join(","))"
    ' <<<"$resp"
    pages="$(jq -r '.meta.pagination.pages // 1' <<<"$resp")"
    if [[ "$page" -ge "$pages" ]]; then
      break
    fi
    page=$((page + 1))
  done
}

deadline=$((SECONDS + TIMEOUT))
noted_bootstrap=false
while (( SECONDS < deadline )); do
  mapfile -t ROWS < <(list_host_rows || true)
  MEMBER_FILTER=""
  if [[ -n "$POOL_ID" && -n "$TOKEN" ]]; then
    MEMBER_FILTER="$(mktemp)"
    list_member_ids "$POOL_ID" >"$MEMBER_FILTER" || true
  fi

  healthy=0
  considered=0
  skipped_orphan=0
  dual_tag=0
  bootstrapping=0
  details=()

  for row in "${ROWS[@]:-}"; do
    [[ -n "$row" ]] || continue
    id="${row%%$'\t'*}"
    rest="${row#*$'\t'}"
    ip="${rest%%$'\t'*}"
    tags="${rest#*$'\t'}"

    if [[ "$tags" == *"-pool-blue"* && "$tags" == *"-pool-green"* ]]; then
      dual_tag=$((dual_tag + 1))
    fi

    if [[ -n "$MEMBER_FILTER" ]] && ! grep -qx "$id" "$MEMBER_FILTER"; then
      skipped_orphan=$((skipped_orphan + 1))
      details+=("${ip}=skip-non-member")
      continue
    fi

    considered=$((considered + 1))
    code="$(curl -sS -m 5 -o /dev/null -w '%{http_code}' "http://${ip}/health" || true)"
    if [[ "$code" == "200" ]]; then
      healthy=$((healthy + 1))
      details+=("${ip}=200")
    else
      bootstrapping=$((bootstrapping + 1))
      details+=("${ip}=${code:-err}")
    fi
  done

  [[ -n "$MEMBER_FILTER" ]] && rm -f "$MEMBER_FILTER"

  echo "tag=${TAG} pool=${POOL_ID:-tag-only} hosts=${considered} healthy=${healthy} bootstrapping=${bootstrapping} skipped_non_member=${skipped_orphan} dual_tag_seen=${dual_tag} (want >= ${MIN_HOSTS})"
  if ((${#details[@]} > 0)); then
    echo "  hosts: ${details[*]}"
  fi
  if [[ "$bootstrapping" -gt 0 && "$noted_bootstrap" != "true" ]]; then
    echo "note: new pool members clone from base Ubuntu; cloud-init/Docker often needs several minutes before /health returns 200"
    noted_bootstrap=true
  fi

  if [[ "$healthy" -ge "$MIN_HOSTS" ]]; then
    exit 0
  fi
  sleep 10
done

echo "Timed out waiting for ${MIN_HOSTS} healthy host(s) on tag ${TAG} (pool=${POOL_ID:-tag-only})" >&2
exit 1
