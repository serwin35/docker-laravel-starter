#!/bin/sh
# ─── Production entrypoint — caches Laravel bootstrapping then starts FPM ────
set -e

echo "[entrypoint] Caching Laravel bootstrap..."
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan event:cache

echo "[entrypoint] Starting php-fpm..."
exec "$@"
