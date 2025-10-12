# Quick Start Guide

Get your WordPress development environment running in under 2 minutes.

## First-Time Setup

### Prerequisites
- Docker Desktop installed and running
- macOS with Homebrew (recommended) or mkcert installed manually

### One-Command Setup

```bash
./scripts/first-run-setup.sh
```

This will:
1. ✅ Check prerequisites (Docker, mkcert)
2. 🔐 Generate SSL certificates
3. 🌐 Configure local DNS (/etc/hosts)
4. ⚙️  Verify .env configuration
5. 🚀 Start Docker containers
6. ⏳ Wait for WordPress initialization
7. 🔒 Enable SSL in Apache

### Custom Domain

```bash
./scripts/first-run-setup.sh mysite.local
```

## Access Your Site

- **HTTPS (recommended):** https://wpdemo.local:8443
- **HTTP:** http://localhost:8007
- **Admin Panel:** https://wpdemo.local:8443/wp-admin

Default credentials are in your `.env` file.

## Daily Usage

### Start Environment
```bash
docker compose up -d
```

### Stop Environment
```bash
docker compose down
```

### View Logs
```bash
docker compose logs -f wordpress
```

### Restart After Plugin/Theme Changes
```bash
docker compose restart wordpress
```

## Development Tools

### Email Testing (MailPit)
```bash
docker compose --profile mailpit up -d
```
Access at: http://localhost:8025

### Public Tunnel (ngrok)

**Start ngrok:**
```bash
docker compose --profile ngrok up -d
```

**Get your public URL:**

Option 1 - Web Dashboard:
```bash
open http://localhost:4040
```

Option 2 - Command Line:
```bash
curl -s http://localhost:4040/api/tunnels | grep -o 'https://[^"]*\.ngrok-free\.dev'
```

**Update WordPress to use ngrok URL:**
```bash
# Replace with your actual ngrok URL from above
NGROK_URL="https://your-subdomain.ngrok-free.dev"

docker compose exec wordpress wp option update siteurl "$NGROK_URL" --path=/var/www/html --allow-root
docker compose exec wordpress wp option update home "$NGROK_URL" --path=/var/www/html --allow-root
```

**For paid ngrok accounts with custom domains:**

1. Set your reserved domain in `compose.yml`:

```yaml
ngrok:
  command:
    - "http"
    - "wordpress:80"
    - "--domain=your-custom-domain.ngrok.app"
```

Your URL will always be: `https://your-custom-domain.ngrok.app`

**Switch back to local development:**
```bash
docker compose exec wordpress wp option update siteurl "https://wpdemo.local:8443" --path=/var/www/html --allow-root
docker compose exec wordpress wp option update home "https://wpdemo.local:8443" --path=/var/www/html --allow-root
```

## Troubleshooting

### SSL Not Working
```bash
./scripts/enable-ssl.sh
```

### Complete Reset
```bash
docker compose down -v
./scripts/first-run-setup.sh
```

### Check WordPress Status
```bash
docker compose exec wordpress wp core is-installed --path=/var/www/html --allow-root
```

## Next Steps

1. Add plugins to `plugins/` directory
2. Add themes to `themes/` directory
3. Restart container: `docker compose restart wordpress`
4. Customize `.env` with your settings

See [CLAUDE.md](CLAUDE.md) for complete documentation.
