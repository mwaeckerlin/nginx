# docker run -d --name myservice-mysql -e MYSQL_ROOT_PASSWORD=$(pwgen -s 16 1) mysql
# docker run -d --name myservice-php --link myservice-mysql:mysql -v $(pwd):/usr/share/nginx/html:ro mwaeckerlin/php-fpm
# docker run -d --name myservice-ldap -e "" mwaeckerlin/ldap-auth
# docker run -d --name myservice --link myservice-ldap:ldap --link myservice-php:php -v $(pwd):/usr/share/nginx/html:ro -p 80:80 mwaeckerlin/nginx

FROM ubuntu
MAINTAINER mwaeckerlin
ENV TERM xterm

ENV WEB_ROOT_PATH /usr/share/nginx/html
ENV WEB_ROOT /
ENV MAX_BODY_SIZE 10M
ENV AUTOINDEX off

ENV LDAP_HOST ""
ENV LDAP_BASE_DN ""
ENV LDAP_BIND_DN ""
ENV LDAP_BIND_PASS ""
ENV LDAP_REALM "Restricted"

ENV ERROR_PAGE ""
ENV LOCATION_ROOT_RULES ""

RUN apt-get update
RUN apt-get install -y nginx-full less emacs-nox
RUN echo "daemon off;" >> /etc/nginx/nginx.conf
RUN sed -i 's,\(access_log.*\);,\1 combined;,' /etc/nginx/nginx.conf
RUN sed -i 's,\(error_log.*\);,\1 warn;,' /etc/nginx/nginx.conf
RUN rm /etc/nginx/sites-enabled/default
ADD start.sh /start.sh
CMD /start.sh

VOLUME /etc/nginx
VOLUME /usr/share/nginx/html
EXPOSE 80 443
