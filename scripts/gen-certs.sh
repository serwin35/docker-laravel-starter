#!/usr/bin/env bash
# =============================================================================
# Generate self-signed SSL certificate for local HTTPS development
#
# Usage:
#   bash scripts/gen-certs.sh
#   bash scripts/gen-certs.sh yourdomain.local
# =============================================================================

set -euo pipefail

DOMAIN="${1:-localhost}"
CERTS_DIR=".docker/nginx/certs"

mkdir -p "$CERTS_DIR"

echo "Generating self-signed certificate for: $DOMAIN"

openssl req -x509 \
    -nodes \
    -days 825 \
    -newkey rsa:2048 \
    -keyout "${CERTS_DIR}/self-signed.key" \
    -out    "${CERTS_DIR}/self-signed.crt" \
    -subj   "/C=PL/ST=Local/L=Local/O=Dev/CN=${DOMAIN}" \
    -addext "subjectAltName=DNS:${DOMAIN},DNS:*.${DOMAIN},IP:127.0.0.1"

echo ""
echo "Certificate generated:"
echo "  ${CERTS_DIR}/self-signed.crt"
echo "  ${CERTS_DIR}/self-signed.key"
echo ""
echo "Next steps:"
echo "  1. Swap app.conf for app-ssl.conf in your nginx Dockerfile or docker-compose volume"
echo "  2. Change APP_PORT to 443 and add port 443 mapping in docker-compose.dev.yml"
echo "  3. Update APP_URL=https://${DOMAIN} in .env"
echo ""
echo "To trust the cert in your browser (macOS):"
echo "  sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain ${CERTS_DIR}/self-signed.crt"
