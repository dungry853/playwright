#!/bin/sh
set -e

LOCK="package-lock.json"
STAMP="node_modules/.lock.sha256"

# 1. Install dependencies when the lockfile changed or node_modules is empty.
if [ -f "$LOCK" ]; then
  HASH="$(sha256sum "$LOCK" | cut -d' ' -f1)"
  if [ ! -d node_modules/@playwright/test ] || [ "$(cat "$STAMP" 2>/dev/null)" != "$HASH" ]; then
    echo "[entrypoint] Installing dependencies (npm ci)..."
    npm ci
    echo "$HASH" > "$STAMP"
  fi
elif [ -f package.json ] && [ ! -d node_modules/@playwright/test ]; then
  echo "[entrypoint] No package-lock.json found, running npm install..."
  npm install
fi

# 2. Warn if @playwright/test does not match the browsers baked into the image.
INSTALLED="$(node -p "require('@playwright/test/package.json').version" 2>/dev/null || true)"
if [ -n "$INSTALLED" ] && [ -n "$PLAYWRIGHT_VERSION" ] && [ "$INSTALLED" != "$PLAYWRIGHT_VERSION" ]; then
  echo "[entrypoint] WARNING: @playwright/test is $INSTALLED but the image is $PLAYWRIGHT_VERSION." >&2
  echo "[entrypoint] Align package.json and PLAYWRIGHT_VERSION, then rebuild the image." >&2
fi

exec "$@"