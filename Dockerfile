# docker run -d --name safechat-mysql -e MYSQL_ROOT_PASSWORD=$(pwgen -s 16 1) mysql
# docker run -d --name safechat-php --link safechat-mysql:mysql -v $(pwd):/usr/share/nginx/html:ro mwaeckerlin/php-fpm
# docker run -d --name safechat --link safechat-php:php -v $(pwd):/usr/share/nginx/html:ro -p 80:80 mwaeckerlin/nginx

FROM ubuntu:latest
MAINTAINER mwaeckerlin

ENV MAX_BODY_SIZE 10M

RUN apt-get install -y nginx
RUN echo "daemon off;" >> /etc/nginx/nginx.conf
#RUN echo "resolver 192.168.99.1 valid=300s;" >> /etc/nginx/nginx.conf
#RUN echo "resolver_timeout 10s;" >> /etc/nginx/nginx.conf
#RUN rm /etc/nginx/sites-enabled/default
#        location ~ \.php$ {
#                fastcgi_split_path_info ^(.+\.php)(/.+)$;
#                include fastcgi_params;
#                # NOTE: You should have "cgi.fix_pathinfo = 0;" in php.ini
#                fastcgi_param SCRIPT_FILENAME /var/www/html$fastcgi_script_name;
#                # With php5-cgi alone:
#                fastcgi_pass php:9000;
#                fastcgi_index index.php;
#                #include fastcgi_params;
#        }
RUN sed -i '/http *{/aclient_max_body_size '${MAX_BODY_SIZE}'\;' /etc/nginx/nginx.conf
RUN sed -i 's,\(access_log.*\);,\1 combined;,' /etc/nginx/nginx.conf
RUN sed -i 's,\(error_log.*\);,\1 warn;,' /etc/nginx/nginx.conf
RUN sed -i '/^[ \t]*#location ~ \\.php$ {/,/^[ \t]*#}/{s/#//;s/127.0.0.1/php/;/sock/d}' /etc/nginx/sites-enabled/default

VOLUME /etc/nginx
VOLUME /usr/share/nginx/html
EXPOSE 80 443
ENTRYPOINT /usr/sbin/nginx
