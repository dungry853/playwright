#!/usr/bin/env bash

set -Eeuo pipefail

cd "$(dirname "$0")"

chmod +x "$0"

STEP=0
TOTAL_STEPS=5
START_TIME=$(date +%s)

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

run_step() {
  local description="$1"
  shift

  STEP=$((STEP + 1))

  echo ""
  echo "=================================================="
  log "[$STEP/$TOTAL_STEPS] $description"
  echo "=================================================="

  log "Command: $*"

  local start_time
  start_time=$(date +%s)

  "$@"

  local duration=$(( $(date +%s) - start_time ))

  log "Completed: $description (${duration}s)"
}

handle_error() {
  local exit_code=$?
  local duration=$(( $(date +%s) - START_TIME ))

  echo ""
  echo "=================================================="
  log "BUILD FAILED"
  log "Failed step: $STEP/$TOTAL_STEPS"
  log "Exit code: $exit_code"
  log "Elapsed time: ${duration}s"
  echo "=================================================="

  exit "$exit_code"
}

trap handle_error ERR

echo "=================================================="
echo " Playwright + OpenCode Environment Setup"
echo "=================================================="

run_step "Building Docker image" \
  docker compose build

run_step "Installing npm dependencies" \
  docker compose run --rm playwright npm ci

run_step "Installing Playwright CLI" \
  docker compose run --rm playwright playwright-cli install

run_step "Installing Playwright Agent skills" \
  docker compose run --rm playwright playwright-cli install --skills=agents

run_step "Initializing Playwright Test Agents for OpenCode" \
  docker compose run --rm playwright npx playwright init-agents --loop=opencode

TOTAL_DURATION=$(( $(date +%s) - START_TIME ))

trap - ERR

echo ""
echo "=================================================="
log "BUILD COMPLETED SUCCESSFULLY!"
log "Total steps: $TOTAL_STEPS"
log "Total time: ${TOTAL_DURATION}s"
echo "=================================================="

echo ""
echo "Start OpenCode:"
echo "  docker compose run --rm playwright opencode"

echo ""
echo "Run Playwright tests:"
echo "  docker compose run --rm playwright npx playwright test"

echo ""