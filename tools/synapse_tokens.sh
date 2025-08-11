#!/usr/bin/env bash
set -euo pipefail

# Helper for Synapse registration tokens (invite-only registration)
#
# Usage:
#   bash tools/synapse_tokens.sh --host http://10.0.0.10:8008 --token <ADMIN_TOKEN> list
#   bash tools/synapse_tokens.sh --host http://10.0.0.10:8008 --token <ADMIN_TOKEN> create [--uses 1] [--length 16] [--valid-days 7]
#   bash tools/synapse_tokens.sh --host http://10.0.0.10:8008 --token <ADMIN_TOKEN> get <TOKEN>
#   bash tools/synapse_tokens.sh --host http://10.0.0.10:8008 --token <ADMIN_TOKEN> delete <TOKEN>
#
# Notes:
# - You need an admin access token. Obtain one by logging in as an admin user
#   and copying the access token from the client, or via the client login API.
# - Pretty printing requires jq; otherwise raw JSON is printed.

HOST="${HOST:-http://10.0.0.10:8008}"
ADMIN_TOKEN="${TOKEN:-}"

pretty() {
  if command -v jq >/dev/null 2>&1; then
    jq . || true
  else
    cat
  fi
}

err() { echo "[synapse-tokens] $*" >&2; }
usage() {
  cat >&2 <<USAGE
Usage:
  $0 [--host URL] --token TOKEN list
  $0 [--host URL] --token TOKEN create [--uses N] [--length N] [--valid-days N]
  $0 [--host URL] --token TOKEN get <TOKEN>
  $0 [--host URL] --token TOKEN delete <TOKEN>

Defaults:
  --host defaults to ${HOST}

Examples:
  $0 --host http://10.0.0.10:8008 --token ABCDEF list
  $0 --token ABCDEF create --uses 1 --length 16 --valid-days 7
USAGE
}

cmd=""
uses_allowed=""
length=""
valid_days=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --host)
      HOST="$2"; shift 2 ;;
    --token)
      ADMIN_TOKEN="$2"; shift 2 ;;
    --uses)
      uses_allowed="$2"; shift 2 ;;
    --length)
      length="$2"; shift 2 ;;
    --valid-days)
      valid_days="$2"; shift 2 ;;
    list|get|create|delete)
      cmd="$1"; shift ; break ;;
    -h|--help)
      usage; exit 0 ;;
    *)
      err "Unknown flag or command: $1"; usage; exit 1 ;;
  esac
done

[[ -n "$cmd" ]] || { usage; exit 1; }
[[ -n "$ADMIN_TOKEN" ]] || { err "--token is required"; exit 1; }

API_BASE="$HOST/_synapse/admin/v1/registration_tokens"

case "$cmd" in
  list)
    curl -fsSL -H "Authorization: Bearer ${ADMIN_TOKEN}" "${API_BASE}" | pretty
    ;;

  get)
    token_value="${1:-}"; [[ -n "$token_value" ]] || { err "get requires <TOKEN>"; exit 1; }
    curl -fsSL -H "Authorization: Bearer ${ADMIN_TOKEN}" "${API_BASE}/${token_value}" | pretty
    ;;

  delete)
    token_value="${1:-}"; [[ -n "$token_value" ]] || { err "delete requires <TOKEN>"; exit 1; }
    curl -fsS -X DELETE -H "Authorization: Bearer ${ADMIN_TOKEN}" "${API_BASE}/${token_value}" -o /dev/null
    echo "Deleted token: ${token_value}"
    ;;

  create)
    body="{}"
    # Build JSON body incrementally
    tmp="{}"
    if [[ -n "$uses_allowed" ]]; then
      tmp=$(printf '%s' "$tmp" | jq ".uses_allowed = (${uses_allowed}|tonumber)" 2>/dev/null || true)
      if [[ -z "$tmp" || "$tmp" == "null" ]]; then
        err "--uses requires jq installed"; exit 1
      fi
      body="$tmp"
    fi
    if [[ -n "$length" ]]; then
      tmp=$(printf '%s' "$body" | jq ".length = (${length}|tonumber)" 2>/dev/null || true)
      if [[ -z "$tmp" || "$tmp" == "null" ]]; then
        err "--length requires jq installed"; exit 1
      fi
      body="$tmp"
    fi
    if [[ -n "$valid_days" ]]; then
      # Expiry time is in milliseconds since epoch
      if ! command -v date >/dev/null 2>&1; then
        err "date command not found for --valid-days"; exit 1
      fi
      seconds=$(date -d "+${valid_days} days" +%s 2>/dev/null || true)
      if [[ -z "$seconds" ]]; then
        # macOS BSD date fallback
        seconds=$(date -v+${valid_days}d +%s 2>/dev/null || true)
      fi
      [[ -n "$seconds" ]] || { err "failed to compute expiry from --valid-days"; exit 1; }
      ms=$(( seconds * 1000 ))
      tmp=$(printf '%s' "$body" | jq ".expiry_time = ${ms}" 2>/dev/null || true)
      if [[ -z "$tmp" || "$tmp" == "null" ]]; then
        err "--valid-days requires jq installed"; exit 1
      fi
      body="$tmp"
    fi

    # POST create
    curl -fsSL -X POST \
      -H 'Content-Type: application/json' \
      -H "Authorization: Bearer ${ADMIN_TOKEN}" \
      -d "${body}" \
      "${API_BASE}/new" | pretty
    ;;
esac

