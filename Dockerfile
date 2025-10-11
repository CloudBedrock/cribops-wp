# syntax=docker/dockerfile:1
FROM wordpress:6.8.3

LABEL maintainer="CloudBedrock <support@cloudbedrock.com>"
LABEL description="WordPress with Redis, optimized PHP settings, and Object Cache Pro support"

# Install system dependencies
RUN set -ex; \
    apt-get clean; \
    rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        libzstd-dev \
        libzstd1 \
        vim \
        less \
        curl \
        zip \
        unzip \
        gifsicle \
        optipng \
        wget \
        git \
        libjpeg-progs; \
    apt-get clean; \
    rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

# Install PECL extensions
RUN set -ex; \
    pecl install igbinary; \
    pecl install --configureoptions 'enable-redis-igbinary="yes" enable-redis-zstd="yes"' redis; \
    pecl install apcu; \
    docker-php-ext-enable igbinary redis apcu; \
    docker-php-ext-install -j$(nproc) pdo pdo_mysql mysqli bcmath sockets; \
    rm -rf /tmp/pear

# Install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Create optimized PHP configuration
RUN { \
    echo '; CribOps PHP Configuration'; \
    echo 'upload_max_filesize = 256M'; \
    echo 'post_max_size = 256M'; \
    echo 'max_execution_time = 600'; \
    echo 'max_input_time = 600'; \
    echo 'max_input_vars = 10000'; \
    echo 'memory_limit = 512M'; \
    echo 'max_file_uploads = 50'; \
    echo 'session.gc_maxlifetime = 1440'; \
    echo ''; \
    echo '; OpCache Settings'; \
    echo 'opcache.enable = 1'; \
    echo 'opcache.memory_consumption = 256'; \
    echo 'opcache.interned_strings_buffer = 16'; \
    echo 'opcache.max_accelerated_files = 10000'; \
    echo 'opcache.revalidate_freq = 2'; \
    echo 'opcache.fast_shutdown = 1'; \
    echo ''; \
    echo '; Redis Settings'; \
    echo 'redis.arrays.retryinterval = 0'; \
    echo 'redis.clusters.cache_slots = 1'; \
    echo 'redis.pconnect.pooling_enabled = 1'; \
    echo 'redis.session.locking_enabled = 1'; \
    echo ''; \
    echo '; APCu Settings'; \
    echo 'apc.enabled = 1'; \
    echo 'apc.shm_size = 128M'; \
    echo 'apc.ttl = 7200'; \
} > /usr/local/etc/php/conf.d/cribops.ini

# Enable Apache modules for better performance
RUN a2enmod expires headers rewrite

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

# Verify required extensions are installed
RUN php -m | grep -q redis || exit 1; \
    php -m | grep -q pdo_mysql || exit 1; \
    php -m | grep -q mysqli || exit 1

# Copy custom entrypoint script
COPY --chmod=755 docker-entrypoint.sh /usr/local/bin/docker-entrypoint-custom.sh

WORKDIR /var/www/html

# Health check to ensure WordPress is responding
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

# Set custom entrypoint
ENTRYPOINT ["/usr/local/bin/docker-entrypoint-custom.sh"]
CMD ["apache2-foreground"]