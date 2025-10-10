#!/bin/bash
# Setup SSL certificates for local development using mkcert
# This script creates trusted SSL certificates for .local domains

set -e

DOMAIN="${1:-mysite.local}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
SSL_DIR="$PROJECT_DIR/ssl"

echo "🔒 Setting up SSL certificates for local development"
echo ""

# Check if mkcert is installed
if ! command -v mkcert &> /dev/null; then
    echo "❌ mkcert is not installed"
    echo ""
    echo "Please install mkcert first:"
    echo ""
    echo "macOS:"
    echo "  brew install mkcert"
    echo "  brew install nss  # for Firefox support"
    echo ""
    echo "Linux:"
    echo "  wget https://github.com/FiloSottile/mkcert/releases/latest/download/mkcert-v*-linux-amd64"
    echo "  chmod +x mkcert-v*-linux-amd64"
    echo "  sudo mv mkcert-v*-linux-amd64 /usr/local/bin/mkcert"
    echo ""
    exit 1
fi

# Install local CA if not already done
echo "📋 Checking for local CA..."
if ! mkcert -check &> /dev/null; then
    echo "📦 Installing local CA (you may be prompted for password)..."
    mkcert -install
    echo "✅ Local CA installed"
else
    echo "✅ Local CA already installed"
fi

# Create SSL directory
mkdir -p "$SSL_DIR"

# Generate certificate
echo ""
echo "🔐 Generating certificate for: $DOMAIN and *.$DOMAIN"
cd "$SSL_DIR"
mkcert -cert-file cert.pem -key-file key.pem "$DOMAIN" "*.$DOMAIN" localhost 127.0.0.1 ::1

echo ""
echo "✅ SSL certificates created successfully!"
echo ""
echo "📁 Certificates location: $SSL_DIR"
echo "   - Certificate: $SSL_DIR/cert.pem"
echo "   - Private Key: $SSL_DIR/key.pem"
echo ""
echo "Next steps:"
echo "1. Update your .env file:"
echo "   WORDPRESS_SITEURL=https://$DOMAIN"
echo "   WORDPRESS_HOME=https://$DOMAIN"
echo ""
echo "2. Setup DNS for .local domain:"
echo "   ./scripts/setup-local-dns.sh $DOMAIN"
echo ""
echo "3. Restart Docker containers:"
echo "   docker compose down && docker compose up -d"
echo ""
echo "4. Access your site at: https://$DOMAIN"
echo ""
