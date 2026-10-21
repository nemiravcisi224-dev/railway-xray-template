#!/bin/sh
# Generate a Clash / mihomo proxy entry for a deployed instance.
#
# Usage:
#   DOMAIN=your-app.up.railway.app UUID=<your-uuid> WS_PATH=/yourpath ./generate-client.sh
#
# DOMAIN, UUID and WS_PATH are required and are never stored in this repo.
set -eu

: "${DOMAIN:?Set DOMAIN, e.g. your-app.up.railway.app}"
: "${UUID:?Set UUID to the value used by your deployment}"
: "${WS_PATH:?Set WS_PATH to the value used by your deployment}"
NAME="${NAME:-railway-backup}"

cat <<EOF
proxies:
  - name: "${NAME}"
    type: vless
    server: ${DOMAIN}
    port: 443
    uuid: ${UUID}
    network: ws
    tls: true
    servername: ${DOMAIN}
    udp: true
    ws-opts:
      path: "${WS_PATH}"
      headers:
        Host: ${DOMAIN}
EOF
