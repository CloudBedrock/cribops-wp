# WordPress Plugin Development Setup

## How to Use

### 1. Set Custom Hostname

Create a `.env` file based on `.env.example`:

```bash
cp .env.example .env
```

Edit `.env` to set your custom hostname:

```env
WORDPRESS_SITEURL=http://mysite.local:8090
WORDPRESS_HOME=http://mysite.local:8090
```

Add the hostname to your `/etc/hosts` file:

```bash
sudo echo "127.0.0.1 mysite.local" >> /etc/hosts
```

### 2. Add Local Plugins

Place your plugin directories in the `plugins/` folder:

```plaintext
plugins/
├── my-custom-plugin/
│   ├── my-custom-plugin.php
│   └── ...
└── another-plugin/
    └── ...
```

### 3. Start the Environment

```bash
docker compose up -d
```

Your plugins will be:

- Mounted at `/wp-content/plugins/custom/[plugin-name]`
- Auto-activated when WordPress starts (if the init script detects WP-CLI)

### 4. Manual Plugin Management

If auto-activation doesn't work with your image, you can manually activate plugins:

```bash
# Enter the WordPress container
docker compose exec wordpress bash

# Activate a plugin
wp plugin activate custom/my-custom-plugin --allow-root

# Or activate through WordPress admin at [http://localhost:8090/wp-admin](http://localhost:8090/wp-admin)
```

## Directory Structure

```plaintext
mwp/
├── compose.yml
├── .env
├── plugins/           # Your local plugin development
│   └── my-plugin/
├── themes/           # Your local theme development (optional)
│   └── my-theme/
└── docker-entrypoint-initwp.d/
    └── install-plugins.sh  # Auto-installation script
```

## Notes

- Plugins in `plugins/` are mounted as read-write, so you can develop directly
- Changes to plugin files are immediately reflected in WordPress
- The init script requires WP-CLI to be available in the container image
- If your image doesn't support init scripts, you can manually activate plugins through wp-admin
