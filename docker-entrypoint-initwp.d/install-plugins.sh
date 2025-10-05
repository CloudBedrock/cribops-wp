#!/bin/bash
# Auto-install WordPress, plugins, and themes

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting WordPress initialization...${NC}"

# Wait for WordPress files to be ready
echo -e "${YELLOW}Waiting for WordPress files to be ready...${NC}"
max_retries=30
counter=0
until [ -f /var/www/html/wp-config.php ]; do
    counter=$((counter+1))
    if [ $counter -gt $max_retries ]; then
        echo -e "${RED}WordPress files not ready after $max_retries attempts${NC}"
        exit 1
    fi
    echo "Waiting for WordPress files... (attempt $counter/$max_retries)"
    sleep 2
done

# Additional wait for database connection through WordPress
sleep 5
echo -e "${GREEN}WordPress files are ready!${NC}"

# Check if WordPress is already installed
if wp core is-installed --path=/var/www/html --allow-root 2>/dev/null; then
    echo -e "${YELLOW}WordPress is already installed. Skipping installation...${NC}"
else
    echo -e "${GREEN}Installing WordPress...${NC}"

    # Install WordPress
    wp core install \
        --url="${WORDPRESS_SITEURL:-http://localhost:8090}" \
        --title="${WP_SITE_TITLE:-My WordPress Site}" \
        --admin_user="${WP_ADMIN_USER:-admin}" \
        --admin_password="${WP_ADMIN_PASSWORD:-password123}" \
        --admin_email="${WP_ADMIN_EMAIL:-admin@example.com}" \
        --skip-email \
        --path=/var/www/html \
        --allow-root

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}WordPress installed successfully!${NC}"
        echo -e "${GREEN}Admin URL: ${WORDPRESS_SITEURL}/wp-admin${NC}"
        echo -e "${GREEN}Username: ${WP_ADMIN_USER:-admin}${NC}"
        echo -e "${GREEN}Password: ${WP_ADMIN_PASSWORD:-password123}${NC}"
    else
        echo -e "${RED}WordPress installation failed!${NC}"
        exit 1
    fi
fi

# Delete default WordPress plugins
echo -e "${YELLOW}Removing default WordPress plugins...${NC}"
# Remove Akismet
if wp plugin is-installed akismet --path=/var/www/html --allow-root 2>/dev/null; then
    echo -e "${GREEN}Deleting plugin: Akismet${NC}"
    wp plugin delete akismet --path=/var/www/html --allow-root
fi

# Remove Hello Dolly
if wp plugin is-installed hello --path=/var/www/html --allow-root 2>/dev/null; then
    echo -e "${GREEN}Deleting plugin: Hello Dolly${NC}"
    wp plugin delete hello --path=/var/www/html --allow-root
fi

# Install and activate custom plugins
echo -e "${YELLOW}Checking for custom plugins...${NC}"
# Check for plugins copied from local directory
for plugin_dir in /var/www/html/wp-content/plugins/*/; do
    if [ -d "$plugin_dir" ]; then
        plugin_name=$(basename "$plugin_dir")

        # Skip default WordPress plugins
        if [ "$plugin_name" != "akismet" ] && [ "$plugin_name" != "hello.php" ] && [ "$plugin_name" != "index.php" ]; then
            # Check if this is one of our local plugins
            if [ -d "/local-plugins/$plugin_name" ]; then
                # Check if plugin is already active
                if wp plugin is-active "$plugin_name" --path=/var/www/html --allow-root 2>/dev/null; then
                    echo -e "${YELLOW}Plugin '$plugin_name' is already active${NC}"
                else
                    echo -e "${GREEN}Activating plugin: $plugin_name${NC}"
                    wp plugin activate "$plugin_name" --path=/var/www/html --allow-root

                    if [ $? -eq 0 ]; then
                        echo -e "${GREEN}✓ Plugin '$plugin_name' activated successfully${NC}"
                    else
                        echo -e "${RED}✗ Failed to activate plugin '$plugin_name'${NC}"
                    fi
                fi
            fi
        fi
    fi
done

# Install and activate custom theme
echo -e "${YELLOW}Checking for custom theme...${NC}"
if [ -n "${WP_ACTIVE_THEME}" ] && [ -d "/var/www/html/wp-content/themes/${WP_ACTIVE_THEME}" ]; then
    # Check if theme is already active
    current_theme=$(wp theme list --status=active --field=name --path=/var/www/html --allow-root 2>/dev/null)

    if [ "$current_theme" = "${WP_ACTIVE_THEME}" ]; then
        echo -e "${YELLOW}Theme '${WP_ACTIVE_THEME}' is already active${NC}"
    else
        echo -e "${GREEN}Activating theme: ${WP_ACTIVE_THEME}${NC}"
        wp theme activate "${WP_ACTIVE_THEME}" --path=/var/www/html --allow-root

        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ Theme '${WP_ACTIVE_THEME}' activated successfully${NC}"
        else
            echo -e "${RED}✗ Failed to activate theme '${WP_ACTIVE_THEME}'${NC}"
        fi
    fi
else
    echo -e "${YELLOW}No custom theme specified or found${NC}"
fi

# Optional: Install additional plugins from WordPress repository
# Uncomment and modify as needed:
# echo -e "${GREEN}Installing additional plugins from WordPress repository...${NC}"
# wp plugin install contact-form-7 --activate --path=/var/www/html --allow-root
# wp plugin install wordfence --activate --path=/var/www/html --allow-root

# Set up Redis object cache if the plugin is available
if wp plugin is-installed redis-cache --path=/var/www/html --allow-root 2>/dev/null; then
    echo -e "${GREEN}Enabling Redis object cache...${NC}"
    wp plugin activate redis-cache --path=/var/www/html --allow-root
    wp redis enable --path=/var/www/html --allow-root
fi

# Activate WPVivid Backup Pro license if provided
if [ -n "${WPVIVID_LICENSE_KEY}" ] && [ "${WPVIVID_LICENSE_KEY}" != "" ]; then
    echo -e "${GREEN}Activating WPVivid Backup Pro license...${NC}"

    # WPVivid stores license in WordPress options
    wp option update wpvivid_common_setting --format=json '{"license_key":"'${WPVIVID_LICENSE_KEY}'","license_status":"active"}' --path=/var/www/html --allow-root 2>/dev/null || true

    # Also try using WP-CLI to set the option directly
    wp eval "update_option('wpvivid_license_key', '${WPVIVID_LICENSE_KEY}');" --path=/var/www/html --allow-root 2>/dev/null || true
    wp eval "update_option('wpvivid_backup_pro_license_key', '${WPVIVID_LICENSE_KEY}');" --path=/var/www/html --allow-root 2>/dev/null || true

    echo -e "${GREEN}✓ WPVivid Backup Pro license key configured${NC}"
else
    echo -e "${YELLOW}No WPVivid Backup Pro license key provided${NC}"
fi

# Activate WPVivid Database Merge license if provided
if [ -n "${WPVIVID_DBMERGE_LICENSE_KEY}" ] && [ "${WPVIVID_DBMERGE_LICENSE_KEY}" != "" ]; then
    echo -e "${GREEN}Activating WPVivid Database Merge license...${NC}"

    # Set the database merge license key in WordPress options
    wp eval "update_option('wpvivid_dbmerge_license_key', '${WPVIVID_DBMERGE_LICENSE_KEY}');" --path=/var/www/html --allow-root 2>/dev/null || true
    wp eval "update_option('wpvivid_database_merge_license_key', '${WPVIVID_DBMERGE_LICENSE_KEY}');" --path=/var/www/html --allow-root 2>/dev/null || true

    # Also try the common setting format
    wp option update wpvivid_dbmerge_setting --format=json '{"license_key":"'${WPVIVID_DBMERGE_LICENSE_KEY}'","license_status":"active"}' --path=/var/www/html --allow-root 2>/dev/null || true

    echo -e "${GREEN}✓ WPVivid Database Merge license key configured${NC}"
else
    echo -e "${YELLOW}No WPVivid Database Merge license key provided${NC}"
fi

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}WordPress initialization complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Site URL: ${WORDPRESS_SITEURL:-http://localhost:8090}${NC}"
echo -e "${GREEN}Admin URL: ${WORDPRESS_SITEURL:-http://localhost:8090}/wp-admin${NC}"
echo -e "${GREEN}========================================${NC}"