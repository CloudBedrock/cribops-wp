# syntax=docker/dockerfile:1
FROM --platform=$BUILDPLATFORM wordpress:latest

# Install image optimization tools for EWWW Image Optimizer
RUN apt-get update && apt-get install -y \
    zip \
    unzip \
    gifsicle \
    optipng \
    wget \
    curl \
    vim \
    libjpeg-turbo-progs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy plugins from local directory to the image
COPY --chown=www-data:www-data ./plugins /var/www/html/wp-content/plugins/custom

# Copy themes from local directory to the image
COPY --chown=www-data:www-data ./themes /var/www/html/wp-content/themes/custom

# Create symlinks for plugins
RUN if [ -d /var/www/html/wp-content/plugins/custom ]; then \
        for plugin in /var/www/html/wp-content/plugins/custom/*; do \
            if [ -d "$plugin" ]; then \
                plugin_name=$(basename "$plugin"); \
                ln -sf "/var/www/html/wp-content/plugins/custom/$plugin_name" "/var/www/html/wp-content/plugins/$plugin_name"; \
            fi \
        done \
    fi

# Create symlinks for themes
RUN if [ -d /var/www/html/wp-content/themes/custom ]; then \
        for theme in /var/www/html/wp-content/themes/custom/*; do \
            if [ -d "$theme" ]; then \
                theme_name=$(basename "$theme"); \
                ln -sf "/var/www/html/wp-content/themes/custom/$theme_name" "/var/www/html/wp-content/themes/$theme_name"; \
            fi \
        done \
    fi

# Create uploads directory structure with proper permissions
RUN mkdir -p /var/www/html/wp-content/uploads \
    && mkdir -p /var/www/html/wp-content/uploads/$(date +%Y)/$(date +%m) \
    && chown -R www-data:www-data /var/www/html/wp-content/uploads \
    && chmod -R 775 /var/www/html/wp-content/uploads

# Ensure correct permissions for all custom content
RUN chown -R www-data:www-data /var/www/html/wp-content/plugins/custom || true \
    && chown -R www-data:www-data /var/www/html/wp-content/themes/custom || true \
    && chown -R www-data:www-data /var/www/html/wp-content/ \
    && find /var/www/html/wp-content -type d -exec chmod 755 {} \; \
    && find /var/www/html/wp-content -type f -exec chmod 644 {} \;

# Copy custom entrypoint script
COPY --chmod=755 docker-entrypoint.sh /usr/local/bin/docker-entrypoint-custom.sh

# Set custom entrypoint
ENTRYPOINT ["/usr/local/bin/docker-entrypoint-custom.sh"]
CMD ["apache2-foreground"]