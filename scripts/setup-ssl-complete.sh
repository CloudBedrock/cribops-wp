#!/bin/bash
# Complete SSL setup script for local HTTPS development
# This script handles everything in the right order

set -e

DOMAIN="${1:-mysite.local}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "🔒 Complete SSL Setup for $DOMAIN"
echo "=================================="
echo ""

# Step 1: Check mkcert
echo "📋 Step 1: Checking mkcert installation..."
if ! command -v mkcert &> /dev/null; then
    echo "❌ mkcert not found"
    echo ""
    echo "Install with: brew install mkcert nss"
    exit 1
fi
echo "✅ mkcert is installed"
echo ""

# Step 2: Generate certificates
echo "📋 Step 2: Generating SSL certificates..."
cd "$PROJECT_DIR"

if [ ! -d "ssl" ]; then
    mkdir ssl
fi

cd ssl

# Install local CA if not already done
if ! mkcert -check &> /dev/null; then
    echo "📦 Installing local CA (you may be prompted for password)..."
    mkcert -install
fi

# Generate certificate
echo "🔐 Generating certificate for: $DOMAIN and *.$DOMAIN"
mkcert -cert-file cert.pem -key-file key.pem "$DOMAIN" "*.$DOMAIN" localhost 127.0.0.1 ::1

echo "✅ Certificates created in $PROJECT_DIR/ssl/"
echo ""

# Step 3: Add to /etc/hosts
echo "📋 Step 3: Adding $DOMAIN to /etc/hosts..."
if grep -q "$DOMAIN" /etc/hosts 2>/dev/null; then
    echo "✅ $DOMAIN already in /etc/hosts"
else
    echo "127.0.0.1  $DOMAIN" | sudo tee -a /etc/hosts > /dev/null
    echo "✅ Added $DOMAIN to /etc/hosts"
fi
echo ""

# Step 4: Test DNS
echo "📋 Step 4: Testing DNS resolution..."
if ping -c 1 "$DOMAIN" &> /dev/null; then
    echo "✅ $DOMAIN resolves correctly"
else
    echo "⚠️  DNS resolution failed - please check /etc/hosts"
fi
echo ""

# Step 5: Instructions
echo "✅ SSL setup complete!"
echo ""
echo "📋 Next steps:"
echo ""
echo "1. Update your .env file:"
echo "   SERVER_NAME=$DOMAIN"
echo "   WORDPRESS_SITEURL=https://$DOMAIN:8443"
echo "   WORDPRESS_HOME=https://$DOMAIN:8443"
echo ""
echo "2. Copy SSL certificates to your project:"
echo "   cp -r $PROJECT_DIR/ssl /path/to/your/project/"
echo ""
echo "3. Start Docker containers:"
echo "   docker compose up -d"
echo ""
echo "4. Enable SSL in Apache:"
echo "   ./scripts/enable-ssl.sh"
echo ""
echo "5. Access your site:"
echo "   https://$DOMAIN:8443"
echo ""
