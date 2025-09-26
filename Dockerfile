# CribOps WordPress Image with Redis Support
# Optimized for production use with all required PHP extensions
FROM wordpress:latest

LABEL maintainer="CloudBedrock <support@cloudbedrock.com>"
LABEL description="WordPress with Redis, optimized PHP settings, and Object Cache Pro support"
LABEL version="1.0.3"

# Install Redis extension with dependencies and debugging tools
RUN set -ex; \
    apt-get update; \
    apt-get install -y libzstd-dev vim less curl; \
    pecl install igbinary; \
    pecl install --configureoptions 'enable-redis-igbinary="yes" enable-redis-zstd="yes"' redis; \
    pecl install apcu; \
    docker-php-ext-enable igbinary redis apcu; \
    docker-php-ext-install -j$(nproc) bcmath sockets; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/* /tmp/pear

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

# Verify Redis is installed
RUN php -m | grep -q redis || exit 1

WORKDIR /var/www/html

CMD ["apache2-foreground"]