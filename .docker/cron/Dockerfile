# =============================================================================
# Cron Dockerfile — runs Laravel scheduler every minute
# =============================================================================
ARG PHP_VERSION=8.4
FROM php:${PHP_VERSION}-fpm-alpine

ARG UID=1000
ARG GID=1000

RUN apk add --no-cache \
    libpng-dev libzip-dev postgresql-dev \
    && rm -rf /var/cache/apk/*

RUN docker-php-ext-install pdo pdo_mysql pdo_pgsql zip bcmath

# Create laravel user matching host UID/GID
RUN getent group ${GID} > /dev/null 2>&1 || addgroup -g ${GID} laravel \
    && adduser -D -u ${UID} -G laravel -s /bin/sh laravel 2>/dev/null || true

# Install cron schedule
RUN echo "* * * * * laravel cd /var/www/html && php artisan schedule:run >> /proc/1/fd/1 2>&1" \
    > /etc/crontabs/laravel

WORKDIR /var/www/html

CMD ["crond", "-f", "-l", "2"]
