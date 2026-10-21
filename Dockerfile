FROM alpine:3.20

# Pin Xray version: 25.12.8 is tested with mihomo / Clash Meta clients.
# (26.x changed parts of the Reality handshake; this template uses WS+TLS,
#  but we keep the known-good pin for reproducibility.)
ARG XRAY_VERSION=v25.12.8

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
