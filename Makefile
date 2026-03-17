# =============================================================================
# Makefile — Laravel Docker Starter Kit
#
# Usage: make <target> [ENV=dev|staging|prod] [ARGS="..."]
# =============================================================================

# ── Configuration ─────────────────────────────────────────────────────────────
ENV     ?= dev
COMPOSE  = docker compose -f docker-compose.yml -f docker-compose.$(ENV).yml
DC       = docker compose -f docker-compose.yml -f docker-compose.$(ENV).yml

# Database profile: set DB=mysql or DB=pgsql (default mysql)
DB      ?= mysql
COMPOSE_FLAGS = --profile $(DB)

.PHONY: help up down restart ps logs build build-prod pull \
        artisan composer tinker shell \
        migrate rollback seed fresh \
        test coverage lint \
        db-mysql db-pgsql db-redis \
        npm npm-build npm-install \
        env-check

# ── Default target ─────────────────────────────────────────────────────────────
.DEFAULT_GOAL := help

help: ## Show this help
	@echo ""
	@echo "  Laravel Docker Starter Kit"
	@echo "  =========================="
	@echo ""
	@awk 'BEGIN {FS = ":.*##"; printf "  \033[36m%-20s\033[0m %s\n", "Target", "Description\n  " sprintf("%0.s─", 1 20) "─────────────────────\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
	@echo ""
	@echo "  ENV: $(ENV) | DB: $(DB)"
	@echo ""

# ── Environment lifecycle ─────────────────────────────────────────────────────
up: ## Start containers (ENV=dev|staging|prod, DB=mysql|pgsql)
	$(DC) $(COMPOSE_FLAGS) up -d

down: ## Stop and remove containers
	$(DC) down

restart: ## Restart all containers
	$(DC) restart

ps: ## Show container status
	$(DC) ps

logs: ## Tail logs (ARGS="nginx" to filter)
	$(DC) logs -f $(ARGS)

# ── Build ─────────────────────────────────────────────────────────────────────
build: ## Build dev images
	$(DC) $(COMPOSE_FLAGS) build $(ARGS)

build-prod: ## Build production images
	docker compose -f docker-compose.yml -f docker-compose.prod.yml build $(ARGS)

pull: ## Pull latest images from registry
	$(DC) pull

# ── Laravel one-shot helpers ──────────────────────────────────────────────────
artisan: ## Run artisan command  e.g. make artisan ARGS="make:model Foo"
	$(DC) run --rm --no-deps artisan $(ARGS)

composer: ## Run composer command  e.g. make composer ARGS="require spatie/laravel-permission"
	$(DC) run --rm --no-deps composer $(ARGS)

tinker: ## Open Laravel Tinker REPL
	$(DC) exec php php artisan tinker

shell: ## Open bash shell in php container
	$(DC) exec php sh

# ── Database ──────────────────────────────────────────────────────────────────
migrate: ## Run database migrations
	$(DC) exec php php artisan migrate --force

rollback: ## Roll back last migration batch
	$(DC) exec php php artisan migrate:rollback

seed: ## Run database seeders
	$(DC) exec php php artisan db:seed --force

fresh: ## Drop all tables and re-migrate + seed
	$(DC) exec php php artisan migrate:fresh --seed

db-mysql: ## Open MySQL CLI
	$(DC) exec mysql mysql -u $${DB_USERNAME:-laravel} -p$${DB_PASSWORD:-secret} $${DB_DATABASE:-laravel}

db-pgsql: ## Open PostgreSQL CLI
	$(DC) exec pgsql psql -U $${DB_USERNAME:-laravel} $${DB_DATABASE:-laravel}

db-redis: ## Open Redis CLI
	$(DC) exec redis redis-cli -a $${REDIS_PASSWORD:-redissecret}

# ── Frontend ──────────────────────────────────────────────────────────────────
npm: ## Run npm command  e.g. make npm ARGS="run dev"
	$(DC) run --rm --no-deps npm $(ARGS)

npm-install: ## Install node modules
	$(MAKE) npm ARGS="install"

npm-build: ## Build frontend assets for production
	$(MAKE) npm ARGS="run build"

npm-dev: ## Start Vite dev server
	$(DC) --profile npm up npm

# ── Testing ───────────────────────────────────────────────────────────────────
test: ## Run PHPUnit tests
	$(DC) exec php php artisan test $(ARGS)

coverage: ## Run tests with HTML coverage report
	$(DC) exec php php artisan test --coverage $(ARGS)

lint: ## Run PHP CS Fixer / Pint
	$(DC) exec php ./vendor/bin/pint $(ARGS)

analyse: ## Run PHPStan static analysis
	$(DC) exec php ./vendor/bin/phpstan analyse $(ARGS)

# ── Utilities ─────────────────────────────────────────────────────────────────
cache-clear: ## Clear all Laravel caches
	$(DC) exec php php artisan cache:clear
	$(DC) exec php php artisan config:clear
	$(DC) exec php php artisan route:clear
	$(DC) exec php php artisan view:clear

env-check: ## Verify .env file exists
	@test -f .env || (echo "ERROR: .env not found. Run: cp .env.example .env" && exit 1)
	@echo ".env OK"

setup: ## First-time project setup
	@cp -n .env.example .env || true
	@echo ">> Building images..."
	$(MAKE) build ENV=dev
	@echo ">> Starting containers..."
	$(MAKE) up ENV=dev DB=$(DB)
	@echo ">> Installing PHP dependencies..."
	$(MAKE) composer ARGS="install"
	@echo ">> Generating app key..."
	$(MAKE) artisan ARGS="key:generate"
	@echo ">> Running migrations..."
	$(MAKE) migrate
	@echo ""
	@echo "  Setup complete! App running at http://localhost:$${APP_PORT:-80}"
