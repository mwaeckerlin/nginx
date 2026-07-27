# Features

Numbered register of every end-user visible feature; a number is never
reused. Every feature is covered by tests listed in [TESTS.md](TESTS.md);
the guard `tests/docs-contract.sh` fails when a feature has no test.

- **F1 — Static file serving.** Everything under `/app` is delivered as-is:
  root and subdirectory `index.html`, named HTML files and assets (CSS, JS,
  images, fonts) with long-lived caching. The image ships a built-in default
  page.
- **F2 — SPA / PWA support.** For client side routed apps an unknown route
  falls back to the app shell `index.html`, so deep links and reloads work.
- **F3 — Missing assets return 404.** A missing asset (`*.js`, `*.css`,
  images, fonts, …) answers 404 and never the app shell or a PHP response,
  so broken builds surface immediately.
- **F4 — Language variants.** Files named `*.XX.*` (`index.de.html`,
  `page.fr.html`, …) are picked automatically from the request's
  `Accept-Language` for any two-letter code, with graceful fallback to the
  language neutral file.
- **F5 — PHP forwarding.** Requests for PHP files are forwarded to the
  FastCGI backend defined by `PHP_FPM_HOST`/`PHP_FPM_PORT` (default
  `php-fpm:9000`); without an `index.html`, unknown routes fall through to
  the `index.php` front controller (e.g. WordPress permalinks). Verified
  end-to-end in the php-fpm project — the nginx suite runs without PHP by
  design.
- **F6 — PHP is optional, out of the box.** The image starts and serves even
  when no PHP backend exists in the stack, because the backend hostname is
  only resolved at request time. A PHP request without a backend answers
  404 ("not found"); a configured but unreachable backend yields the 502
  page — the server never crashes over a missing backend.
- **F7 — Spoof-safe HTTPS signalling to PHP.** The `HTTPS` FastCGI flag is
  set on native TLS or on `X-Forwarded-Proto: https` from a terminating
  proxy; a client-supplied `X-Forwarded-Proto: http` can never downgrade
  it. Verified end-to-end in the php-fpm project.
- **F8 — Security headers.** One complete, authoritative set of security
  headers on every response including error pages, without duplicates; the
  server version is never revealed.
- **F9 — Localized error pages.** Friendly 404/502/504 pages, localized via
  `Accept-Language` (any two-letter code, English fallback).
- **F10 — Configuration via environment variables.** `${VARIABLE_NAME}`
  placeholders in `/etc/nginx.template` are substituted at container start
  (`ROOT`, `PHP_FPM_HOST`, `PHP_FPM_PORT`, …); additional configuration
  files can simply be added to the template directory.
- **F11 — Headless minimal production image.** Around 10 MB, no shell and no
  interpreter to pivot with, runs as an unprivileged user.
