# CribOps WordPress Docker Environment

Production-ready WordPress Docker image and complete development environment with automatic installation, plugin/theme management, and Redis support.

## Features

### Docker Image Features

- **WordPress (latest) with PHP 8.3** and Apache
- **Redis PHP Extension** with igbinary and zstd compression
- **APCu** for local object caching
- **Optimized PHP Settings** (512MB uploads, 600s execution, 512MB memory)
- **Object Cache Pro Ready** with full feature support
- **Multi-architecture**: AMD64 and ARM64 support
- **WP-CLI** pre-installed

### Docker Compose Environment Features

- 🎯 **Automatic WordPress Installation** with credentials from `.env`
- 🔌 **Plugin & Theme Management** with one-way sync protection
- 💾 **Redis Object Caching** for improved performance
- 🔑 **License Key Management** via environment variables
- 📧 **MailPit** for email testing (optional)
- 🌐 **ngrok** for secure tunneling (optional)
- 🔒 **SSL Support** for HTTPS development

## Quick Start

### One-Command Setup

```bash
./scripts/first-run-setup.sh
```

Your WordPress site will be running in under 2 minutes! This command handles SSL certificates, DNS configuration, and container startup automatically.

**See [QUICK_START.md](QUICK_START.md) for the complete setup guide and daily usage instructions.**

## Local Development

Want to edit plugins/themes with VSCode or Cursor? See [LOCAL-EDITING.md](LOCAL-EDITING.md) for:

- **Development Mode**: Direct two-way bind mounts for instant code changes
- **Production Mode**: One-way sync (default) for deployment testing
- Switching between modes and troubleshooting

**Quick Start for Local Editing:**

```bash
# Start in development mode (instant two-way sync)
docker compose -f compose.yml -f compose.dev.yml up -d

# Edit files in plugins/, themes/, or mu-plugins/ with your editor
# Changes appear instantly in WordPress!
```

## Using Docker Image Directly

```bash
# Pull from Docker Hub
docker pull cloudbedrock/cribops-wp:latest

# Or from GitHub Container Registry
docker pull ghcr.io/cloudbedrock/cribops-wp:latest
```

## Environment Configuration

Copy `.env.example` to `.env` and customize:

```env
# WordPress Site
WORDPRESS_SITEURL=https://wpdemo.local:8443
WORDPRESS_HOME=https://wpdemo.local:8443

# Admin Credentials
WP_ADMIN_USER=admin
WP_ADMIN_PASSWORD=secure-password
WP_ADMIN_EMAIL=admin@example.com

# Theme (folder name in themes/)
WP_ACTIVE_THEME=your-theme-name

# Plugin Licenses
WPVIVID_LICENSE_KEY=your-license
WP_CONFIG_EXTRA="
define('CUSTOM_CONSTANT', 'value');
"

# PHP Limits
MAX_UPLOAD_SIZE=512M
PHP_MEMORY_LIMIT=512M
```

## How It Works

### Automatic Installation

1. WordPress is installed with your `.env` credentials
2. Local plugins/themes are copied and activated
3. Redis cache is configured automatically
4. License keys are applied

### One-Way Plugin/Theme Sync

Your `plugins/` and `themes/` directories are:

- Mounted read-only and copied on startup
- Protected from WordPress modifications
- Synced when container restarts

## Project Structure

```text
cribops-wp/
├── compose.yml                      # Docker configuration
├── .env                            # Your settings
├── plugins/                        # Your plugins
├── themes/                         # Your themes
├── scripts/                        # Setup utilities
│   ├── first-run-setup.sh         # Quick setup
│   └── enable-ssl.sh              # SSL activation
└── docker-entrypoint-initwp.d/    # Init scripts
```

## Development Tools

### MailPit - Email Testing

```bash
docker compose --profile mailpit up -d
# Access at: http://localhost:8025
```

### ngrok - Public Tunneling

```bash
docker compose --profile ngrok up -d
# Dashboard at: http://localhost:4040
```

**See [QUICK_START.md](QUICK_START.md) for detailed ngrok setup and URL management.**

## Common Commands

### Container Management

```bash
docker compose up -d              # Start
docker compose down               # Stop
docker compose restart wordpress  # Sync plugins/themes
docker compose logs -f wordpress  # View logs
docker compose down -v           # Reset everything
```

### WP-CLI

```bash
# All commands require: --path=/var/www/html --allow-root
docker compose exec wordpress wp user list --path=/var/www/html --allow-root
docker compose exec wordpress wp plugin list --path=/var/www/html --allow-root
```

## PHP Extensions & Configuration

### Extensions

Core, caching (Redis, APCu), performance (OPcache), image processing (ImageMagick, GD), compression (zstd)

### Settings

- Upload: 512MB max
- Execution: 600 seconds
- Memory: 512MB
- Input vars: 10,000

## Documentation

- **[QUICK_START.md](QUICK_START.md)** - Setup guide and daily usage
- **[CLAUDE.md](CLAUDE.md)** - AI assistant instructions and advanced usage
- **[Docker Hub](https://hub.docker.com/r/cloudbedrock/cribops-wp)** - Image documentation

## Troubleshooting

Common issues and solutions are covered in [QUICK_START.md](QUICK_START.md#troubleshooting).

For advanced troubleshooting and WP-CLI commands, see [CLAUDE.md](CLAUDE.md).

## Security

- Remove `phpinfo.php` in production
- Use strong passwords in `.env`
- Never commit `.env` to version control
- Keep WordPress and plugins updated

## Support

Issues and feature requests: [GitHub Issues](https://github.com/CloudBedrock/cribops-wp/issues)

## License

GPL-2.0-or-later (matching WordPress). See [LICENSE](LICENSE).

## Credits

Maintained by [CloudBedrock / CribOps](https://cribops.com)