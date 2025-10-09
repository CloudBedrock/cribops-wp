#!/bin/bash
set -e

# Ensure uploads directory exists with proper permissions
echo "Setting up WordPress uploads directory..."

# Create base uploads directory
mkdir -p /var/www/html/wp-content/uploads

# Create current year/month subdirectory
YEAR=$(date +%Y)
MONTH=$(date +%m)
mkdir -p "/var/www/html/wp-content/uploads/${YEAR}/${MONTH}"

# Set proper ownership for all uploads
chown -R www-data:www-data /var/www/html/wp-content/uploads

# Set proper permissions (775 for directories, 664 for files)
find /var/www/html/wp-content/uploads -type d -exec chmod 775 {} \;
find /var/www/html/wp-content/uploads -type f -exec chmod 664 {} \; 2>/dev/null || true

# Ensure plugins directory has correct permissions
if [ -d /var/www/html/wp-content/plugins ]; then
    chown -R www-data:www-data /var/www/html/wp-content/plugins
    find /var/www/html/wp-content/plugins -type d -exec chmod 755 {} \;
    find /var/www/html/wp-content/plugins -type f -exec chmod 644 {} \;
fi

echo "WordPress directory permissions configured successfully"

# Execute the original entrypoint
exec docker-php-entrypoint "$@"