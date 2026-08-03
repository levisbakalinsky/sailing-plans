#!/usr/bin/env bash
# Durable release ledger in DigitalOcean Spaces.
# Usage:
#   release-ledger.sh list
#   release-ledger.sh get <id-or-sha-prefix>
#   release-ledger.sh current
#   release-ledger.sh append <json-object>
#   release-ledger.sh set-current <id>
#
# Env:
#   AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY (Spaces keys)
#   RELEASE_LEDGER_URI (default s3://sailing-plans-tfstate/releases/dev/ledger.json)
set -euo pipefail

ACTION="${1:-}"
ARG="${2:-}"
URI="${RELEASE_LEDGER_URI:-s3://sailing-plans-tfstate/releases/dev/ledger.json}"
ENDPOINT="${AWS_ENDPOINT_URL:-https://nyc3.digitaloceanspaces.com}"
MAX_RELEASES="${RELEASE_LEDGER_MAX:-50}"

export AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:-us-east-1}"
export AWS_EC2_METADATA_DISABLED=true

if [[ -z "${AWS_ACCESS_KEY_ID:-}" || -z "${AWS_SECRET_ACCESS_KEY:-}" ]]; then
  echo "AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY (Spaces) are required" >&2
  exit 2
fi

if ! command -v aws >/dev/null 2>&1; then
  echo "aws CLI is required" >&2
  exit 2
fi

aws_s3() {
  aws --endpoint-url "$ENDPOINT" s3 "$@"
}

empty_ledger='{"version":1,"current_id":null,"releases":[]}'

load() {
  if aws_s3 ls "$URI" >/dev/null 2>&1; then
    local body
    body="$(aws_s3 cp "$URI" - 2>/dev/null || true)"
    if [[ -z "$body" ]] || ! jq -e . >/dev/null 2>&1 <<<"$body"; then
      echo "$empty_ledger"
    else
      echo "$body"
    fi
  else
    echo "$empty_ledger"
  fi
}

save() {
  aws_s3 cp "$1" "$URI" --content-type application/json >/dev/null
}

case "$ACTION" in
  list)
    load | jq -r '
      . as $root
      | ((.releases // []) | sort_by(.created_at) | reverse) as $rels
      | (
          "MARKER\tID\tSHA\tCREATED\tSTATUS\tMESSAGE",
          ($rels[] |
            [
              (if .id == $root.current_id then "*" else "" end),
              .id,
              (.git_sha_short // (.git_sha[0:12] // "-")),
              (.created_at // "-"),
              (if .live == false then "staged" else "recorded" end),
              (.message // "")
            ] | @tsv)
        )
    '
    ;;

  current)
    ledger="$(load)"
    cid="$(jq -r '.current_id // empty' <<<"$ledger")"
    if [[ -z "$cid" ]]; then
      echo "{}"
      exit 0
    fi
    jq -ce --arg id "$cid" '(.releases // [])[] | select(.id == $id)' <<<"$ledger"
    ;;

  get)
    if [[ -z "$ARG" ]]; then
      echo "usage: release-ledger.sh get <id-or-sha-prefix>" >&2
      exit 2
    fi
    load | jq -ce --arg q "$ARG" '
      (.releases // []) as $all
      | ($all | map(select(
          .id == $q
          or .git_sha == $q
          or (.git_sha_short // "") == $q
        ))) as $exact
      | if ($exact | length) == 1 then $exact[0]
        elif ($exact | length) > 1 then error("ambiguous exact match for \($q)")
        else
          ($all | map(select(
            (.git_sha | startswith($q))
            or (.id | contains($q))
            or ((.git_sha_short // "") | startswith($q))
          ))) as $pref
          | if ($pref | length) == 0 then error("release not found: \($q)")
            elif ($pref | length) > 1 then error("ambiguous release prefix: \($q) (\($pref|length) matches)\n" + ($pref|map(.id)|join("\n")))
            else $pref[0]
            end
        end
    '
    ;;

  append)
    if [[ -z "$ARG" ]]; then
      echo "usage: release-ledger.sh append '<json>'" >&2
      exit 2
    fi
    tmp="$(mktemp)"
    load | jq -c --argjson rel "$ARG" --argjson max "$MAX_RELEASES" '
      (.releases // []) as $old
      | ($old | map(select(.id != $rel.id))) as $rest
      | .releases = (($rest + [$rel]) | sort_by(.created_at) | if length > $max then .[-$max:] else . end)
    ' >"$tmp"
    save "$tmp"
    rm -f "$tmp"
    jq -r '"appended \(.id)"' <<<"$ARG"
    ;;

  set-current)
    if [[ -z "$ARG" ]]; then
      echo "usage: release-ledger.sh set-current <id>" >&2
      exit 2
    fi
    tmp="$(mktemp)"
    load | jq -ce --arg id "$ARG" '
      (.releases // []) | map(select(.id == $id)) | if length == 0 then error("unknown release: \($id)") else .[0] end
    ' >/dev/null
    load | jq -c --arg id "$ARG" '
      .current_id = $id
      | .releases = [(.releases // [])[] | if .id == $id then .live = true else . end]
      | .updated_at = (now | todate)
    ' >"$tmp"
    save "$tmp"
    rm -f "$tmp"
    echo "current_id=$ARG"
    ;;

  *)
    echo "usage: release-ledger.sh list|get|current|append|set-current" >&2
    exit 2
    ;;
esac
