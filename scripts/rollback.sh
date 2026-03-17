#!/usr/bin/env bash
# =============================================================================
# Rollback script — reverts 'current' to a previous release (by git SHA)
#
# Fast: just switches a symlink + restarts containers. No image pull needed.
#
# Usage:
#   # Roll back to previous release automatically:
#   DEPLOY_PATH=/var/www/myapp ENVIRONMENT=prod bash rollback.sh
#
#   # Roll back to a specific SHA:
#   DEPLOY_PATH=/var/www/myapp ENVIRONMENT=prod GIT_SHA=abc1234 bash rollback.sh
# =============================================================================

set -euo pipefail

DEPLOY_PATH="${DEPLOY_PATH:?DEPLOY_PATH is required}"
ENVIRONMENT="${ENVIRONMENT:?ENVIRONMENT is required}"
DB_PROFILE="${DB_PROFILE:-mysql}"

RELEASES_DIR="${DEPLOY_PATH}/releases"
CURRENT_LINK="${DEPLOY_PATH}/current"

COMPOSE="docker compose \
  -f ${DEPLOY_PATH}/docker-compose.yml \
  -f ${DEPLOY_PATH}/docker-compose.${ENVIRONMENT}.yml \
  --profile ${DB_PROFILE}"

log() { echo "[rollback] $(date '+%H:%M:%S') $*"; }

# ── List releases sorted by modification time (newest first) ──────────────────
mapfile -d '' RELEASES < <(find "$RELEASES_DIR" -mindepth 1 -maxdepth 1 -type d -print0 | xargs -0 ls -1dt)

CURRENT_RELEASE=$(readlink -f "$CURRENT_LINK" 2>/dev/null || echo "none")

log "Available releases (newest first):"
for i in "${!RELEASES[@]}"; do
  SHA=$(basename "${RELEASES[$i]}")
  MARKER=""
  [ "${RELEASES[$i]}" = "$CURRENT_RELEASE" ] && MARKER=" ◄ current"
  printf "  [%d] %s%s\n" "$i" "$SHA" "$MARKER"
done
echo ""

if [ "${#RELEASES[@]}" -lt 2 ]; then
  log "ERROR: Need at least 2 releases to rollback."
  log "       Current active: $(basename "$CURRENT_RELEASE")"
  exit 1
fi

# ── Resolve target release ─────────────────────────────────────────────────────
if [ -n "${GIT_SHA:-}" ]; then
  # Specific SHA requested
  TARGET_RELEASE="${RELEASES_DIR}/${GIT_SHA}"
  if [ ! -d "$TARGET_RELEASE" ]; then
    log "ERROR: Release '${GIT_SHA}' not found in ${RELEASES_DIR}"
    log "Available: $(ls "${RELEASES_DIR}")"
    exit 1
  fi
else
  # Auto: find the release immediately before current
  CURRENT_INDEX=-1
  for i in "${!RELEASES[@]}"; do
    [ "${RELEASES[$i]}" = "$CURRENT_RELEASE" ] && CURRENT_INDEX=$i && break
  done

  if [ "$CURRENT_INDEX" -lt 0 ]; then
    log "WARN: Could not find current release in list, using most recent."
    TARGET_RELEASE="${RELEASES[0]}"
  elif [ "$CURRENT_INDEX" -ge $((${#RELEASES[@]} - 1)) ]; then
    log "ERROR: No previous release available — already at oldest."
    exit 1
  else
    TARGET_RELEASE="${RELEASES[$((CURRENT_INDEX + 1))]}"
  fi
fi

TARGET_SHA=$(basename "$TARGET_RELEASE")
CURRENT_SHA=$(basename "$CURRENT_RELEASE")

log "Rolling back:"
log "  FROM: ${CURRENT_SHA}"
log "  TO:   ${TARGET_SHA}"

# ── Atomic symlink switch ──────────────────────────────────────────────────────
ln -sfn "$TARGET_RELEASE" "${CURRENT_LINK}.rollback"
mv -Tf "${CURRENT_LINK}.rollback" "$CURRENT_LINK"

# ── Restart containers ─────────────────────────────────────────────────────────
log "Restarting containers..."
$COMPOSE restart php nginx queue scheduler

# ── Done ──────────────────────────────────────────────────────────────────────
log "Rollback complete!"
log "  Active release: $(basename "$(readlink -f "$CURRENT_LINK")")"
log ""
log "To redo the forward deploy: run deploy.sh or trigger GitHub Actions."
