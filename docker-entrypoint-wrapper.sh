#!/bin/bash
# Custom entrypoint wrapper that runs initialization scripts

echo "Starting custom entrypoint wrapper..."

# Copy local plugins to container (one-way sync)
if [ -d /local-plugins ]; then
    echo "Copying local plugins to WordPress..."
    for plugin_dir in /local-plugins/*/; do
        if [ -d "$plugin_dir" ]; then
            plugin_name=$(basename "$plugin_dir")
            if [ ! -d "/var/www/html/wp-content/plugins/$plugin_name" ]; then
                echo "  - Copying plugin: $plugin_name"
                cp -r "$plugin_dir" "/var/www/html/wp-content/plugins/$plugin_name"
                chown -R www-data:www-data "/var/www/html/wp-content/plugins/$plugin_name"
            else
                echo "  - Plugin already exists: $plugin_name (skipping)"
            fi
        fi
    done
fi

# Copy local themes to container (one-way sync)
if [ -d /local-themes ]; then
    echo "Copying local themes to WordPress..."
    for theme_dir in /local-themes/*/; do
        if [ -d "$theme_dir" ]; then
            theme_name=$(basename "$theme_dir")
            if [ ! -d "/var/www/html/wp-content/themes/$theme_name" ]; then
                echo "  - Copying theme: $theme_name"
                cp -r "$theme_dir" "/var/www/html/wp-content/themes/$theme_name"
                chown -R www-data:www-data "/var/www/html/wp-content/themes/$theme_name"
            else
                echo "  - Theme already exists: $theme_name (skipping)"
            fi
        fi
    done
fi

# Run the initialization script in the background after a delay
(
    # Wait for Apache and WordPress to be ready
    sleep 15

    # Run our custom initialization script if it exists
    if [ -f /docker-entrypoint-initwp.d/install-plugins.sh ]; then
        echo "Running WordPress initialization script..."
        /docker-entrypoint-initwp.d/install-plugins.sh
    fi
) &

# Execute the original entrypoint
exec docker-entrypoint.sh "$@"