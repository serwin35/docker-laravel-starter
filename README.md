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
| MinIO (local S3-compatible storage) | ❌ | ✅ |
| Laravel Reverb (WebSocket server) | ❌ | ✅ |
| SSL/HTTPS + cert generator | ❌ | ✅ |
| Queue worker + Scheduler | ❌ | ✅ |
| Security headers in Nginx | ❌ | ✅ |

---

## 🧱 Stack

```
┌─────────────────────────────────────────────────┐
│                    Nginx (stable)                │
│         Security headers · Gzip · Cache          │
│         HTTP + HTTPS (app-ssl.conf)              │
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

── DEV only (via profiles) ──────────────────────
Mailpit (SMTP)  ·  MinIO (S3)  ·  Reverb (WS)
Queue Worker    ·  Scheduler   ·  Vite dev server
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

> **Full step-by-step guide** → [QUICKSTART.md](./QUICKSTART.md)

### New project (install Laravel inside Docker — no local PHP required)

```bash
git clone https://github.com/serwin35/docker-laravel-starter.git my-project
cd my-project
cp .env.example .env

make laravel-new      # installs Laravel inside the container
make setup DB=mysql   # build + up + key:generate + migrate
```

### Existing Laravel project

```bash
# Inside your existing Laravel project directory:
curl -fsSL https://github.com/serwin35/docker-laravel-starter/archive/refs/heads/main.tar.gz \
  | tar xz --strip-components=1 \
    --exclude='docker-laravel-starter-main/README.md' \
    --exclude='docker-laravel-starter-main/LICENSE' \
    --exclude='docker-laravel-starter-main/.git'

# Merge .env.example Docker variables into your existing .env
make up DB=mysql
make migrate
```

App available at **http://localhost:80**

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
# First run
make laravel-new          # Install fresh Laravel inside the container (no local PHP)
make setup DB=mysql       # Build + up + install + key:generate + migrate

# Environment management
make up DB=mysql          # Start (DB=mysql|pgsql, ENV=dev|staging|prod)
make down                 # Stop all containers
make ps                   # Container status
make logs                 # Tail logs (ARGS=php to filter one service)
make shell                # bash inside the php container

# Laravel
make artisan  ARGS="make:model Post -mcr"
make composer ARGS="require spatie/laravel-permission"
make migrate
make seed
make fresh                # migrate:fresh --seed
make tinker
make cache-clear          # Clear all Laravel caches

# Testing
make test
make coverage
make lint                 # PHP Pint
make analyse              # PHPStan

# Frontend
make npm-dev              # Vite dev server with hot-reload
make npm-build            # Production asset build
make npm ARGS="add alpinejs"

# Database CLI
make db-mysql
make db-pgsql
make db-redis

# Optional services (require profiles)
COMPOSE_PROFILES=minio,mysql   make up   # + MinIO S3 storage
COMPOSE_PROFILES=reverb,mysql  make up   # + Laravel Reverb WebSocket
COMPOSE_PROFILES=npm,mysql     make up   # + Vite dev server in background
```

---

## 🔄 Zero-Downtime Releases & Rollback

One of the key features of this starter is the **git SHA-based releases** system — the same pattern used by Deployer, Capistrano and Envoyer, implemented in pure Bash + Docker.

### How it works

```
/var/www/myapp/
├── releases/
│   ├── a1b2c3d4.../    ← two weeks ago
│   ├── e5f6g7h8.../    ← previous deploy   (available for rollback)
│   └── i9j0k1l2.../    ← active deploy     ← current points here
│
├── shared/
│   ├── .env            ← shared — CI uploads before each deploy
│   └── storage/        ← logs, uploads, cache — persistent across releases
│
└── current -> releases/i9j0k1l2...    ← symlink, switched atomically
```

### Every deploy

1. Creates `releases/{git-sha}/` directory
2. Extracts code via `git archive`
3. Symlinks `shared/.env` and `shared/storage/`
4. Switches `current` symlink **atomically** (`mv -T`) — zero downtime
5. Runs `docker compose up -d --wait` — containers start with new code
6. Runs `php artisan migrate --force`
7. Prunes old releases (keeps last **5** by default)

### Rollback — one click

**Via GitHub UI** (recommended):

```
Actions → Rollback → select environment → Run workflow
```

**Via SSH on the server:**

```bash
# Roll back to the previous release automatically:
DEPLOY_PATH=/var/www/app ENVIRONMENT=prod bash scripts/rollback.sh

# Roll back to a specific commit:
GIT_SHA=e5f6g7h8 DEPLOY_PATH=/var/www/app ENVIRONMENT=prod bash scripts/rollback.sh
```

Rollback is **instant** — it only switches the symlink and restarts containers. No image pull needed.

### Why git SHA instead of a timestamp?

| Timestamp `20240319150000` | Git SHA `e5f6g7h8` |
|---|---|
| No link to code | `git show e5f6g7h8` — you know exactly what you deployed |
| Timezone ambiguity | Globally unique identifier |
| "When was this?" | "What was in this?" |

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
