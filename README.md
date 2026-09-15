# Minimalistic Secure NGINX Webserver Docker Image

[mwaeckerlin/nginx] is a simple nginx webserver in less than 10MB. High secure: No shell means less risk for backdoors, just nginx running as unprivileged user.

If you need PHP, use [mwaeckerlin/php-fpm]. The image forwards php files to the FastCGI backend defined by env `PHP_FPM_HOST` and `PHP_FPM_PORT` (defaults: `php-fpm:9000`). PHP is optional: without a PHP backend in the stack the image runs exactly the same — the backend hostname is only resolved when a PHP file is actually requested, and such a request then simply answers `404`.

All features are listed in [FEATURES.md](FEATURES.md), all tests in [TESTS.md](TESTS.md).

Image size: ca. 9.87MB (depends on parent image sizes and changes)

This is the most lean and secure image for NGINX servers:
 - extremely small size, minimalistic dependencies
 - no shell, only the server command
 - small attack surface
 - starts as non root user

**Role: production runtime image** — run it directly or use it as the **final stage** of a multi-stage build (copy your files into `/app`). It is a runtime image, never a build image; it is built via the build-only [mwaeckerlin/very-base] and ships on the runtime base [mwaeckerlin/scratch].

## Universal usage without extra configuration

The same image serves all of the following out of the box, just by copying your
files to `/app` — the presence of the files decides the behaviour:

- **Static files** — plain delivery of whatever lies in `/app`. With
  `SPA_FALLBACK=no` an unknown address answers `404` instead of the start
  page, which is what a static website needs (see [Configuration](#configuration)).
- **SPA / PWA** — for client side routed apps (React, Vue, …) an unknown route
  falls back to the app shell `index.html`, so deep links and reloads work.
  Missing assets (`*.js`, `*.css`, images, …) return `404` instead of the shell.
- **PHP** — an unknown route goes to the `index.php` front controller via
  [mwaeckerlin/php-fpm] (FastCGI backend from env `PHP_FPM_HOST`/`PHP_FPM_PORT`)
  whenever `/app` holds one, so WordPress permalinks and every other routed PHP
  application work. The front controller decides per address and answers `404`
  for one it does not know, so it wins over an `index.html` lying beside it —
  which matters because this image copies its welcome page into `/app` and
  every derived image inherits it. Entirely optional: with no backend in the
  stack, PHP requests answer `404` and everything else works unchanged.
- **Language variants** — files named `*.XX.*` (`index.de.html`, `page.fr.html`,
  …) are picked automatically from the request's `Accept-Language`; any
  two letter code works, with a graceful fallback to the language neutral file.

## Port

Exposes nginx on port `8080`.

## Configuration

- serves from `/app`
- answer for an address that matches no file via env: `SPA_FALLBACK` (default `yes`), see below
- FastCGI backend via env: `PHP_FPM_HOST` (default `php-fpm`), `PHP_FPM_PORT` (default `9000`)
- add additional configuration directly to `/etc/nginx.template` (environment variables allowed in the form of ${VARIABLE_NAME}, but they must be defined)
- should you need ssl, create `/etc/nginx/dhparam.pem`, see example in [mwaeckerlin/reverse-proxy]

### Unknown Paths: Start Page or 404

`SPA_FALLBACK` decides what an address that matches no file answers:

- `SPA_FALLBACK=yes` (default) — the `index.php` front controller answers where `/app` holds one, otherwise the app shell `index.html` with status 200. **This is the right behaviour for a single page application** (React, Vue, …), where a deep link and a reload of a client side route must reach the app, **and for every routed PHP application** (WordPress permalinks).
- `SPA_FALLBACK=no` — the request answers `404` with the friendly error page. **This is the right behaviour for a static website**, where a typing error in the address must say "not found": with the fallback a wrong address answers 200 with the start page, and search engines then index every invented address as a valid page.

The default keeps the behaviour of all earlier versions, so an upgrade changes nothing in a running deployment; only the literal value `no` switches the fallback off, every other value keeps it. In both settings existing files, subdirectory indexes, assets and language variants are delivered unchanged and the error pages stay localized. A PHP application keeps the default `yes`: with `no` an unknown address answers `404` before the front controller is asked, so its routed addresses stop working.

    docker run -it --rm --name mysite -p 8005:8080 -e SPA_FALLBACK=no mwaeckerlin/nginx

### Docker Compose Sample

See `docker-compose.yml` for an example serving the built-in default page:

- `npm run build`
- `npm start` (foreground) or `npm run start:daemon` (background)
- browse to: `http://localhost:8080`
- stop with `Ctrl+C` (or `npm stop` for daemon mode)

### Command Line Example With Default Page

    docker run -it --rm --name myservice -p 8005:8080 mwaeckerlin/nginx

Browse to http://localhost:8005. Cleans up when you press `Ctrl+C`.

## Tests

`npm test` runs the docs contract (every feature in [FEATURES.md](FEATURES.md)
has a test in [TESTS.md](TESTS.md), no skipped tests), the image contract
(headless image) and the docker-compose based end to end suite under
`tests/e2e/`, spinning up one nginx service per usage (static, SPA/PWA,
language, error pages, env overrides) and verifying each with pytest:

    npm test            # docs + image contract + full e2e suite

The e2e stack deliberately contains **no php-fpm service** — it pins that the
image works without a PHP backend. The nginx+php-fpm combination is tested
end to end in the [mwaeckerlin/php-fpm] project.

[mwaeckerlin/nginx]: https://hub.docker.com/r/mwaeckerlin/nginx "get the image from docker hub"
[mwaeckerlin/php-fpm]: https://hub.docker.com/r/mwaeckerlin/php-fpm "get the image from docker hub"
[mwaeckerlin/reverse-proxy]: https://github.com/mwaeckerlin/reverse-proxy "see definition at git hub"
[mwaeckerlin/very-base]: https://github.com/mwaeckerlin/very-base "build-only base image, never for production"
[mwaeckerlin/scratch]: https://github.com/mwaeckerlin/scratch "minimalistic runtime base image"
