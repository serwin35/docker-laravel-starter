# 🐋 Laravel Docker Starter Kit

Production-ready Docker environment for Laravel with full CI/CD pipeline.

**Stack:** PHP 8.4 · Nginx · MySQL 8.4 or PostgreSQL 16 · Redis 7 · Mailpit

---

## Features

- **Multi-stage PHP Dockerfile** — separate dev (Xdebug) and prod (Opcache + JIT) images
- **MySQL 8.4 or PostgreSQL 16** — switch via Docker profiles
- **Three environments** — `dev`, `staging`, `prod` via compose overlay files
- **Releases system** — Capistrano-style `releases/` + `current` symlink, one-click rollback
- **Dynamic `.env`** — GitHub Actions auto-builds `.env` from all Environment vars/secrets
- **CI pipeline** — PHP Pint, PHPStan, tests against both MySQL and PostgreSQL
- **CD pipeline** — build → push to GHCR → SSH deploy → migrate → smoke test
- **Makefile** — ergonomic shortcuts for all common operations

---

## Directory Structure

```
.
├── .docker/
│   ├── php/
│   │   ├── Dockerfile          # Multi-stage: development | production
│   │   ├── php.ini             # Dev PHP config (debug on, opcache off)
│   │   ├── php-prod.ini        # Prod PHP config (opcache + JIT enabled)
│   │   ├── www.conf            # PHP-FPM pool
│   │   ├── xdebug.ini          # Xdebug 3 config
│   │   └── entrypoint.sh       # Prod entrypoint (config:cache etc.)
│   ├── nginx/
│   │   ├── Dockerfile
│   │   └── conf.d/app.conf     # Nginx config (gzip, security headers)
│   ├── cron/
│   │   └── Dockerfile          # Laravel scheduler (every minute)
│   ├── mysql/init/             # MySQL init scripts
│   └── pgsql/init/             # PostgreSQL init scripts
├── .github/workflows/
│   ├── ci.yml                  # Lint + tests on PR (MySQL & PostgreSQL)
│   ├── deploy.yml              # Build images → SSH deploy with releases
│   └── rollback.yml            # One-click rollback via GitHub UI
├── scripts/
│   ├── deploy.sh               # Server-side: creates release, switches symlink
│   └── rollback.sh             # Server-side: reverts to previous release
├── docker-compose.yml          # Base services
├── docker-compose.dev.yml      # Dev additions: Xdebug, Mailpit, Vite
├── docker-compose.staging.yml  # Staging: prod images, resource limits
├── docker-compose.prod.yml     # Prod: prod images, strict limits, logging
├── .env.example
└── Makefile
```

---

## Quick Start (Development)

```bash
# 1. Clone the repo and copy your Laravel app here (or start fresh)
git clone https://github.com/serwin35/docker-laravel-starter.git
cd docker-laravel-starter

# 2. Copy environment file
cp .env.example .env

# 3. First-time setup (builds images, starts containers, runs migrations)
make setup DB=mysql      # or DB=pgsql

# 4. Open http://localhost:80
```

### Manual setup

```bash
# Start with MySQL
COMPOSE_PROFILES=mysql make up

# Start with PostgreSQL
make up DB=pgsql

# Start Vite dev server (separate terminal)
make npm-dev

# Open Mailpit UI (fake SMTP)
open http://localhost:8025
```

---

## Makefile Reference

```bash
make up              # Start dev environment (DB=mysql|pgsql)
make down            # Stop all containers
make ps              # Container status
make logs            # Tail logs (ARGS=nginx to filter)
make shell           # bash in php container
make tinker          # Laravel Tinker

make migrate         # Run migrations
make seed            # Run seeders
make fresh           # migrate:fresh --seed

make test            # Run PHPUnit tests
make lint            # PHP Pint code style
make analyse         # PHPStan static analysis

make artisan  ARGS="make:model Foo -mcr"
make composer ARGS="require spatie/laravel-permission"
make npm      ARGS="run build"

make setup           # First-time full setup
make cache-clear     # Clear all Laravel caches
```

---

## Database Selection

The database is activated via **Docker profiles**:

| Profile | Variable | Host in .env |
|---------|----------|--------------|
| `mysql` | `DB_CONNECTION=mysql` | `DB_HOST=mysql` |
| `pgsql` | `DB_CONNECTION=pgsql` | `DB_HOST=pgsql` |

```bash
# MySQL (default)
make up DB=mysql

# PostgreSQL
make up DB=pgsql
```

---

## Server Layout (Production)

```
/var/www/myapp/
├── releases/
│   ├── 20240317120000/     ← old release
│   ├── 20240318093000/     ← old release
│   └── 20240319150000/     ← new release
├── shared/
│   ├── .env                ← written by CI
│   └── storage/            ← persistent (logs, uploads)
├── current -> releases/20240319150000    ← active symlink
├── docker-compose.yml
├── docker-compose.prod.yml
└── scripts/
    ├── deploy.sh
    └── rollback.sh
```

Deploy switches `current` to the new release atomically. The last **5 releases** are kept automatically.

### Rollback

One-click rollback from GitHub Actions UI:
> **Actions → Rollback → Run workflow** → choose environment → run

Or manually on the server:
```bash
DEPLOY_PATH=/var/www/myapp ENVIRONMENT=prod bash scripts/rollback.sh

# Roll back to a specific release
DEPLOY_PATH=/var/www/myapp ENVIRONMENT=prod RELEASE=20240318093000 bash scripts/rollback.sh
```

---

## CI/CD Setup

### 1. GitHub Environments

Create three environments in **Settings → Environments**: `dev`, `staging`, `prod`.

Add required reviewers to `prod` for protection.

### 2. Secrets & Variables per Environment

| Secret / Var | Type | Description |
|---|---|---|
| `SSH_HOST` | Secret | Server IP or hostname |
| `SSH_USER` | Secret | Deploy user (e.g. `deploy`) |
| `SSH_KEY`  | Secret | Private SSH key (ED25519) |
| `SSH_PORT` | Var    | SSH port (default `22`) |
| `DEPLOY_PATH` | Var | Absolute path on server |
| `APP_URL`  | Var    | App URL for smoke test |
| `DB_PROFILE` | Var  | `mysql` or `pgsql` |
| `APP_KEY`  | Secret | Laravel app key |
| `DB_PASSWORD` | Secret | Database password |
| `REDIS_PASSWORD` | Secret | Redis password |
| *(any other .env vars)* | Var/Secret | Auto-injected into `.env` |

All vars and secrets are **automatically written to `.env`** — no need to enumerate each one in the workflow.

### 3. Branch → Environment mapping

| Branch    | Deploys to |
|-----------|------------|
| `develop` | `dev`      |
| `staging` | `staging`  |
| `main`    | `prod`     |

---

## Xdebug (Development)

Xdebug 3 is pre-configured for PhpStorm on port `9003`.

In VS Code, set `"xdebug.port": 9003` in your launch config.

```ini
# .env — enable/disable per session
XDEBUG_MODE=debug       # step debugging
XDEBUG_MODE=coverage    # code coverage only
XDEBUG_MODE=off         # disabled
```

---

## License

MIT — use freely in commercial projects.
