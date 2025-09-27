FROM cloudbedrock/cribops-wp:latest

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

# Ensure correct permissions
RUN chown -R www-data:www-data /var/www/html/wp-content/plugins/custom || true \
    && chown -R www-data:www-data /var/www/html/wp-content/themes/custom || true