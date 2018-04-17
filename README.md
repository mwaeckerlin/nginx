NGINX Webserver with optional PHP and LDAP authentication
=========================================================

Nginx webserver with optional link to PHP service on
[waeckerlin/php-fpm](https://github.com/waeckerlin/php-fpm) and with
optional link to
[mwaeckerlin/ldap-auth](https://github.com/mwaeckerlin/ldap-auth) for
LDAP athentication.

Example
-------

    docker run -d --name myservice-mysql -e MYSQL_ROOT_PASSWORD=$(pwgen -s 16 1) mysql
    docker run -d --name myservice-php --link myservice-mysql:mysql -v $(pwd):/usr/share/nginx/html:ro mwaeckerlin/php-fpm
    docker run -d --name myservice-ldap -e "" mwaeckerlin/ldap-auth
    docker run -d --name myservice --link myservice-ldap:ldap --link myservice-php:php -v $(pwd):/usr/share/nginx/html:ro -p 80:80 mwaeckerlin/nginx
