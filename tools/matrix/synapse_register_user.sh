#!/usr/bin/env bash
set -euo pipefail

# Create a Matrix user on Synapse using the registration_shared_secret
# inside the Matrix VM (no admin token required).

# Usage:
#   bash tools/matrix/synapse_register_user.sh -u <USER> -p <PASS> [-a]
#   [--vm matrix] [--host http://localhost:8008]

USER_NAME=""
USER_PASS=""
ADMIN_FLAG=""
VM_NAME="matrix"
SYNAPSE_URL="http://localhost:8008"

usage() {
  cat <<USAGE
Usage:
  $0 -u <USER> -p <PASS> [-a] [--vm matrix] [--host URL]
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -u|--user) USER_NAME="$2"; shift 2 ;;
    -p|--pass) USER_PASS="$2"; shift 2 ;;
    -a|--admin) ADMIN_FLAG="-a"; shift 1 ;;
    --vm) VM_NAME="$2"; shift 2 ;;
    --host) SYNAPSE_URL="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown arg: $1" >&2; usage; exit 1 ;;
  esac
done

[[ -n "$USER_NAME" && -n "$USER_PASS" ]] || { echo "Missing -u/--user and/or -p/--pass" >&2; usage; exit 1; }

INNER_CMD=$(cat <<'EOF'
set -euo pipefail
file=/run/host-secrets/matrix/registration.yaml
test -r "$file"
secret="$(sed -n "s/^registration_shared_secret:[[:space:]]*//p" "$file" | tr -d "\r" | tr -d '"\'' | tr -d ' ')"
if [ -z "$secret" ]; then echo "Failed to parse registration_shared_secret" >&2; exit 1; fi
echo "Using shared-secret of length ${#secret}"
register_new_matrix_user -k "$secret" __ADMIN_FLAG__ -u '__USER__' -p '__PASS__' '__URL__'
EOF
)

INNER_CMD=${INNER_CMD/__ADMIN_FLAG__/$ADMIN_FLAG}
INNER_CMD=${INNER_CMD/__USER__/$USER_NAME}
INNER_CMD=${INNER_CMD/__PASS__/$USER_PASS}
INNER_CMD=${INNER_CMD/__URL__/$SYNAPSE_URL}

if ! machinectl shell "${VM_NAME}@" /bin/sh -lc "$INNER_CMD"; then
  echo "User registration failed. Ensure the VM is running and the secret is available at /run/host-secrets/matrix/registration.yaml" >&2
  exit 1
fi

echo "User '${USER_NAME}' created${ADMIN_FLAG:+ as admin}."

