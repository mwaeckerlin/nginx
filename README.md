# NGINX Webserver Docker Image

Simple nginx webserver in less than 6MB. High secure: No shell, no backdoor, just nginx.

If you need PHP, use [https://github.com/waeckerlin/php-fpm].

Info: LDAP has been removed and will be implemented lated reperately in [https://github.com/mwaeckerlin/ldap-auth].

## Port

Exposes nginx on port `8080`.

## Configuration

- serves from `/app`
- add additional configuration directly to `/etc/nginx`

### Simple Example With Default Page

    docker run -it --rm --name myservice -p 8005:8080 mwaeckerlin/nginx

Got to http://localhost:8005. Cleans up when you press `Ctrl+C`.
