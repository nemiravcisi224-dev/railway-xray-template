FROM alpine:3.20

# Pin Xray version: v26.10.21, emergency security update (Oct 2026) that
# removed three compromised root CAs; smoke-tested with this template's
# VLESS + WS config (server start + WebSocket handshake OK).
# This template uses WS+TLS, not Reality, so the 26.x Reality handshake
# changes do not apply to it.
ARG XRAY_VERSION=v26.10.21

RUN apk add --no-cache ca-certificates curl unzip tzdata \
&& curl -fsSL -o /tmp/xray.zip "https://github.com/XTLS/Xray-core/releases/download/${XRAY_VERSION}/Xray-linux-64.zip" \
&& mkdir -p /usr/local/xray \
&& unzip -o /tmp/xray.zip -d /usr/local/xray \
&& chmod +x /usr/local/xray/xray \
&& rm /tmp/xray.zip
COPY entrypoint.sh /entrypoint.sh
COPY config.template.json /usr/local/xray/config.template.json
RUN chmod +x /entrypoint.sh
CMD ["/entrypoint.sh"]
