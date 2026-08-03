#!/usr/bin/env bash
# Wait until at least N pool hosts (by tag) respond 200 on /health.
# Usage: wait-pool-hosts.sh <tag> <min_hosts> [timeout_seconds]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TAG="${1:-}"
MIN_HOSTS="${2:-1}"
TIMEOUT="${3:-600}"

if [[ -z "$TAG" ]]; then
  echo "usage: wait-pool-hosts.sh <tag> <min_hosts> [timeout_seconds]" >&2
  exit 2
fi

deadline=$((SECONDS + TIMEOUT))
while (( SECONDS < deadline )); do
  mapfile -t HOSTS < <(POOL_TAG="$TAG" "$SCRIPT_DIR/pool-hosts.sh" "$TAG" || true)
  healthy=0
  for host in "${HOSTS[@]:-}"; do
    [[ -n "$host" ]] || continue
    code="$(curl -sS -m 5 -o /dev/null -w '%{http_code}' "http://${host}/health" || true)"
    if [[ "$code" == "200" ]]; then
      healthy=$((healthy + 1))
    fi
  done
  echo "tag=${TAG} hosts=${#HOSTS[@]} healthy=${healthy} (want >= ${MIN_HOSTS})"
  if [[ "$healthy" -ge "$MIN_HOSTS" ]]; then
    exit 0
  fi
  sleep 10
done

echo "Timed out waiting for ${MIN_HOSTS} healthy host(s) on tag ${TAG}" >&2
exit 1
