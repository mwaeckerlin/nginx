# docker run -d --name myservice-mysql -e MYSQL_ROOT_PASSWORD=$(pwgen -s 16 1) mysql
# docker run -d --name myservice-php --link myservice-mysql:mysql -v $(pwd):/usr/share/nginx/html:ro mwaeckerlin/php-fpm
# docker run -d --name myservice-ldap -e "" mwaeckerlin/ldap-auth
# docker run -d --name myservice --link myservice-ldap:ldap --link myservice-php:php -v $(pwd):/usr/share/nginx/html:ro -p 80:80 mwaeckerlin/nginx

FROM ubuntu:wily
MAINTAINER mwaeckerlin

ENV WEB_ROOT_PATH /usr/share/nginx/html
ENV MAX_BODY_SIZE 10M
ENV AUTOINDEX off

ENV LDAP_HOST ""
ENV LDAP_BASE_DN ""
ENV LDAP_BIND_DN ""
ENV LDAP_BIND_PASS ""
ENV LDAP_REALM "Restricted"

RUN apt-get update
RUN apt-get install -y nginx-full less emacs-nox
RUN echo "daemon off;" >> /etc/nginx/nginx.conf
RUN sed -i 's,\(access_log.*\);,\1 combined;,' /etc/nginx/nginx.conf
RUN sed -i 's,\(error_log.*\);,\1 warn;,' /etc/nginx/nginx.conf
RUN rm /etc/nginx/sites-enabled/default

VOLUME /etc/nginx
VOLUME /usr/share/nginx/html
EXPOSE 80 443
CMD cp /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default && \
    sed -i '/client_max_body_size/d;/http *{/aclient_max_body_size '${MAX_BODY_SIZE}'\;' /etc/nginx/nginx.conf \
  && sed -i '/autoindex/d;s,^\([ \t]*root[ \t]*\).*$,\1'${WEB_ROOT_PATH}';,;/^[ \t]*root.*/aautoindex '${AUTOINDEX}'\;' /etc/nginx/sites-enabled/default \
  && if test -n "${PHP_PORT}"; then \
       sed -i -e '/^[ \t]*#location ~ \\.php$ {/,/^[ \t]*#}/{s/#//;s/127.0.0.1/php/;/sock/d}' -e 's,^include snippets/fastcgi-php.conf;,include fastcgi.conf;,g' /etc/nginx/sites-enabled/default; \
       echo "PHP Enabled"; \
     fi \
  && if test -n "${LDAP_PORT}" -a -n "$LDAP_HOST" -a -n "$LDAP_BASE_DN" -a -n "$LDAP_BIND_DN" -a -n "$LDAP_BIND_PASS"; then \
       sed -i '/location \/ {/a      satisfy any;    auth_request /auth-proxy;' /etc/nginx/sites-enabled/default; \
       sed -i '/^}/i  location = /auth-proxy {\n    #internal;\n    fastcgi_param LDAP_HOST "'${LDAP_HOST}'";\n    fastcgi_param LDAP_BASE_DN "'${LDAP_BASE_DN}'";\n    fastcgi_param LDAP_BIND_DN "'${LDAP_BIND_DN}'";\n    fastcgi_param LDAP_BIND_PASS "'${LDAP_BIND_PASS}'";\n    fastcgi_param LDAP_REALM "'${LDAP_REALM}'";\n    include fastcgi.conf;\n    fastcgi_param  SCRIPT_FILENAME    $document_root/index.php;\n    fastcgi_param  SCRIPT_NAME        index.php;\n    fastcgi_pass ldap:9000;\n    fastcgi_pass_request_body off;\n  }' /etc/nginx/sites-enabled/default; \
       echo "LDAP Authentication Enabled"; \
     fi \
  && /usr/sbin/nginx
