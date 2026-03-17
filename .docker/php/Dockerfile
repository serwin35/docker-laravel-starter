# =============================================================================
# PHP Dockerfile — multi-stage (development | production)
# =============================================================================
ARG PHP_VERSION=8.4

# ─────────────────────────── BASE STAGE ──────────────────────────────────────
FROM php:${PHP_VERSION}-fpm-alpine AS base

ARG UID=1000
ARG GID=1000

# System packages
RUN apk add --no-cache \
    bash curl zip unzip git shadow \
    libpng-dev libwebp-dev libjpeg-turbo-dev freetype-dev \
    libxml2-dev oniguruma-dev libzip-dev icu-dev icu-libs \
    postgresql-dev linux-headers autoconf gcc g++ make \
    && rm -rf /var/cache/apk/*

# PHP core extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install -j$(nproc) \
        gd intl bcmath mbstring curl mysqli opcache soap \
        pdo pdo_mysql pdo_pgsql zip exif pcntl sockets

# PECL extensions
RUN pecl install imagick redis \
    && docker-php-ext-enable imagick redis \
    && rm -rf /tmp/pear

# Create laravel system user matching host UID/GID
RUN getent group ${GID} > /dev/null 2>&1 || addgroup -g ${GID} laravel \
    && adduser -D -u ${UID} -G laravel -s /bin/sh laravel 2>/dev/null || true

WORKDIR /var/www/html

# ─────────────────────────── DEVELOPMENT STAGE ───────────────────────────────
FROM base AS development

# Xdebug
RUN pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && rm -rf /tmp/pear

COPY php.ini      /usr/local/etc/php/conf.d/zzz-custom.ini
COPY www.conf     /usr/local/etc/php-fpm.d/www.conf
COPY xdebug.ini   /usr/local/etc/php/conf.d/zzz-xdebug.ini

USER laravel
CMD ["php-fpm"]

# ─────────────────────────── PRODUCTION STAGE ────────────────────────────────
FROM base AS production

# Install Composer (multi-stage copy)
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Production PHP config
COPY php-prod.ini /usr/local/etc/php/conf.d/zzz-custom.ini
COPY www.conf     /usr/local/etc/php-fpm.d/www.conf

# Copy application code
COPY --chown=laravel:laravel . /var/www/html

# Install PHP dependencies (no dev, optimized autoloader)
RUN composer install \
        --no-dev \
        --optimize-autoloader \
        --no-scripts \
        --no-interaction \
        --prefer-dist \
    && rm -f /usr/bin/composer

# Entrypoint caches Laravel bootstrapping at container start
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

USER laravel
ENTRYPOINT ["entrypoint.sh"]
CMD ["php-fpm"]
