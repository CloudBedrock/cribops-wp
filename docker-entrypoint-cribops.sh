#!/bin/bash
set -euo pipefail

# Process WORDPRESS_CONFIG_EXTRA environment variable
if [ -n "${WORDPRESS_CONFIG_EXTRA:-}" ] && [ -f /var/www/html/wp-config.php ]; then
    echo "Processing WORDPRESS_CONFIG_EXTRA..."

    # Check if the configuration is already in wp-config.php
    if ! grep -q "WP_REDIS_CONFIG" /var/www/html/wp-config.php 2>/dev/null; then
        echo "Adding Object Cache Pro configuration to wp-config.php..."

        # Create a temporary file with the configuration
        echo "$WORDPRESS_CONFIG_EXTRA" > /tmp/wp-config-extra.php

        # Insert the configuration before "That's all, stop editing!"
        # Use a more robust sed command
        cp /var/www/html/wp-config.php /var/www/html/wp-config.php.tmp

        # Find the line with "That's all, stop editing!" and insert before it
        awk '/\/\* That.s all, stop editing!/ {
            while ((getline line < "/tmp/wp-config-extra.php") > 0) {
                print line
            }
            close("/tmp/wp-config-extra.php")
        }
        {print}' /var/www/html/wp-config.php.tmp > /var/www/html/wp-config.php

        rm -f /var/www/html/wp-config.php.tmp /tmp/wp-config-extra.php
        echo "Configuration added successfully."
    else
        echo "Object Cache Pro configuration already present in wp-config.php"
    fi
fi

# Call the original WordPress entrypoint
exec docker-entrypoint.sh "$@"