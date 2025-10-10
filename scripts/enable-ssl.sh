#!/bin/bash
# Enable SSL in Apache inside Docker container
# Run this after generating certificates with setup-ssl.sh

set -e

echo "🔒 Enabling SSL in Apache..."
echo ""

# Check if container is running
if ! docker compose ps wordpress | grep -q "Up"; then
    echo "❌ WordPress container is not running"
    echo "Start it with: docker compose up -d"
    exit 1
fi

# Check if SSL certificates exist
if [ ! -f "./ssl/cert.pem" ] || [ ! -f "./ssl/key.pem" ]; then
    echo "❌ SSL certificates not found"
    echo ""
    echo "Generate them first with:"
    echo "  ./scripts/setup-ssl.sh yourdomain.local"
    echo ""
    exit 1
fi

# Enable SSL module and site in Apache
echo "📦 Enabling Apache SSL module..."
docker compose exec wordpress a2enmod ssl
docker compose exec wordpress a2ensite default-ssl

echo ""
echo "🔄 Reloading Apache..."
docker compose exec wordpress service apache2 reload

echo ""
echo "✅ SSL enabled successfully!"
echo ""
echo "Access your site at:"
echo "  HTTP:  http://localhost:8090"
echo "  HTTPS: https://localhost:8443"
echo ""
echo "If using a .local domain, make sure:"
echo "1. DNS is configured: ./scripts/setup-local-dns.sh yourdomain.local"
echo "2. .env has HTTPS URLs"
echo ""
