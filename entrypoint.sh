#!/bin/sh
set -eu

# PORT is injected by Railway (and most PaaS platforms). Default for local runs.
PORT="${PORT:-8080}"

# UUID: use the env var when provided. If it is empty, generate a fresh one
# for this boot and print it once, so a first-time deploy works out of the box.
# NOTE: an auto-generated UUID changes on every restart. Set UUID explicitly
# in your platform variables for a stable client configuration.
if [ -z "${UUID:-}" ]; then
  UUID="$(cat /proc/sys/kernel/random/uuid)"
  echo "[entrypoint] UUID env var not set - generated for this boot: ${UUID}"
  echo "[entrypoint] Set UUID in your service variables to keep it stable."
fi

# WS_PATH: default to a random path when not set, for the same reason.
if [ -z "${WS_PATH:-}" ]; then
  WS_PATH="/$(head -c 8 /dev/urandom | od -An -tx1 | tr -d ' \n')"
  echo "[entrypoint] WS_PATH env var not set - generated for this boot: ${WS_PATH}"
fi

# Normalise: WS_PATH must start with a slash.
case "${WS_PATH}" in
  /*) ;;
  *) WS_PATH="/${WS_PATH}" ;;
esac

sed -e "s/__PORT__/${PORT}/g" \
    -e "s/__UUID__/${UUID}/g" \
    -e "s|__WS_PATH__|${WS_PATH}|g" \
    /usr/local/xray/config.template.json > /usr/local/xray/config.json

echo "[entrypoint] Starting Xray on port ${PORT}, ws path ${WS_PATH}"
exec /usr/local/xray/xray run -config /usr/local/xray/config.json
