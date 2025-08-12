#!/usr/bin/env bash
set -euo pipefail

# Login to Synapse and print the JSON response (or just the access token).
# Shows error body on non-2xx to aid debugging.
# Usage:
#   bash tools/matrix/synapse_login.sh --host http://10.0.0.10:8008 -u <USER|@user:domain> -p <PASS> [--token-only] [--domain matrix.holymike.com]

HOST="${HOST:-http://10.0.0.10:8008}"
USER=""
PASS=""
TOKEN_ONLY=false
DOMAIN="matrix.holymike.com"

usage() {
  cat >&2 <<USAGE
Usage:
  $0 [--host URL] -u USER -p PASS [--token-only] [--domain DOMAIN]

Notes:
  - USER can be a localpart (e.g., alice) or a full MXID (@alice:domain)
  - If a localpart is provided, a fallback attempt with @USER:DOMAIN is made on 400 errors

Defaults:
  --host defaults to ${HOST}
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --host) HOST="$2"; shift 2 ;;
    -u|--user) USER="$2"; shift 2 ;;
    -p|--pass) PASS="$2"; shift 2 ;;
    --token-only) TOKEN_ONLY=true; shift ;;
    --domain) DOMAIN="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown arg: $1" >&2; usage; exit 1 ;;
  esac
done

[[ -n "$USER" && -n "$PASS" ]] || { usage; exit 1; }

to_json_string() { printf '"%s"' "${1//"/\\"}"; }

do_login() {
  local user_payload="$1"
  local out
  local json_payload="{\"password\":\"${PASS}\",\"identifier\":{\"type\":\"m.id.user\",\"user\":${user_payload}},\"initial_device_display_name\":\"synapse_login.sh\",\"type\":\"m.login.password\"}"
  out=$(curl -sS -X POST \
    -H 'Content-Type: application/json' \
    -w '\n%{http_code}\n' \
    -d "$json_payload" \
    "${HOST}/_matrix/client/v3/login")
  printf '%s' "$out"
}

attempt_user="$USER"
echo "Attempting login as $attempt_user with password ${PASS}"
resp=$(do_login "$(to_json_string "$attempt_user")")
code="${resp##*$'\n'}"; body="${resp%$'\n'*}"

if [[ "$code" != 200* && "$code" != 2* ]]; then
  if [[ "$USER" != @*:* && "$code" == 400* ]]; then
    attempt_user="@${USER}:${DOMAIN}"
    resp=$(do_login "$(to_json_string "$attempt_user")")
    code="${resp##*$'\n'}"; body="${resp%$'\n'*}"
  fi
fi

if [[ "$code" == 200* || "$code" == 2* ]]; then
  if $TOKEN_ONLY; then
    if command -v jq >/dev/null 2>&1; then echo "$body" | jq -r .access_token; else echo "$body" | sed -n 's/.*"access_token"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p'; fi
  else
    if command -v jq >/dev/null 2>&1; then echo "$body" | jq .; else echo "$body"; fi
  fi
  exit 0
else
  echo "Login failed (HTTP $code). Response:" >&2
  if command -v jq >/dev/null 2>&1; then echo "$body" | jq . >&2 || echo "$body" >&2; else echo "$body" >&2; fi
  exit 1
fi
