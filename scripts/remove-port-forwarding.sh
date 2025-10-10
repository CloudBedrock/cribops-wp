#!/bin/bash

# Remove port forwarding setup for Docker WordPress

set -e

echo "🗑️  Removing port forwarding: 443 → 8443"
echo ""

PF_ANCHOR_FILE="/etc/pf.anchors/com.docker.wordpress"

# Remove anchor file
if [ -f "$PF_ANCHOR_FILE" ]; then
    echo "📝 Removing anchor file..."
    sudo rm "$PF_ANCHOR_FILE"
    echo "✅ Anchor file removed"
else
    echo "ℹ️  Anchor file doesn't exist"
fi

# Remove from pf.conf
if sudo grep -q "com.docker.wordpress" /etc/pf.conf 2>/dev/null; then
    echo "📝 Removing anchor reference from /etc/pf.conf..."

    # Backup pf.conf
    sudo cp /etc/pf.conf /etc/pf.conf.backup.$(date +%Y%m%d_%H%M%S)

    # Remove the anchor lines
    sudo sed -i '' '/com.docker.wordpress/d' /etc/pf.conf
    sudo sed -i '' '/Docker WordPress port forwarding/d' /etc/pf.conf

    echo "✅ Anchor reference removed from /etc/pf.conf"

    # Reload pf
    echo "🔄 Reloading pf rules..."
    sudo pfctl -f /etc/pf.conf 2>/dev/null

    echo "✅ Port forwarding removed!"
else
    echo "ℹ️  No anchor reference found in /etc/pf.conf"
fi

echo ""
echo "✅ Cleanup complete!"
echo "   You'll need to use https://wpdemo.local:8443 now"
