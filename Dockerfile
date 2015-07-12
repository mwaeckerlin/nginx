# docker run -d --name safechat-mysql -e MYSQL_ROOT_PASSWORD=$(pwgen -s 16 1) mysql
# docker run -d --name safechat-php --link safechat-mysql:mysql -v $(pwd):/usr/share/nginx/html:ro mwaeckerlin/php-fpm
# docker run -d --name safechat --link safechat-php:php -v $(pwd):/usr/share/nginx/html:ro -p 80:80 mwaeckerlin/nginx

FROM ubuntu:latest
MAINTAINER mwaeckerlin

ENV WEB_ROOT_PATH /usr/share/nginx/html
ENV MAX_BODY_SIZE 10M

RUN apt-get install -y nginx
RUN echo "daemon off;" >> /etc/nginx/nginx.conf
RUN sed -i 's,\(access_log.*\);,\1 combined;,' /etc/nginx/nginx.conf
RUN sed -i 's,\(error_log.*\);,\1 warn;,' /etc/nginx/nginx.conf

VOLUME /etc/nginx
VOLUME /usr/share/nginx/html
EXPOSE 80 443
CMD sed -i '/client_max_body_size/d;/http *{/aclient_max_body_size '${MAX_BODY_SIZE}'\;' /etc/nginx/nginx.conf \
  && sed -i 's,^\([ \t]*root[ \t]*\).*$,\1'${WEB_ROOT_PATH}';,' /etc/nginx/sites-enabled/default \
  && if test -n "${PHP_PORT}"; then \
       sed -i '/^[ \t]*#location ~ \\.php$ {/,/^[ \t]*#}/{s/#//;s/127.0.0.1/php/;/sock/d}' /etc/nginx/sites-enabled/default; \
     fi \
  && /usr/sbin/nginx
