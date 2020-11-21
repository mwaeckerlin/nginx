# NGINX Webserver

Simple nginx webserver. If you need PHP, use [waeckerlin/php-fpm].

Info: LDAP has been removed and will be implemented lated reperately in [mwaeckerlin/ldap-auth].

## Port

Exposes nginx on port `8080`.

## Configuration

- serves from `/app`
- add additional configuration directly to `/etc/nginx`

### Simple Example With Default Page

    docker run -it --rm --name myservice -p 8005:8080 mwaeckerlin/nginx

Got to http://localhost:8005. Cleans up when you press `Ctrl+C`.
