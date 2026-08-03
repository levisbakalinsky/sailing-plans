#!/usr/bin/env bash
# Read or write /opt/sailing-plans/release.json on pool hosts.
# Usage:
#   release-state.sh get
#   release-state.sh put <json-file>
# Env: POOL_TAG, DIGITALOCEAN_TOKEN, DROPLET_USER, DROPLET_SSH_KEY
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ACTION="${1:-}"
FILE="${2:-}"
REMOTE_PATH="/opt/sailing-plans/release.json"

if [[ "$ACTION" != "get" && "$ACTION" != "put" ]]; then
  echo "usage: release-state.sh get|put [json-file]" >&2
  exit 2
fi

USER_NAME="${DROPLET_USER:-root}"
KEY_PATH="$(mktemp)"
printf '%s\n' "${DROPLET_SSH_KEY}" >"$KEY_PATH"
chmod 600 "$KEY_PATH"
cleanup() { rm -f "$KEY_PATH"; }
trap cleanup EXIT

SSH_OPTS=(-o StrictHostKeyChecking=accept-new -o UserKnownHostsFile=/dev/null -o IdentitiesOnly=yes -o LogLevel=ERROR -i "$KEY_PATH")
mapfile -t HOSTS < <("$SCRIPT_DIR/pool-hosts.sh")
if [[ "${#HOSTS[@]}" -eq 0 ]]; then
  echo "No hosts for POOL_TAG=${POOL_TAG:-}" >&2
  exit 1
fi

if [[ "$ACTION" == "get" ]]; then
  raw="$(ssh "${SSH_OPTS[@]}" "${USER_NAME}@${HOSTS[0]}" \
    "if [[ -f ${REMOTE_PATH} ]]; then cat ${REMOTE_PATH}; else echo '{}'; fi")"
  # Ensure valid JSON for callers.
  if ! jq -e . >/dev/null 2>&1 <<<"$raw"; then
    echo '{}' 
  else
    echo "$raw"
  fi
  exit 0
fi

if [[ -z "$FILE" || ! -f "$FILE" ]]; then
  echo "put requires a json file" >&2
  exit 2
fi

for host in "${HOSTS[@]}"; do
  scp "${SSH_OPTS[@]}" "$FILE" "${USER_NAME}@${host}:${REMOTE_PATH}"
  ssh "${SSH_OPTS[@]}" "${USER_NAME}@${host}" "chmod 644 ${REMOTE_PATH}"
  echo "Wrote release state to ${host}" >&2
done
