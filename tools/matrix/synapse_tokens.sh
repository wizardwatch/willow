#!/usr/bin/env bash
set -euo pipefail

# Manage Synapse registration tokens via admin API.
#
# Usage examples:
#   bash tools/matrix/synapse_tokens.sh --host http://10.0.0.10:8008 --token-file /var/lib/matrix/synapse_admin_token list
#   bash tools/matrix/synapse_tokens.sh --host http://10.0.0.10:8008 --token <ADMIN_TOKEN> create --uses 1 --length 16 --valid-days 7
#   bash tools/matrix/synapse_tokens.sh --host http://10.0.0.10:8008 --token <ADMIN_TOKEN> put MYJOINCODE --uses 100
#
# Notes:
# - Provide an admin access token via --token, --token-file, or SYNAPSE_ADMIN_TOKEN env.
# - Pretty printing requires jq; otherwise raw JSON is printed.

HOST="${HOST:-http://10.0.0.10:8008}"
ADMIN_TOKEN="${TOKEN:-}"
TOKEN_FILE="${TOKEN_FILE:-}"

pretty() { command -v jq >/dev/null 2>&1 && jq . || cat; }
err() { echo "[synapse-tokens] $*" >&2; }

usage() {
  cat >&2 <<USAGE
Usage:
  $0 [--host URL] (--token TOKEN | --token-file PATH) list
  $0 [--host URL] (--token TOKEN | --token-file PATH) get <TOKEN>
  $0 [--host URL] (--token TOKEN | --token-file PATH) delete <TOKEN>
  $0 [--host URL] (--token TOKEN | --token-file PATH) create [--uses N] [--length N] [--valid-days N]
  $0 [--host URL] (--token TOKEN | --token-file PATH) put <TOKEN> [--uses N] [--valid-days N]

Defaults:
  --host defaults to ${HOST}
USAGE
}

cmd=""
uses_allowed=""
length=""
valid_days=""
token_value=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --host) HOST="$2"; shift 2 ;;
    --token) ADMIN_TOKEN="$2"; shift 2 ;;
    --token-file) TOKEN_FILE="$2"; shift 2 ;;
    --uses) uses_allowed="$2"; shift 2 ;;
    --length) length="$2"; shift 2 ;;
    --valid-days) valid_days="$2"; shift 2 ;;
    list|get|create|delete|put) cmd="$1"; shift ; break ;;
    -h|--help) usage; exit 0 ;;
    *) err "Unknown flag or command: $1"; usage; exit 1 ;;
  esac
done

[[ -n "$cmd" ]] || { usage; exit 1; }

if [[ -z "$ADMIN_TOKEN" ]]; then
  if [[ -n "$TOKEN_FILE" ]]; then
    [[ -r "$TOKEN_FILE" ]] || { err "--token-file not readable: $TOKEN_FILE"; exit 1; }
    ADMIN_TOKEN=$(cat "$TOKEN_FILE")
  elif [[ -r "/var/lib/matrix/synapse_admin_token" ]]; then
    ADMIN_TOKEN=$(cat /var/lib/matrix/synapse_admin_token)
  elif [[ -n "${SYNAPSE_ADMIN_TOKEN:-}" ]]; then
    ADMIN_TOKEN="$SYNAPSE_ADMIN_TOKEN"
  else
    err "Provide --token or --token-file, or set SYNAPSE_ADMIN_TOKEN env"; exit 1
  fi
fi

API_BASE="${HOST}/_synapse/admin/v1/registration_tokens"

ms_from_valid_days() {
  local days="$1"
  local seconds
  seconds=$(date -d "+${days} days" +%s 2>/dev/null || date -v+${days}d +%s 2>/dev/null || true)
  [[ -n "$seconds" ]] || { err "failed to compute expiry from --valid-days"; return 1; }
  echo $((seconds * 1000))
}

case "$cmd" in
  list)
    curl -fsSL -H "Authorization: Bearer ${ADMIN_TOKEN}" "${API_BASE}" | pretty ;;

  get)
    token_value="${1:-}"; [[ -n "$token_value" ]] || { err "get requires <TOKEN>"; exit 1; }
    curl -fsSL -H "Authorization: Bearer ${ADMIN_TOKEN}" "${API_BASE}/${token_value}" | pretty ;;

  delete)
    token_value="${1:-}"; [[ -n "$token_value" ]] || { err "delete requires <TOKEN>"; exit 1; }
    curl -fsS -X DELETE -H "Authorization: Bearer ${ADMIN_TOKEN}" "${API_BASE}/${token_value}" -o /dev/null
    echo "Deleted token: ${token_value}" ;;

  create)
    body="{}"
    if [[ -n "$uses_allowed" ]]; then
      body=$(printf '%s' "$body" | jq ".uses_allowed = (${uses_allowed}|tonumber)" 2>/dev/null || { err "--uses requires jq"; exit 1; })
    fi
    if [[ -n "$length" ]]; then
      body=$(printf '%s' "$body" | jq ".length = (${length}|tonumber)" 2>/dev/null || { err "--length requires jq"; exit 1; })
    fi
    if [[ -n "$valid_days" ]]; then
      ms=$(ms_from_valid_days "$valid_days") || exit 1
      body=$(printf '%s' "$body" | jq ".expiry_time = ${ms}" 2>/dev/null || { err "--valid-days requires jq"; exit 1; })
    fi
    curl -fsSL -X POST -H 'Content-Type: application/json' -H "Authorization: Bearer ${ADMIN_TOKEN}" -d "$body" "${API_BASE}/new" | pretty ;;

  put)
    token_value="${1:-}"; [[ -n "$token_value" ]] || { err "put requires <TOKEN>"; exit 1; }
    # Build body for fixed token
    body="{}"
    if [[ -n "$uses_allowed" ]]; then
      body=$(printf '%s' "$body" | jq ".uses_allowed = (${uses_allowed}|tonumber)" 2>/dev/null || { err "--uses requires jq"; exit 1; })
    else
      body=$(printf '%s' "$body" | jq ".uses_allowed = null" 2>/dev/null || { err "requires jq"; exit 1; })
    fi
    if [[ -n "$valid_days" ]]; then
      ms=$(ms_from_valid_days "$valid_days") || exit 1
      body=$(printf '%s' "$body" | jq ".expiry_time = ${ms}" 2>/dev/null || { err "--valid-days requires jq"; exit 1; })
    fi
    curl -fsSL -X PUT -H 'Content-Type: application/json' -H "Authorization: Bearer ${ADMIN_TOKEN}" -d "$body" "${API_BASE}/${token_value}" | pretty ;;
esac

