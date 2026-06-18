#!/usr/bin/env bash
# Run the full nginx e2e test suite covering every supported usage
# (static files, SPA/PWA, PHP, language variants).
# Usage: bash tests/run-e2e.sh [pytest-args...]
set -euo pipefail

COMPOSE="tests/e2e/docker-compose.yml"
cd "$(dirname "$0")/.."

cleanup() {
    docker compose -f "$COMPOSE" down -v --remove-orphans 2>/dev/null || true
}
trap cleanup EXIT

echo "==> Building test stack..."
docker compose -f "$COMPOSE" build --quiet

echo "==> Starting services..."
docker compose -f "$COMPOSE" up -d --remove-orphans static spa php php-fpm lang

echo "==> Running tests..."
EXIT=0
docker compose -f "$COMPOSE" run --rm test-runner "$@" || EXIT=$?

echo "==> Checking nginx logs for TLS handshake errors..."
LOGS=$(docker compose -f "$COMPOSE" logs static spa php lang 2>&1)
if echo "$LOGS" | grep -qi "invalid method\|SSL_do_handshake\|no shared cipher"; then
    echo "FAIL: TLS handshake errors found in nginx log"
    echo "$LOGS" | grep -i "invalid method\|SSL_do_handshake\|no shared cipher" | head -5
    EXIT=1
fi

if [[ $EXIT -ne 0 ]]; then
    echo "==> Collecting logs on failure..."
    docker compose -f "$COMPOSE" logs 2>&1 | tail -120
fi

exit $EXIT
