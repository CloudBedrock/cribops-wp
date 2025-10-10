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

# Fix ownership issues: ensure all wp-content directories are owned by www-data
# This prevents "Failed to move downloaded file" errors when plugins try to create/move files
echo -e "${GREEN}Fixing wp-content ownership...${NC}"
chown -R www-data:www-data /var/www/html/wp-content/uploads 2>/dev/null || true

# Pre-create the cribops-wp-kit directory with correct ownership
mkdir -p /var/www/html/wp-content/uploads/cribops-wp-kit
chown -R www-data:www-data /var/www/html/wp-content/uploads/cribops-wp-kit 2>/dev/null || true
chmod -R 755 /var/www/html/wp-content/uploads/cribops-wp-kit 2>/dev/null || true
echo -e "${GREEN}✓ Upload directories ownership fixed${NC}"

# Install cribops-wp-kit from GitHub if not present
echo -e "${YELLOW}Checking for cribops-wp-kit plugin...${NC}"
if [ ! -d "/var/www/html/wp-content/plugins/cribops-wp-kit" ]; then
    echo -e "${GREEN}Downloading cribops-wp-kit from GitHub...${NC}"

    # Get the latest release download URL
    LATEST_RELEASE=$(curl -s https://api.github.com/repos/CloudBedrock/cribops-wp-kit/releases/latest | grep "zipball_url" | cut -d '"' -f 4)

    if [ -n "$LATEST_RELEASE" ]; then
        echo -e "${GREEN}Found latest release, downloading...${NC}"

        # Download and extract the plugin
        cd /tmp
        curl -L -o cribops-wp-kit.zip "$LATEST_RELEASE"
        unzip -q cribops-wp-kit.zip

        # Find the extracted directory (GitHub creates a dir with format: CloudBedrock-cribops-wp-kit-{commit})
        EXTRACTED_DIR=$(find /tmp -maxdepth 1 -type d -name "CloudBedrock-cribops-wp-kit-*" | head -n 1)

        if [ -n "$EXTRACTED_DIR" ]; then
            # Move to plugins directory
            mv "$EXTRACTED_DIR" /var/www/html/wp-content/plugins/cribops-wp-kit
            chown -R www-data:www-data /var/www/html/wp-content/plugins/cribops-wp-kit
            echo -e "${GREEN}✓ cribops-wp-kit installed successfully${NC}"
        else
            echo -e "${RED}✗ Failed to extract cribops-wp-kit${NC}"
        fi

        # Cleanup
        rm -f /tmp/cribops-wp-kit.zip
    else
        echo -e "${YELLOW}Could not fetch latest release, attempting to clone from main branch...${NC}"

        # Fallback to cloning the repository
        git clone --depth 1 https://github.com/CloudBedrock/cribops-wp-kit.git /var/www/html/wp-content/plugins/cribops-wp-kit

        if [ $? -eq 0 ]; then
            chown -R www-data:www-data /var/www/html/wp-content/plugins/cribops-wp-kit
            # Remove .git directory to save space
            rm -rf /var/www/html/wp-content/plugins/cribops-wp-kit/.git
            echo -e "${GREEN}✓ cribops-wp-kit cloned successfully${NC}"
        else
            echo -e "${RED}✗ Failed to install cribops-wp-kit${NC}"
        fi
    fi
else
    echo -e "${YELLOW}cribops-wp-kit already installed${NC}"
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

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}WordPress initialization complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Site URL: ${WORDPRESS_SITEURL:-http://localhost:8090}${NC}"
echo -e "${GREEN}Admin URL: ${WORDPRESS_SITEURL:-http://localhost:8090}/wp-admin${NC}"
echo -e "${GREEN}========================================${NC}"