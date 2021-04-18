# NGINX Webserver Docker Image

[mwaeckerlin/nginx] is a simple nginx webserver in less than 6MB. High secure: No shell means less risks for backdoors, just nginx running as unprivileged user.

If you need PHP, use [mwaeckerlin/php-fpm].

Info: LDAP has been removed and will be implemented later in [mwaeckerlin/ldap-auth].

## Port

Exposes nginx on port `8080`.

## Configuration

- serves from `/app`
- add additional configuration directly to `/etc/nginx`

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
[mwaeckerlin/ldap-auth]: https://hub.docker.com/r/mwaeckerlin/ldap-auth "get the image from docker hub"
