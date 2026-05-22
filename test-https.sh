#!/usr/bin/env bash
# Regression test: HTTPS fastcgi_param must reflect the actual protocol,
# not be hardcoded to "on".
#
# Requires: docker, docker compose, curl
# Usage:    ./test-https.sh
set -euo pipefail

PORT=18321
WORKDIR="$(mktemp -d)"
COMPOSE="$WORKDIR/docker-compose.yml"
PHP_DIR="$WORKDIR/app"
PASS=0
FAIL=0

red()   { printf '\033[31m%s\033[0m\n' "$*"; }
green() { printf '\033[32m%s\033[0m\n' "$*"; }

ok()   { green "PASS: $*"; ((PASS++)); }
fail() { red   "FAIL: $*"; ((FAIL++)); }

cleanup() {
    docker compose -f "$COMPOSE" down -v --remove-orphans 2>/dev/null || true
    rm -rf "$WORKDIR"
}
trap cleanup EXIT

# ---------------------------------------------------------------------------
# Test environment
# ---------------------------------------------------------------------------
mkdir -p "$PHP_DIR"

# PHP probe: outputs exactly "HTTPS=<value>" so we can grep it unambiguously
cat > "$PHP_DIR/probe.php" <<'PHP'
<?php echo 'HTTPS=' . ($_SERVER['HTTPS'] ?? '') . "\n";
PHP

cat > "$COMPOSE" <<YAML
services:
  nginx:
    image: mwaeckerlin/nginx
    environment:
      PHP_FPM_HOST: php-fpm
      PHP_FPM_PORT: "9000"
      ROOT: /app
    ports:
      - "${PORT}:8080"
    volumes:
      - ${PHP_DIR}:/app
    depends_on:
      - php-fpm
  php-fpm:
    image: php:8-fpm-alpine
    volumes:
      - ${PHP_DIR}:/app
    working_dir: /app
YAML

# Build the nginx image (uses the Dockerfile in the repo root)
echo "Building nginx image..."
docker compose -f "$(dirname "$0")/docker-compose.yml" build --quiet

echo "Starting test stack..."
docker compose -f "$COMPOSE" up -d --quiet-pull
# Wait until nginx is ready (max 20 s)
for i in $(seq 1 20); do
    curl -sf "http://localhost:${PORT}/probe.php" &>/dev/null && break
    sleep 1
done

# ---------------------------------------------------------------------------
# Test 1: plain HTTP must NOT set HTTPS
# ---------------------------------------------------------------------------
echo
echo "--- Test 1: HTTP request => HTTPS param must be absent/empty ---"
RESULT=$(curl -sf "http://localhost:${PORT}/probe.php" || true)
echo "  Response: $RESULT"
if echo "$RESULT" | grep -qx "HTTPS="; then
    ok "HTTP request: HTTPS param is empty"
else
    fail "HTTP request: expected 'HTTPS=' (empty), got '$RESULT'"
fi

# ---------------------------------------------------------------------------
# Test 2: X-Forwarded-Proto: https must set HTTPS=on
# ---------------------------------------------------------------------------
echo
echo "--- Test 2: X-Forwarded-Proto: https => HTTPS param must be 'on' ---"
RESULT=$(curl -sf -H "X-Forwarded-Proto: https" "http://localhost:${PORT}/probe.php" || true)
echo "  Response: $RESULT"
if echo "$RESULT" | grep -qx "HTTPS=on"; then
    ok "X-Forwarded-Proto: https sets HTTPS=on"
else
    fail "X-Forwarded-Proto: https expected 'HTTPS=on', got '$RESULT'"
fi

# ---------------------------------------------------------------------------
# Test 3: X-Forwarded-Proto: http must NOT set HTTPS
# ---------------------------------------------------------------------------
echo
echo "--- Test 3: X-Forwarded-Proto: http => HTTPS param must be empty ---"
RESULT=$(curl -sf -H "X-Forwarded-Proto: http" "http://localhost:${PORT}/probe.php" || true)
echo "  Response: $RESULT"
if echo "$RESULT" | grep -qx "HTTPS="; then
    ok "X-Forwarded-Proto: http: HTTPS param is empty"
else
    fail "X-Forwarded-Proto: http expected 'HTTPS=' (empty), got '$RESULT'"
fi

# ---------------------------------------------------------------------------
# Test 4: No TLS handshake errors in nginx log during HTTP operation
# ---------------------------------------------------------------------------
echo
echo "--- Test 4: nginx log must not contain TLS handshake errors ---"
LOGS=$(docker compose -f "$COMPOSE" logs nginx 2>&1)
if echo "$LOGS" | grep -qi "invalid method\|SSL_do_handshake\|no shared cipher"; then
    fail "TLS handshake errors found in nginx log"
    echo "$LOGS" | grep -i "invalid method\|SSL_do_handshake\|no shared cipher" | head -5
else
    ok "No TLS handshake errors in nginx log"
fi

# ---------------------------------------------------------------------------
echo
echo "Results: ${PASS} passed, ${FAIL} failed"
[[ $FAIL -eq 0 ]]
