# CribOps WordPress Docker Environment

Production-ready WordPress Docker image and complete development environment with automatic installation, plugin/theme management, and Redis support.

## 🚀 Features

### Docker Image Features
- **WordPress (latest) with PHP 8.3** and Apache
- **Redis PHP Extension** with igbinary and zstd compression
- **APCu** for local object caching
- **Optimized PHP Settings**:
  - 512MB file uploads (configurable)
  - 600s execution time
  - 512MB memory limit
  - 10,000 input vars
- **Object Cache Pro Ready** with full feature support
- **Multi-architecture**: Supports both AMD64 and ARM64
- **WP-CLI** pre-installed

### Docker Compose Environment Features
- 🎯 **Automatic WordPress Installation** - WordPress automatically installed with credentials from `.env`
- 🔌 **Plugin & Theme Management** - Local plugins/themes automatically copied and activated
- 💾 **Redis Object Caching** - Built-in Redis support for improved performance
- 🔑 **License Key Management** - Support for WPVivid and other plugin licenses via environment variables
- 🛡️ **Source Protection** - One-way sync prevents WordPress from modifying your local files
- 📊 **PHP Info Page** - Built-in phpinfo page for debugging
- 🔄 **Auto-activation** - Plugins and themes automatically activated on startup

### Development Tools (Optional)
- 📧 **MailPit** - SMTP email testing with web UI (no real emails sent)
- 🌐 **ngrok** - Secure tunneling for sharing local sites remotely
- 🔒 **SSL Support** - Ready for HTTPS development with self-signed certificates

## Quick Start

### Using Docker Compose (Recommended for Development)

1. **Clone this repository**
   ```bash
   git clone https://github.com/CloudBedrock/cribops-wp.git
   cd cribops-wp
   ```

2. **Create your configuration files**
   ```bash
   cp .env.example .env
   cp compose.yml.example compose.yml
   # Edit .env and compose.yml with your settings
   ```

3. **Add your plugins and themes**
   - Place plugins in `plugins/` directory
   - Place themes in `themes/` directory

4. **Start the environment**
   ```bash
   docker compose up -d
   ```

5. **Access WordPress**
   - Site URL: Configured in `.env` (default: http://localhost:8080)
   - Admin URL: /wp-admin
   - Credentials: Configured in `.env`

### Using Docker Image Directly

```bash
# Pull from Docker Hub
docker pull cloudbedrock/cribops-wp:latest

# Or pull from GitHub Container Registry
docker pull ghcr.io/cloudbedrock/cribops-wp:latest
```

## Environment Configuration (.env)

```env
# WordPress Site Configuration
WORDPRESS_SITEURL=https://your-site.com
WORDPRESS_HOME=https://your-site.com

# WordPress Admin Configuration
WP_ADMIN_USER=admin
WP_ADMIN_PASSWORD=secure-password
WP_ADMIN_EMAIL=admin@example.com
WP_SITE_TITLE="My WordPress Site"

# Theme Configuration (folder name in themes/)
WP_ACTIVE_THEME=your-theme-name

# Plugin License Keys
WPVIVID_LICENSE_KEY=your-backup-pro-license
WPVIVID_DBMERGE_LICENSE_KEY=your-database-merge-license

# Additional WordPress Constants
WP_CONFIG_EXTRA="
define('WS_FORM_LICENSE_KEY', 'your-license');
define('CUSTOM_CONSTANT', 'value');
"

# Upload and Memory Limits
MAX_UPLOAD_SIZE=512M
PHP_MEMORY_LIMIT=512M
PHP_MAX_EXECUTION_TIME=600

# Debug Configuration
WP_DEBUG=false
WP_DEBUG_LOG=false
WP_DEBUG_DISPLAY=false
```

## How It Works

### Automatic Installation Flow
1. Database waits for MySQL to be ready
2. WordPress is installed with your `.env` credentials
3. Local plugins are copied and activated
4. Configured theme is activated
5. Redis cache is configured
6. License keys are applied

### One-Way Plugin/Theme Sync
Your local `plugins/` and `themes/` directories are:
1. Mounted as read-only to temporary locations
2. Copied into WordPress on container startup
3. Automatically activated based on `.env` settings
4. Protected from modifications by WordPress

Benefits:
- ✅ Source files are never modified by WordPress
- ✅ Can still upload plugins through WordPress admin
- ✅ WordPress updates work normally
- ✅ Just restart container to sync local changes

## Architecture

### Services

1. **WordPress** (Port 8080, HTTPS 8443)
   - Image: cloudbedrock/cribops-wp:latest
   - PHP 8.3 with Apache
   - WP-CLI pre-installed
   - Auto-installation on first run

2. **MySQL 8.0** (Port 3306)
   - Database: wordpress
   - User: wordpress
   - Password: wordpress
   - Persistent storage

3. **Redis 7** (Internal)
   - Object caching
   - Persistent with AOF
   - Auto-configured

### File Structure

```
cribops-wp/
├── compose.yml.example              # Docker Compose template
├── compose.yml                      # Your Docker config (not in git)
├── .env.example                     # Environment template
├── .env                            # Your configuration (not in git)
├── docker-entrypoint-wrapper.sh    # Custom entrypoint
├── docker-entrypoint-initwp.d/     # Initialization scripts
│   └── install-plugins.sh          # Auto-installation script
├── php-uploads.ini                 # PHP configuration
├── phpinfo.php                     # PHP info page
├── plugins/                        # Your local plugins
│   ├── plugin-one/
│   └── plugin-two/
├── themes/                         # Your local themes
│   └── your-theme/
├── Dockerfile                      # Custom build (optional)
└── CLAUDE.md                       # AI assistant instructions
```

## Development Tools

### MailPit - Email Testing

MailPit captures all emails sent from WordPress so you can test email functionality without sending real emails.

```bash
# Start MailPit
docker compose --profile mailpit up -d

# Access MailPit Web UI
open http://localhost:8025
```

**Configuration:**
- SMTP Host: `mailpit` (from within WordPress container)
- SMTP Port: `1025`
- Web UI: http://localhost:8025

Use an SMTP plugin like [WP Mail SMTP](https://wordpress.org/plugins/wp-mail-smtp/) to configure WordPress to use MailPit.

### ngrok - Secure Tunneling

Share your local WordPress site with clients or test webhooks from external services.

```bash
# Set your ngrok auth token in .env
NGROK_AUTHTOKEN=your_token_here

# Start ngrok
docker compose --profile ngrok up -d

# Get your public URL
open http://localhost:4040
```

Your local site will be accessible at a public ngrok URL (e.g., `https://abc123.ngrok.io`).

**WordPress Integration:**
- Visit the "Development Tools" page in CribOps WP-Kit admin to get the current ngrok URL
- Copy the URL for sharing with clients or testing webhooks

### SSL Certificates - Local HTTPS Development

Develop with trusted HTTPS connections using self-signed certificates.

**Quick Setup (Recommended):**

```bash
# One-command setup (requires mkcert)
./scripts/setup-ssl-complete.sh mysite.local
```

This will:
1. Check if mkcert is installed
2. Generate SSL certificates
3. Add domain to /etc/hosts
4. Show you the next steps

Then follow the printed instructions to:
- Update your .env with the domain
- Start Docker containers
- Enable SSL in Apache
- Access at https://mysite.local:8443

**Manual Setup:**

**Requirements:**
- [mkcert](https://github.com/FiloSottile/mkcert) - Install with `brew install mkcert nss`

**Steps:**

1. **Run the complete setup script**
   ```bash
   ./scripts/setup-ssl-complete.sh mysite.local
   ```

2. **Update .env Configuration**
   ```env
   SERVER_NAME=mysite.local
   WORDPRESS_SITEURL=https://mysite.local:8443
   WORDPRESS_HOME=https://mysite.local:8443
   ```

3. **Start Containers**
   ```bash
   docker compose up -d
   ```

4. **Enable SSL in Apache**
   ```bash
   ./scripts/enable-ssl.sh
   ```

5. **Access Your Site**
   - HTTPS: https://mysite.local:8443
   - HTTP: http://mysite.local:8090

**Advanced: Use Port 443 (Optional)**

If you want to access via standard port 443 (`https://mysite.local` instead of `:8443`):

```bash
# Setup port forwarding (macOS only)
./scripts/setup-port-forwarding.sh

# Update .env to remove port
WORDPRESS_SITEURL=https://mysite.local
WORDPRESS_HOME=https://mysite.local

# Restart
docker compose restart wordpress
```

Remove with: `./scripts/remove-port-forwarding.sh`

### Running Multiple Development Tools

```bash
# Start WordPress with MailPit and ngrok
docker compose --profile mailpit --profile ngrok up -d

# Stop development tools
docker compose --profile mailpit --profile ngrok down
```

## Common Commands

### Container Management
```bash
# Start environment
docker compose up -d

# Stop environment
docker compose down

# Restart to sync local changes
docker compose restart wordpress

# View logs
docker compose logs -f wordpress

# Remove everything (including data)
docker compose down -v
```

### WP-CLI Commands
```bash
# List users
docker compose exec wordpress wp user list --path=/var/www/html --allow-root

# Reset password
docker compose exec wordpress wp user update USERNAME --user_pass="newpass" --path=/var/www/html --allow-root

# List plugins
docker compose exec wordpress wp plugin list --path=/var/www/html --allow-root

# Activate plugin
docker compose exec wordpress wp plugin activate plugin-name --path=/var/www/html --allow-root

# Clear cache
docker compose exec wordpress wp cache flush --path=/var/www/html --allow-root
```

## PHP Extensions Included

- **Core**: opcache, zip, gd, intl, mysqli, pdo_mysql
- **Caching**: redis, igbinary, apcu
- **Performance**: bcmath, sockets, exif
- **Images**: imagick, gd
- **Compression**: zstd

## PHP Configuration

| Setting | Value | Description |
|---------|-------|-------------|
| upload_max_filesize | 512M | Maximum upload file size |
| post_max_size | 512M | Maximum POST data size |
| max_execution_time | 600 | Maximum script execution time (10 minutes) |
| memory_limit | 512M | PHP memory limit |
| max_input_vars | 10000 | Maximum input variables |
| max_file_uploads | 50 | Maximum concurrent file uploads |

## Troubleshooting

### Port Conflicts
If ports 8080 or 3306 are in use (e.g., Laravel Herd):
1. Stop the conflicting service, or
2. Change ports in your local `compose.yml`

### Plugins Not Activating
1. Check plugin folder name matches exactly
2. Verify plugin file structure
3. Check logs: `docker compose logs wordpress`

### Database Connection Issues
```bash
# Test connection
docker compose exec wordpress wp db check --path=/var/www/html --allow-root

# Check database logs
docker compose logs db
```

### PHP Configuration Check
Access PHP info at: `http://your-site/phpinfo.php`

### Reset Everything
```bash
# Stop and remove all containers and volumes
docker compose down -v

# Start fresh
docker compose up -d
```

## Security Notes

- **Remove `phpinfo.php` in production**
- **Use strong passwords in `.env`**
- **Never commit `.env` to version control**
- **Keep license keys secure**
- **Change default database passwords for production**
- **Update WordPress and plugins regularly**

## Building Custom Image

```bash
# Build with custom modifications
docker build -t cribops-wp:custom .

# Use in compose.yml
# Change: image: cloudbedrock/cribops-wp:latest
# To: image: cribops-wp:custom
```

## Tags

- `latest`, `php8.3-redis` - Latest stable build with PHP 8.3
- `vX.Y.Z` - Specific version releases
- `main-<sha>` - Development builds from main branch

## Support

For issues and feature requests, please visit: https://github.com/CloudBedrock/cribops-wp/issues

## License

This Docker configuration is open source and available under the MIT License.

## Credits

Maintained by [CloudBedrock / CribOps](https://cribops.com) for the CribOps platform.