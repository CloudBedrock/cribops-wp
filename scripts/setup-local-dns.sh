#!/bin/bash
# Setup local DNS resolver for .local domains on macOS
# This allows *.local domains to resolve to 127.0.0.1 without editing /etc/hosts

set -e

DOMAIN="${1:-mysite.local}"
TLD=$(echo "$DOMAIN" | awk -F. '{print $NF}')

echo "🌐 Setting up DNS resolver for .$TLD domains"
echo ""

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "⚠️  This script is for macOS only"
    echo ""
    echo "For Linux, add this to /etc/hosts:"
    echo "127.0.0.1  $DOMAIN"
    echo ""
    echo "For Windows, add this to C:\\Windows\\System32\\drivers\\etc\\hosts:"
    echo "127.0.0.1  $DOMAIN"
    echo ""
    exit 1
fi

# Create resolver directory if it doesn't exist
if [ ! -d /etc/resolver ]; then
    echo "📁 Creating /etc/resolver directory (requires sudo)..."
    sudo mkdir -p /etc/resolver
fi

# Create resolver file for the TLD
RESOLVER_FILE="/etc/resolver/$TLD"
echo "📝 Creating resolver file: $RESOLVER_FILE"
echo "nameserver 127.0.0.1" | sudo tee "$RESOLVER_FILE" > /dev/null

echo ""
echo "✅ DNS resolver configured!"
echo ""
echo "All *.$TLD domains will now resolve to 127.0.0.1"
echo ""
echo "Testing DNS resolution..."
if command -v dscacheutil &> /dev/null; then
    sudo dscacheutil -flushcache
    echo "🔄 DNS cache flushed"
fi

echo ""
echo "🧪 Test with: ping $DOMAIN"
echo ""
echo "To remove this later:"
echo "  sudo rm $RESOLVER_FILE"
echo ""
