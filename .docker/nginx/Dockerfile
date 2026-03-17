# =============================================================================
# Nginx Dockerfile
# =============================================================================
FROM nginx:stable-alpine AS base

ARG UID=1000
ARG GID=1000

# wget for healthcheck
RUN apk add --no-cache wget \
    && rm -rf /var/cache/apk/*

# Create laravel user matching host UID/GID
RUN getent group ${GID} > /dev/null 2>&1 || addgroup -g ${GID} laravel \
    && adduser -D -u ${UID} -G laravel -s /bin/sh laravel 2>/dev/null || true \
    && sed -i "s/user  nginx;/user  laravel;/" /etc/nginx/nginx.conf \
    && chown -R laravel:laravel /var/cache/nginx /var/log/nginx /etc/nginx/conf.d

COPY conf.d/app.conf /etc/nginx/conf.d/default.conf

# ─────────────────────────── PRODUCTION STAGE ────────────────────────────────
FROM base AS production

# Bake in public assets (run `npm run build` before docker build in CI)
COPY --chown=laravel:laravel public /var/www/html/public

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
