#!/bin/bash

# Setup port forwarding from 443 to 8443 on macOS using pf
# This allows accessing https://wpdemo.local instead of https://wpdemo.local:8443

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "🔀 Setting up port forwarding: 443 → 8443"
echo ""

# Create pf anchor file for port forwarding
PF_ANCHOR_FILE="/etc/pf.anchors/com.docker.wordpress"

echo "📝 Creating pf anchor file..."
cat <<'EOF' | sudo tee "$PF_ANCHOR_FILE" > /dev/null
# Forward port 443 to 8443 for Docker WordPress
rdr pass on lo0 inet proto tcp from any to any port 443 -> 127.0.0.1 port 8443
rdr pass on en0 inet proto tcp from any to any port 443 -> 127.0.0.1 port 8443
EOF

echo "✅ Anchor file created: $PF_ANCHOR_FILE"
echo ""

# Check if pf.conf already has our anchor
if ! sudo grep -q "com.docker.wordpress" /etc/pf.conf 2>/dev/null; then
    echo "📝 Adding anchor reference to /etc/pf.conf..."

    # Backup pf.conf
    sudo cp /etc/pf.conf /etc/pf.conf.backup.$(date +%Y%m%d_%H%M%S)

    # Add anchor reference
    echo "" | sudo tee -a /etc/pf.conf > /dev/null
    echo "# Docker WordPress port forwarding (443 -> 8443)" | sudo tee -a /etc/pf.conf > /dev/null
    echo "rdr-anchor \"com.docker.wordpress\"" | sudo tee -a /etc/pf.conf > /dev/null
    echo "load anchor \"com.docker.wordpress\" from \"$PF_ANCHOR_FILE\"" | sudo tee -a /etc/pf.conf > /dev/null

    echo "✅ Anchor reference added to /etc/pf.conf"
else
    echo "ℹ️  Anchor already exists in /etc/pf.conf"
fi

echo ""
echo "🔄 Enabling and loading pf rules..."

# Enable pf if not already enabled
if ! sudo pfctl -s info 2>/dev/null | grep -q "Status: Enabled"; then
    echo "📦 Enabling pf..."
    sudo pfctl -e 2>/dev/null || true
fi

# Load the rules
sudo pfctl -f /etc/pf.conf 2>/dev/null

echo "✅ Port forwarding enabled!"
echo ""
echo "📋 Summary:"
echo "   - Port 443 → 8443 forwarding active"
echo "   - Access your site at: https://wpdemo.local (no port needed!)"
echo ""
echo "ℹ️  To disable port forwarding:"
echo "   sudo pfctl -f /etc/pf.conf -d"
echo ""
echo "ℹ️  To remove port forwarding completely:"
echo "   ./scripts/remove-port-forwarding.sh"
