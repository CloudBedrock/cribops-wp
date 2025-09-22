# CribOps WordPress Docker Image

Production-ready WordPress image with Redis support and optimized PHP settings for high-performance WordPress hosting.

## Features

- **WordPress (latest) with PHP 8.3** and Apache
- **Redis PHP Extension** with igbinary and zstd compression
- **APCu** for local object caching
- **Optimized PHP Settings**:
  - 256MB file uploads
  - 600s execution time
  - 512MB memory limit
  - 10,000 input vars
- **Object Cache Pro Ready** with full feature support
- **Multi-architecture**: Supports both AMD64 and ARM64

## Quick Start

```bash
# Pull from Docker Hub
docker pull cloudbedrock/cribops-wp:latest

# Or pull from GitHub Container Registry
docker pull ghcr.io/cloudbedrock/cribops-wp:latest
```

## Usage

### Basic WordPress Setup

```yaml
version: '3.8'
services:
  wordpress:
    image: cloudbedrock/cribops-wp:latest
    ports:
      - "8080:80"
    environment:
      WORDPRESS_DB_HOST: db
      WORDPRESS_DB_USER: wordpress
      WORDPRESS_DB_PASSWORD: wordpress
      WORDPRESS_DB_NAME: wordpress
    volumes:
      - wordpress_data:/var/www/html

  db:
    image: mysql:8.0
    environment:
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wordpress
      MYSQL_PASSWORD: wordpress
      MYSQL_RANDOM_ROOT_PASSWORD: '1'
    volumes:
      - db_data:/var/lib/mysql

volumes:
  wordpress_data:
  db_data:
```

### With Redis Cache

```yaml
version: '3.8'
services:
  wordpress:
    image: cloudbedrock/cribops-wp:latest
    ports:
      - "8080:80"
    environment:
      WORDPRESS_DB_HOST: db
      WORDPRESS_DB_USER: wordpress
      WORDPRESS_DB_PASSWORD: wordpress
      WORDPRESS_DB_NAME: wordpress
      WORDPRESS_CONFIG_EXTRA: |
        define('WP_REDIS_HOST', 'redis');
        define('WP_REDIS_PORT', 6379);
    volumes:
      - wordpress_data:/var/www/html

  redis:
    image: redis:7-alpine
    command: redis-server --appendonly yes
    volumes:
      - redis_data:/data

  db:
    image: mysql:8.0
    environment:
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wordpress
      MYSQL_PASSWORD: wordpress
      MYSQL_RANDOM_ROOT_PASSWORD: '1'
    volumes:
      - db_data:/var/lib/mysql

volumes:
  wordpress_data:
  redis_data:
  db_data:
```

## PHP Extensions Included

- **Core**: opcache, zip, gd, intl, mysqli, pdo_mysql
- **Caching**: redis, igbinary, apcu
- **Performance**: bcmath, sockets, exif
- **Images**: imagick, gd

## PHP Configuration

| Setting | Value | Description |
|---------|-------|-------------|
| upload_max_filesize | 256M | Maximum upload file size |
| post_max_size | 256M | Maximum POST data size |
| max_execution_time | 600 | Maximum script execution time (10 minutes) |
| memory_limit | 512M | PHP memory limit |
| max_input_vars | 10000 | Maximum input variables |
| max_file_uploads | 50 | Maximum concurrent file uploads |

## Environment Variables

All standard WordPress environment variables are supported:

- `WORDPRESS_DB_HOST`
- `WORDPRESS_DB_USER`
- `WORDPRESS_DB_PASSWORD`
- `WORDPRESS_DB_NAME`
- `WORDPRESS_TABLE_PREFIX`
- `WORDPRESS_DEBUG`
- `WORDPRESS_CONFIG_EXTRA`

## Tags

- `latest`, `php8.3-redis` - Latest stable build with PHP 8.3
- `vX.Y.Z` - Specific version releases
- `main-<sha>` - Development builds from main branch

## Building from Source

```bash
git clone https://github.com/cloudbedrock/cribops-wp.git
cd cribops-wp
docker build -t cribops-wp:custom .
```

## License

This Docker image is open source and available under the MIT License.

## Support

For issues and feature requests, please visit: https://github.com/CloudBedrock/wordpress-docker/issues

## Credits

Maintained by [CloudBedrock](https://cloudbedrock.com) for the CribOps platform.