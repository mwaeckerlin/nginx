# Minimalistic Secure NGINX Webserver Docker Image

[mwaeckerlin/nginx] is a simple nginx webserver in less than 10MB. High secure: No shell means less risk for backdoors, just nginx running as unprivileged user.

If you need PHP, use [mwaeckerlin/php-fpm]. The image forwards php files to the FastCGI backend defined by env `PHP_FPM_HOST` and `PHP_FPM_PORT` (defaults: `php-fpm:9000`).

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

- **Static files** — plain delivery of whatever lies in `/app`.
- **SPA / PWA** — for client side routed apps (React, Vue, …) an unknown route
  falls back to the app shell `index.html`, so deep links and reloads work.
  Missing assets (`*.js`, `*.css`, images, …) return `404` instead of the shell.
- **PHP** — if there is no `index.html`, unknown routes fall through to the
  `index.php` front controller via [mwaeckerlin/php-fpm] (FastCGI backend from
  env `PHP_FPM_HOST`/`PHP_FPM_PORT`).
- **Language variants** — files named `*.XX.*` (`index.de.html`, `page.fr.html`,
  …) are picked automatically from the request's `Accept-Language`; any
  two letter code works, with a graceful fallback to the language neutral file.

## Port

Exposes nginx on port `8080`.

## Configuration

- serves from `/app`
- FastCGI backend via env: `PHP_FPM_HOST` (default `php-fpm`), `PHP_FPM_PORT` (default `9000`)
- add additional configuration directly to `/etc/nginx.template` (environment variables allowed in the form of ${VARIABLE_NAME}, but they must be defined)
- should you need ssl, create `/etc/nginx/dhparam.pem`, see example in [mwaeckerlin/reverse-proxy]

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

`npm test` runs the docker-compose based end to end suite under `tests/e2e/`,
spinning up one nginx service per usage (static, SPA/PWA, PHP, language) and
verifying each with pytest:

    npm test            # full e2e suite (tests/run-e2e.sh)

[mwaeckerlin/nginx]: https://hub.docker.com/r/mwaeckerlin/nginx "get the image from docker hub"
[mwaeckerlin/php-fpm]: https://hub.docker.com/r/mwaeckerlin/php-fpm "get the image from docker hub"
[mwaeckerlin/reverse-proxy]: https://github.com/mwaeckerlin/reverse-proxy "see definition at git hub"
[mwaeckerlin/very-base]: https://github.com/mwaeckerlin/very-base "build-only base image, never for production"
[mwaeckerlin/scratch]: https://github.com/mwaeckerlin/scratch "minimalistic runtime base image"
