#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   export APIC='https://10.0.0.10'
#   export APIC_USER='admin'
#   read -rsp 'APIC password: ' APIC_PASS; export APIC_PASS; echo
#   ./rest-api-login-query.sh
#
# -k is for isolated lab environments with self-signed certificates.
# Production automation should validate TLS using a trusted CA.

: "${APIC:?Set APIC, e.g. https://10.0.0.10}"
: "${APIC_USER:?Set APIC_USER}"
: "${APIC_PASS:?Set APIC_PASS}"

COOKIE_FILE="$(mktemp)"
trap 'rm -f "$COOKIE_FILE"' EXIT

LOGIN_PAYLOAD=$(python3 - <<'PY'
import json, os
print(json.dumps({
    "aaaUser": {
        "attributes": {
            "name": os.environ["APIC_USER"],
            "pwd": os.environ["APIC_PASS"]
        }
    }
}))
PY
)

curl -sk -c "$COOKIE_FILE"   -H 'Content-Type: application/json'   -X POST   -d "$LOGIN_PAYLOAD"   "$APIC/api/aaaLogin.json" >/dev/null

curl -sk -b "$COOKIE_FILE"   "$APIC/api/node/class/fvTenant.json"   | python3 -m json.tool
