#!/bin/bash
# Complete first-run setup for WordPress development environment
# This script handles SSL certificates, DNS, and container startup

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  WordPress Development Environment - First Run Setup  ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# Prompt for domain if not provided as argument
if [ -z "$1" ]; then
    echo -e "${BLUE}Enter your local domain name${NC}"
    echo -e "   Must use .local TLD (e.g., mysite.local, wpdemo.local)"
    echo ""
    read -p "   Domain [wpdemo.local]: " DOMAIN
    DOMAIN="${DOMAIN:-wpdemo.local}"
    echo ""
else
    DOMAIN="$1"
fi

# Validate .local TLD
if [[ ! "$DOMAIN" =~ \.local$ ]]; then
    echo -e "${RED}❌ Error: Domain must use .local TLD${NC}"
    echo -e "   Example: mysite.local, dev.local, wpdemo.local"
    echo ""
    exit 1
fi

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${YELLOW}⚠️  This script is optimized for macOS${NC}"
    echo -e "${YELLOW}   Some steps may require manual configuration on other systems${NC}"
    echo ""
fi

# Change to project directory
cd "$PROJECT_DIR"

# Step 1: Check prerequisites
echo -e "${BLUE}[1/7]${NC} Checking prerequisites..."
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker is not installed${NC}"
    echo "   Please install Docker Desktop from https://www.docker.com/products/docker-desktop"
    exit 1
fi

if ! command -v mkcert &> /dev/null; then
    echo -e "${YELLOW}⚠️  mkcert is not installed${NC}"
    echo "   Installing mkcert via Homebrew..."
    if command -v brew &> /dev/null; then
        brew install mkcert
        mkcert -install
    else
        echo -e "${RED}❌ Homebrew is not installed${NC}"
        echo "   Please install mkcert manually from https://github.com/FiloSottile/mkcert"
        exit 1
    fi
fi
echo -e "${GREEN}✅ Prerequisites satisfied${NC}"
echo ""

# Step 2: Generate SSL certificates
echo -e "${BLUE}[2/7]${NC} Generating SSL certificates for ${DOMAIN}..."
if [ -f "./ssl/cert.pem" ] && [ -f "./ssl/key.pem" ]; then
    echo -e "${GREEN}✅ SSL certificates already exist (using existing)${NC}"
else
    "$SCRIPT_DIR/setup-ssl.sh" "$DOMAIN"
fi
echo ""

# Step 3: Configure local DNS
echo -e "${BLUE}[3/7]${NC} Configuring local DNS (/etc/hosts)..."
if grep -q "$DOMAIN" /etc/hosts 2>/dev/null; then
    echo -e "${GREEN}✅ DNS already configured${NC}"
else
    echo -e "${YELLOW}   This requires sudo access${NC}"
    "$SCRIPT_DIR/setup-local-dns.sh" "$DOMAIN"
fi
echo ""

# Step 4: Verify .env configuration
echo -e "${BLUE}[4/7]${NC} Verifying .env configuration..."
if [ ! -f ".env" ]; then
    echo -e "${RED}❌ .env file not found${NC}"
    echo "   Please create .env from .env.example"
    exit 1
fi

# Check if .env has correct URLs
if grep -q "WORDPRESS_SITEURL=https://${DOMAIN}:8443" .env; then
    echo -e "${GREEN}✅ .env configured correctly${NC}"
else
    echo -e "${YELLOW}⚠️  .env may need URL updates${NC}"
    echo "   Expected: WORDPRESS_SITEURL=https://${DOMAIN}:8443"
    echo "   Expected: WORDPRESS_HOME=https://${DOMAIN}:8443"
fi
echo ""

# Step 5: Start Docker containers
echo -e "${BLUE}[5/7]${NC} Starting Docker containers..."
docker compose up -d
echo -e "${GREEN}✅ Containers started${NC}"
echo ""

# Step 6: Wait for WordPress to be ready
echo -e "${BLUE}[6/7]${NC} Waiting for WordPress to initialize..."

# First, wait for database to be ready
echo -n "   Waiting for database"
for i in {1..30}; do
    if docker compose exec db mysqladmin ping -h localhost -u wordpress -pwordpress --silent >/dev/null 2>&1; then
        echo -e " ${GREEN}✓${NC}"
        break
    fi
    echo -n "."
    sleep 2
done

# Then wait for WordPress to be installed
echo -n "   Waiting for WordPress"
for i in {1..30}; do
    if docker compose exec wordpress wp core is-installed --path=/var/www/html --allow-root >/dev/null 2>&1; then
        echo -e " ${GREEN}✓${NC}"
        echo -e "${GREEN}✅ WordPress is ready${NC}"
        break
    fi
    echo -n "."
    sleep 2
done
echo ""

# Step 7: Enable SSL in Apache
echo -e "${BLUE}[7/7]${NC} Enabling SSL in Apache..."
"$SCRIPT_DIR/enable-ssl.sh"
echo ""

# Final summary
echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║              Setup Complete! 🎉                         ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Access your WordPress site:${NC}"
echo -e "  • HTTP:  http://localhost:8007"
echo -e "  • HTTPS: https://${DOMAIN}:8443"
echo ""
echo -e "${BLUE}Admin credentials:${NC}"
echo -e "  • Check your .env file for WP_ADMIN_USER and WP_ADMIN_PASSWORD"
echo ""
echo -e "${BLUE}Useful commands:${NC}"
echo -e "  • View logs:       ${YELLOW}docker compose logs -f wordpress${NC}"
echo -e "  • Restart:         ${YELLOW}docker compose restart wordpress${NC}"
echo -e "  • Stop:            ${YELLOW}docker compose down${NC}"
echo -e "  • Complete reset:  ${YELLOW}docker compose down -v${NC}"
echo ""
echo -e "${BLUE}Development tools (optional):${NC}"
echo -e "  • MailPit:         ${YELLOW}docker compose --profile mailpit up -d${NC}"
echo -e "  • ngrok:           ${YELLOW}docker compose --profile ngrok up -d${NC}"
echo ""
echo -e "${GREEN}Opening WordPress in your browser...${NC}"
sleep 2
if command -v open &> /dev/null; then
    open "https://${DOMAIN}:8443"
fi
