# docker run -d --name myservice-mysql -e MYSQL_ROOT_PASSWORD=$(pwgen -s 16 1) mysql
# docker run -d --name myservice-php --link myservice-mysql:mysql -v $(pwd):/usr/share/nginx/html:ro mwaeckerlin/php-fpm
# docker run -d --name myservice-ldap -e "" mwaeckerlin/ldap-auth
# docker run -d --name myservice --link myservice-ldap:ldap --link myservice-php:php -v $(pwd):/usr/share/nginx/html:ro -p 80:80 mwaeckerlin/nginx

FROM ubuntu:latest
MAINTAINER mwaeckerlin

ENV WEB_ROOT_PATH /usr/share/nginx/html
ENV MAX_BODY_SIZE 10M
ENV AUTOINDEX off

ENV LDAP_URL ""
ENV LDAP_BASE_DN ""
ENV LDAP_BIND_DN ""
ENV LDAP_BIND_PASS ""
ENV LDAP_REALM "Restricted"

RUN apt-get install -y nginx
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
       sed -i '/^[ \t]*#location ~ \\.php$ {/,/^[ \t]*#}/{s/#//;s/127.0.0.1/php/;/sock/d}' /etc/nginx/sites-enabled/default; \
     fi \
  && if test -n "${LDAP_PORT}" -a -n "$LDAP_URL" -a -n "$LDAP_BASE_DN" -a -n "$LDAP_BIND_DN" -a -n "$LDAP_BIND_PASS"; then \
       sed -i '\,location / {\,a      auth_request /auth-proxy;' /etc/nginx/sites-enabled/default; \
       sed -i '/^}/i  location = /auth-proxy {\n    internal;\n    proxy_pass http://ldap:8888;\n    proxy_pass_request_body off;\n    proxy_set_header Content-Length "";\n    proxy_cache auth_cache;\n    proxy_cache_valid 200 403 10m;\n    proxy_cache_key "$http_authorization$cookie_nginxauth";\n    proxy_set_header X-Ldap-URL "'${LDAP_URL}'";\n    proxy_set_header X-Ldap-BaseDN "'${LDAP_BASE_DN}'";\n    proxy_set_header X-Ldap-BindDN "'${LDAP_BIND_DN}'";\n    proxy_set_header X-Ldap-BindPass "'${LDAP_BIND_PASS}'";\n    proxy_set_header X-CookieName "nginxauth";\n    proxy_set_header Cookie nginxauth=$cookie_nginxauth;\n    proxy_set_header X-Ldap-Realm "Restricted";\n  }' /etc/nginx/sites-enabled/default; \
     fi \
  && /usr/sbin/nginx
