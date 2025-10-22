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

# Copy local mu-plugins to container (one-way sync)
if [ -d /local-mu-plugins ]; then
    echo "Copying local mu-plugins to WordPress..."
    mkdir -p /var/www/html/wp-content/mu-plugins
    chown www-data:www-data /var/www/html/wp-content/mu-plugins
    for file in /local-mu-plugins/*; do
        if [ -e "$file" ]; then
            filename=$(basename "$file")
            if [ ! -e "/var/www/html/wp-content/mu-plugins/$filename" ]; then
                echo "  - Copying mu-plugin: $filename"
                cp -r "$file" "/var/www/html/wp-content/mu-plugins/$filename"
                chown -R www-data:www-data "/var/www/html/wp-content/mu-plugins/$filename"
            else
                echo "  - MU-plugin already exists: $filename (skipping)"
            fi
        fi
    done
fi

# Create cribops-wp-kit directory in uploads with proper permissions
if [ -d /var/www/html/wp-content/uploads ]; then
    echo "Creating cribops-wp-kit directory in uploads..."
    mkdir -p /var/www/html/wp-content/uploads/cribops-wp-kit
    chown -R www-data:www-data /var/www/html/wp-content/uploads/cribops-wp-kit
    chmod -R 775 /var/www/html/wp-content/uploads/cribops-wp-kit
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

    # Import media files if the script exists
    if [ -f /docker-entrypoint-initwp.d/import-media.sh ]; then
        echo "Running media import script..."
        /docker-entrypoint-initwp.d/import-media.sh
    fi
) &

# Execute the original entrypoint
exec docker-entrypoint.sh "$@"