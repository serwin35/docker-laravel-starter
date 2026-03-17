#!/usr/bin/env bash
# =============================================================================
# Server-side deploy script — releases keyed by git SHA
#
# Directory layout on server:
#
#   /var/www/myapp/
#   ├── releases/
#   │   ├── a1b2c3d/    ← old commit
#   │   ├── e4f5g6h/    ← old commit
#   │   └── i7j8k9l/    ← new commit (being deployed)
#   ├── shared/
#   │   ├── .env               ← written by CI before this script runs
#   │   └── storage/           ← persistent storage (logs, uploads, etc.)
#   ├── current -> releases/i7j8k9l    ← active symlink
#   └── docker-compose.yml     ← compose files (updated by CI via git)
#
# Usage (called from GitHub Actions):
#   DEPLOY_PATH=/var/www/myapp \
#   GIT_SHA=abc1234 \
#   IMAGE_TAG=abc1234 \
#   ENVIRONMENT=prod \
#   DB_PROFILE=mysql \
#   bash deploy.sh
# =============================================================================

set -euo pipefail

# ── Configuration ─────────────────────────────────────────────────────────────
DEPLOY_PATH="${DEPLOY_PATH:?DEPLOY_PATH is required}"
GIT_SHA="${GIT_SHA:?GIT_SHA is required}"
IMAGE_TAG="${IMAGE_TAG:-$GIT_SHA}"
ENVIRONMENT="${ENVIRONMENT:?ENVIRONMENT is required}"
DB_PROFILE="${DB_PROFILE:-mysql}"
KEEP_RELEASES="${KEEP_RELEASES:-5}"

RELEASES_DIR="${DEPLOY_PATH}/releases"
SHARED_DIR="${DEPLOY_PATH}/shared"
CURRENT_LINK="${DEPLOY_PATH}/current"
RELEASE_DIR="${RELEASES_DIR}/${GIT_SHA}"

COMPOSE="docker compose \
  -f ${DEPLOY_PATH}/docker-compose.yml \
  -f ${DEPLOY_PATH}/docker-compose.${ENVIRONMENT}.yml \
  --profile ${DB_PROFILE}"

log() { echo "[deploy] $(date '+%H:%M:%S') $*"; }

# ── Guard: don't re-deploy the same SHA ──────────────────────────────────────
if [ -d "$RELEASE_DIR" ]; then
  CURRENT=$(readlink -f "$CURRENT_LINK" 2>/dev/null || echo "")
  if [ "$CURRENT" = "$RELEASE_DIR" ]; then
    log "WARN: Release ${GIT_SHA} is already active. Nothing to do."
    exit 0
  fi
  log "Release dir already exists, reusing (${GIT_SHA})"
fi

# ── 1. Prepare directories ────────────────────────────────────────────────────
log "Creating release: ${GIT_SHA}"
mkdir -p "$RELEASES_DIR" "${SHARED_DIR}/storage"

# ── 2. Extract application code into new release ─────────────────────────────
log "Archiving code from git (${GIT_SHA})..."
mkdir -p "$RELEASE_DIR"
git -C "$DEPLOY_PATH" archive "$GIT_SHA" | tar -x -C "$RELEASE_DIR"

# ── 3. Link shared resources ──────────────────────────────────────────────────
log "Linking shared .env and storage..."
ln -sfn "${SHARED_DIR}/.env"    "${RELEASE_DIR}/.env"
rm -rf  "${RELEASE_DIR}/storage"
ln -sfn "${SHARED_DIR}/storage" "${RELEASE_DIR}/storage"

# Ensure full storage structure exists
mkdir -p \
  "${SHARED_DIR}/storage/app/public" \
  "${SHARED_DIR}/storage/framework/cache/data" \
  "${SHARED_DIR}/storage/framework/sessions" \
  "${SHARED_DIR}/storage/framework/views" \
  "${SHARED_DIR}/storage/logs"

# ── 4. Update docker-compose files ────────────────────────────────────────────
log "Updating compose files to ${GIT_SHA}..."
git -C "$DEPLOY_PATH" fetch origin
git -C "$DEPLOY_PATH" reset --hard "$GIT_SHA"

# ── 5. Pull Docker images ─────────────────────────────────────────────────────
log "Pulling images (IMAGE_TAG=${IMAGE_TAG})..."
IMAGE_TAG="$IMAGE_TAG" $COMPOSE pull nginx php

# ── 6. Atomic symlink switch ──────────────────────────────────────────────────
PREVIOUS_RELEASE=$(readlink -f "$CURRENT_LINK" 2>/dev/null || echo "none")
log "Switching current: ${PREVIOUS_RELEASE} → ${RELEASE_DIR}"
ln -sfn "$RELEASE_DIR" "${CURRENT_LINK}.next"
mv -Tf "${CURRENT_LINK}.next" "$CURRENT_LINK"

# ── 7. Start / reload containers ──────────────────────────────────────────────
log "Starting containers..."
IMAGE_TAG="$IMAGE_TAG" $COMPOSE up -d --remove-orphans --wait

# ── 8. Database migrations ────────────────────────────────────────────────────
log "Running migrations..."
docker compose exec php php artisan migrate --force

# ── 9. Clear application caches ───────────────────────────────────────────────
log "Clearing caches..."
docker compose exec php php artisan cache:clear

# ── 10. Prune old releases ────────────────────────────────────────────────────
log "Pruning old releases (keeping last ${KEEP_RELEASES})..."
ls -1dt "${RELEASES_DIR}/"* | tail -n "+$((KEEP_RELEASES + 1))" | xargs rm -rf --

# ── Done ──────────────────────────────────────────────────────────────────────
log "Deploy complete!"
log "  SHA:     ${GIT_SHA}"
log "  Release: ${RELEASE_DIR}"
log ""
docker compose ps
