<div align="center">

# 🐋 Laravel Docker Starter Kit

**Production-ready Docker environment for Laravel — dev, staging and prod in one place.**

[![Stars](https://img.shields.io/github/stars/serwin35/docker-laravel-starter?style=flat-square&color=yellow)](https://github.com/serwin35/docker-laravel-starter/stargazers)
[![Forks](https://img.shields.io/github/forks/serwin35/docker-laravel-starter?style=flat-square)](https://github.com/serwin35/docker-laravel-starter/network)
[![Issues](https://img.shields.io/github/issues/serwin35/docker-laravel-starter?style=flat-square)](https://github.com/serwin35/docker-laravel-starter/issues)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen?style=flat-square)](./CONTRIBUTING.md)
[![License](https://img.shields.io/github/license/serwin35/docker-laravel-starter?style=flat-square)](./LICENSE)

![PHP](https://img.shields.io/badge/PHP-8.4-777BB4?style=flat-square&logo=php&logoColor=white)
![Laravel](https://img.shields.io/badge/Laravel-11%2B-FF2D20?style=flat-square&logo=laravel&logoColor=white)
![Nginx](https://img.shields.io/badge/Nginx-stable-009639?style=flat-square&logo=nginx&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-8.4-005C84?style=flat-square&logo=mysql&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-4169E1?style=flat-square&logo=postgresql&logoColor=white)
![Redis](https://img.shields.io/badge/Redis-7-DC382D?style=flat-square&logo=redis&logoColor=white)

</div>

---

## ✨ Why This Starter Kit?

A complete, battle-tested Docker setup that goes further than Laravel Sail:

| Feature | Laravel Sail | **This starter** |
|---|:---:|:---:|
| Dev environment | ✅ | ✅ |
| Staging environment | ❌ | ✅ |
| Production environment | ❌ | ✅ |
| Multi-stage Dockerfile (dev/prod) | ❌ | ✅ |
| CI/CD with GitHub Actions | ❌ | ✅ |
| Dynamic `.env` from GitHub Environments | ❌ | ✅ |
| Releases system + rollback | ❌ | ✅ |
| MySQL 8.4 or PostgreSQL 16 (switchable) | ✅ | ✅ |
| Xdebug 3 pre-configured | ❌ | ✅ |
| Opcache + JIT in production | ❌ | ✅ |
| Mailpit (fake SMTP) | ✅ | ✅ |
| Queue worker + Scheduler | ❌ | ✅ |
| Security headers in Nginx | ❌ | ✅ |

---

## 🧱 Stack

```
┌─────────────────────────────────────────────────┐
│                    Nginx (stable)                │
│         Security headers · Gzip · Cache          │
└─────────────────────┬───────────────────────────┘
                      │ FastCGI
┌─────────────────────▼───────────────────────────┐
│               PHP 8.4-FPM (Alpine)               │
│    Extensions: gd, intl, bcmath, redis, ...      │
│    DEV:  Xdebug 3                                │
│    PROD: Opcache + JIT + entrypoint cache        │
└─────────┬──────────────────┬────────────────────┘
          │                  │
┌─────────▼──────┐  ┌────────▼────────────────────┐
│ MySQL 8.4      │  │  Redis 7                      │
│  OR            │  │  Cache · Queue · Sessions     │
│ PostgreSQL 16  │  └─────────────────────────────┘
│ (via profiles) │
└────────────────┘

Queue Worker · Scheduler (cron) · Mailpit (dev)
```

---

## 📦 Directory Structure

```
.
├── .docker/
│   ├── php/
│   │   ├── Dockerfile          # Multi-stage: development | production
│   │   ├── php.ini             # Dev config (debug on, opcache off)
│   │   ├── php-prod.ini        # Prod config (opcache + JIT)
│   │   ├── www.conf            # PHP-FPM pool
│   │   ├── xdebug.ini          # Xdebug 3 (dev only)
│   │   └── entrypoint.sh       # Prod: config:cache, route:cache...
│   ├── nginx/
│   │   ├── Dockerfile
│   │   └── conf.d/app.conf     # Gzip, security headers, PHP-FPM
│   ├── cron/Dockerfile         # Laravel Scheduler
│   ├── mysql/init/             # MySQL init scripts
│   └── pgsql/init/             # PostgreSQL init scripts
├── .github/
│   ├── workflows/
│   │   ├── ci.yml              # Tests on PR (MySQL + PostgreSQL)
│   │   ├── deploy.yml          # Build GHCR image → SSH deploy
│   │   └── rollback.yml        # One-click rollback from GitHub UI
│   ├── ISSUE_TEMPLATE/         # Bug + Feature request templates
│   └── pull_request_template.md
├── scripts/
│   ├── deploy.sh               # Releases by git SHA, current symlink
│   └── rollback.sh             # Instant rollback to previous SHA
├── docker-compose.yml          # Base services
├── docker-compose.dev.yml      # + Xdebug, Mailpit, Vite
├── docker-compose.staging.yml  # Prod images, resource limits
├── docker-compose.prod.yml     # Prod images, strict limits, JSON logging
├── .env.example
└── Makefile                    # Shortcuts for all operations
```

---

## 🚀 Quick Start

### 1. Prerequisites

- Docker Desktop (or Docker Engine + Compose v2)
- GitHub CLI: `brew install gh`

### 2. Clone & Setup

```bash
git clone https://github.com/serwin35/docker-laravel-starter.git
cd docker-laravel-starter

# Copy your Laravel app here, then:
make setup DB=mysql        # or DB=pgsql
```

That's it. App running at **http://localhost:80**

### 3. Manual Setup

```bash
cp .env.example .env

# Start with MySQL (default)
make up DB=mysql

# OR start with PostgreSQL
make up DB=pgsql

# Install dependencies
make composer ARGS="install"
make artisan  ARGS="key:generate"
make migrate

# Start Vite dev server (separate terminal)
make npm-dev
```

---

## 🗄️ Database Selection

Switch between MySQL and PostgreSQL via Docker profiles:

```bash
make up DB=mysql    # mysql:8.4
make up DB=pgsql    # postgres:16-alpine
```

Update `.env` accordingly:

```ini
# MySQL
DB_CONNECTION=mysql
DB_HOST=mysql
DB_PORT=3306

# PostgreSQL
DB_CONNECTION=pgsql
DB_HOST=pgsql
DB_PORT=5432
```

---

## 🛠️ Makefile Reference

```bash
# Environment
make up              # Start dev (DB=mysql|pgsql)
make down            # Stop all containers
make ps              # Container status
make logs            # Tail logs (ARGS=nginx to filter one service)
make shell           # bash in php container

# Laravel
make artisan  ARGS="make:model Post -mcr"
make composer ARGS="require spatie/laravel-permission"
make migrate
make seed
make fresh           # migrate:fresh --seed
make tinker

# Testing
make test
make coverage
make lint            # PHP Pint
make analyse         # PHPStan

# Frontend
make npm-dev         # Vite dev server
make npm-build       # Production assets
make npm ARGS="add alpinejs"

# Database CLI
make db-mysql
make db-pgsql
make db-redis

# First-time setup
make setup           # build + up + composer install + key:generate + migrate
```

---

## 🔁 Environments

### Development (default)

```bash
make up              # docker compose -f base -f dev
```

Includes: Xdebug, Mailpit (http://localhost:8025), Vite dev server, bind mounts.

### Staging

```bash
make up ENV=staging DB=mysql
```

Production PHP image, resource limits (1 CPU / 512M RAM).

### Production

```bash
make up ENV=prod DB=mysql
```

Production image, strict limits (2 CPU / 1G RAM), JSON logging, `restart: always`.

---

## ⚙️ CI/CD Pipeline

### CI (every Pull Request)

```
Pull Request → Lint (Pint) → PHPStan → Tests on MySQL → Tests on PostgreSQL
```

### CD (push to branch)

```
develop → dev server
staging → staging server
main    → production server  (+ required reviewers)
```

### Deploy Flow

```
1. npm run build               (frontend assets)
2. Build PHP image (prod)      (code + vendor baked in)
3. Build Nginx image (prod)    (public/ assets baked in)
4. Push both to GHCR
5. Dynamic .env built from GitHub Environment vars/secrets
6. SSH → run deploy.sh:
   - Create releases/{git-sha}/
   - Symlink shared/.env + shared/storage/
   - Switch current → new release (atomic)
   - docker compose up -d --wait
   - php artisan migrate --force
7. Smoke test: GET /up → 200 OK
```

### Rollback

```bash
# Via GitHub UI (recommended):
Actions → Rollback → choose env → Run workflow

# Via SSH:
DEPLOY_PATH=/var/www/app ENVIRONMENT=prod bash scripts/rollback.sh

# To specific commit:
GIT_SHA=abc1234 DEPLOY_PATH=/var/www/app ENVIRONMENT=prod bash scripts/rollback.sh
```

---

## 🔐 GitHub Environments Setup

Create three environments: `dev`, `staging`, `prod` in **Settings → Environments**.

Required per environment:

| Type | Name | Description |
|---|---|---|
| Secret | `SSH_HOST` | Server IP or hostname |
| Secret | `SSH_USER` | Deploy user |
| Secret | `SSH_KEY` | Private SSH key |
| Var | `SSH_PORT` | SSH port (default 22) |
| Var | `DEPLOY_PATH` | Absolute path on server |
| Var | `APP_URL` | For smoke test |
| Var | `DB_PROFILE` | `mysql` or `pgsql` |
| Secret | `APP_KEY` | Laravel app key |
| Secret | `DB_PASSWORD` | Database password |

All other vars/secrets are **automatically written to `.env`** — no manual enumeration needed.

---

## 🐛 Xdebug

Pre-configured for PhpStorm and VS Code on port `9003`:

```ini
# .env
XDEBUG_MODE=debug       # step debugging
XDEBUG_MODE=coverage    # code coverage
XDEBUG_MODE=off         # disabled (faster)
```

---

## 🤝 Contributing

Contributions are welcome! This project uses GitHub Actions — your merged PR counts toward the **Open Sourcerer** achievement.

See [CONTRIBUTING.md](.github/CONTRIBUTING.md) for guidelines.

**Good first issues:** [github.com/serwin35/docker-laravel-starter/issues?q=label%3A%22good+first+issue%22](https://github.com/serwin35/docker-laravel-starter/issues?q=label%3A%22good+first+issue%22)

---

## 💬 Discussions & Support

Have a question or idea? Use [GitHub Discussions](https://github.com/serwin35/docker-laravel-starter/discussions).

---

## ⭐ Show Your Support

If this starter kit saves you time — please **star ⭐ the repo**.
It helps others discover the project and motivates continued development.

---

## 📄 License

MIT — free to use in commercial projects.

---

<div align="center">
Made with ❤️ by <a href="https://github.com/serwin35">@serwin35</a>
</div>
