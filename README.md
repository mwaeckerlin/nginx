# Minimalistic Secure NGINX Webserver Docker Image

[mwaeckerlin/nginx] is a simple nginx webserver in less than 10MB. High secure: No shell means less risk for backdoors, just nginx running as unprivileged user.

If you need PHP, use [mwaeckerlin/php-fpm]. The image forwards php files to the FastCGI backend defined by env `PHP_FPM_HOST` and `PHP_FPM_PORT` (defaults: `php-fpm:9000`).

Image size: ca. 9.87MB (depends on parent image sizes and changes)

This is the most lean and secure image for NGINX servers:
 - extremely small size, minimalistic dependencies
 - no shell, only the server command
 - small attack surface
 - starts as non root user

## Port

Exposes nginx on port `8080`.

## Configuration

- serves from `/app`
- FastCGI backend via env: `PHP_FPM_HOST` (default `php-fpm`), `PHP_FPM_PORT` (default `9000`)
- add additional configuration directly to `/etc/nginx.template` (environment variables allowed in the form of ${VARIABLE_NAME}, but they must be defined)
- should you need ssl, create `/etc/nginx/dhparam.pem`, see example in [mwaeckerlin/reverse-proxy]

### Docker Compose Sample with Mounted App Path

See `docker-compose.yml` for an example:

- `docker-compose build`
- `docker-compose up`
- browse to: `http://localhost:8080`
- stop with `Ctrl+C`

### Command Line Example With Default Page

    docker run -it --rm --name myservice -p 8005:8080 mwaeckerlin/nginx

Browse to http://localhost:8005. Cleans up when you press `Ctrl+C`.

[mwaeckerlin/nginx]: https://hub.docker.com/r/mwaeckerlin/nginx "get the image from docker hub"
[mwaeckerlin/php-fpm]: https://hub.docker.com/r/mwaeckerlin/php-fpm "get the image from docker hub"
[mwaeckerlin/reverse-proxy]: https://github.com/mwaeckerlin/reverse-proxy "see definition at git hub"
