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

# For .local TLD, we need to use /etc/hosts instead of resolver
# macOS resolver files require a real DNS server, not just 127.0.0.1
if [ "$TLD" = "local" ]; then
    echo "📝 Adding $DOMAIN to /etc/hosts..."

    # Check if entry already exists
    if grep -q "$DOMAIN" /etc/hosts; then
        echo "ℹ️  Entry already exists in /etc/hosts"
    else
        # Add entry
        echo "127.0.0.1  $DOMAIN" | sudo tee -a /etc/hosts > /dev/null
        echo "✅ Added $DOMAIN to /etc/hosts"
    fi
else
    # For other TLDs, use resolver file (requires DNS server)
    RESOLVER_FILE="/etc/resolver/$TLD"
    echo "📝 Creating resolver file: $RESOLVER_FILE"
    echo "nameserver 127.0.0.1" | sudo tee "$RESOLVER_FILE" > /dev/null
fi

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
