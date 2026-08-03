#!/usr/bin/env bash
# Read or write /opt/sailing-plans/release.json on pool hosts.
# Usage:
#   release-state.sh get
#   release-state.sh put <json-file>
# Env: POOL_TAG (or pass via pool-hosts), DIGITALOCEAN_TOKEN, DROPLET_USER, DROPLET_SSH_KEY
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ACTION="${1:-}"
FILE="${2:-}"
REMOTE_PATH="/opt/sailing-plans/release.json"

if [[ "$ACTION" != "get" && "$ACTION" != "put" ]]; then
  echo "usage: release-state.sh get|put [json-file]" >&2
  exit 2
fi

if [[ "$ACTION" == "get" ]]; then
  "$SCRIPT_DIR/ssh-pool.sh" --first-only -- "$(cat <<EOF
set -euo pipefail
if [[ -f ${REMOTE_PATH} ]]; then
  cat ${REMOTE_PATH}
else
  echo '{}'
fi
EOF
)"
  exit 0
fi

if [[ -z "$FILE" || ! -f "$FILE" ]]; then
  echo "put requires a json file" >&2
  exit 2
fi

KEY_PATH="$(mktemp)"
printf '%s\n' "${DROPLET_SSH_KEY}" >"$KEY_PATH"
chmod 600 "$KEY_PATH"
mapfile -t HOSTS < <("$SCRIPT_DIR/pool-hosts.sh")
if [[ "${#HOSTS[@]}" -eq 0 ]]; then
  echo "No hosts for POOL_TAG=${POOL_TAG:-}" >&2
  rm -f "$KEY_PATH"
  exit 1
fi
for host in "${HOSTS[@]}"; do
  scp -o StrictHostKeyChecking=accept-new -o UserKnownHostsFile=/dev/null -o IdentitiesOnly=yes \
    -i "$KEY_PATH" \
    "$FILE" "${DROPLET_USER}@${host}:${REMOTE_PATH}"
  ssh -o StrictHostKeyChecking=accept-new -o UserKnownHostsFile=/dev/null -o IdentitiesOnly=yes \
    -i "$KEY_PATH" \
    "${DROPLET_USER}@${host}" "chmod 644 ${REMOTE_PATH}"
  echo "Wrote release state to ${host}"
done
rm -f "$KEY_PATH"
