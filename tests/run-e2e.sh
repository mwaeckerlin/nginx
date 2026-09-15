#!/usr/bin/env bash
# Run the full nginx e2e test suite covering every supported usage
# (static files, SPA/PWA, language variants, optional PHP forwarding).
# The stack deliberately contains NO php-fpm service: the nginx suite runs
# entirely without PHP; the nginx+php-fpm combination is tested in the
# php-fpm project.
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
docker compose -f "$COMPOSE" up -d --remove-orphans static spa lang bare deadphp fallback-yes fallback-no frontcontroller frontcontroller-nofallback rooted

echo "==> Running tests..."
EXIT=0
docker compose -f "$COMPOSE" run --rm test-runner "$@" || EXIT=$?

echo "==> Checking nginx logs for TLS handshake errors..."
LOGS=$(docker compose -f "$COMPOSE" logs static spa lang bare deadphp fallback-yes fallback-no frontcontroller frontcontroller-nofallback rooted 2>&1)
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
