#!/usr/bin/env bash
# Run a remote bash script on every Droplet in the autoscale pool (by tag).
# Usage:
#   ssh-pool.sh [--first-only] -- <remote-script>
# Env: POOL_TAG, DIGITALOCEAN_TOKEN, DROPLET_USER, DROPLET_SSH_KEY (or DROPLET_SSH_KEY_PATH)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FIRST_ONLY=false
REMOTE_SCRIPT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --first-only)
      FIRST_ONLY=true
      shift
      ;;
    --)
      shift
      REMOTE_SCRIPT="$*"
      break
      ;;
    *)
      echo "unknown arg: $1" >&2
      exit 2
      ;;
  esac
done

if [[ -z "$REMOTE_SCRIPT" ]]; then
  echo "usage: ssh-pool.sh [--first-only] -- <remote bash>" >&2
  exit 2
fi

USER_NAME="${DROPLET_USER:-root}"
KEY_PATH="${DROPLET_SSH_KEY_PATH:-}"
CLEANUP_KEY=""

if [[ -z "$KEY_PATH" ]]; then
  if [[ -z "${DROPLET_SSH_KEY:-}" ]]; then
    echo "DROPLET_SSH_KEY or DROPLET_SSH_KEY_PATH is required" >&2
    exit 2
  fi
  KEY_PATH="$(mktemp)"
  CLEANUP_KEY="$KEY_PATH"
  printf '%s\n' "$DROPLET_SSH_KEY" >"$KEY_PATH"
  chmod 600 "$KEY_PATH"
fi

cleanup() {
  if [[ -n "$CLEANUP_KEY" ]]; then
    rm -f "$CLEANUP_KEY"
  fi
}
trap cleanup EXIT

HOSTS=()
while IFS= read -r host; do
  [[ -n "$host" ]] || continue
  HOSTS+=("$host")
done < <("$SCRIPT_DIR/pool-hosts.sh")

if [[ "${#HOSTS[@]}" -eq 0 ]]; then
  echo "No Droplets found for tag ${POOL_TAG:-<unset>}" >&2
  exit 1
fi

echo "Pool hosts (${#HOSTS[@]}): ${HOSTS[*]}"

SSH_OPTS=(-o StrictHostKeyChecking=accept-new -o UserKnownHostsFile=/dev/null -o IdentitiesOnly=yes -i "$KEY_PATH")

run_one() {
  local host="$1"
  echo "==== ${USER_NAME}@${host} ===="
  ssh "${SSH_OPTS[@]}" "${USER_NAME}@${host}" "bash -s" <<<"$REMOTE_SCRIPT"
}

if [[ "$FIRST_ONLY" == "true" ]]; then
  run_one "${HOSTS[0]}"
  exit 0
fi

fail=0
for host in "${HOSTS[@]}"; do
  if ! run_one "$host"; then
    echo "FAILED on $host" >&2
    fail=1
  fi
done
exit "$fail"
