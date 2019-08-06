FROM mwaeckerlin/base
MAINTAINER mwaeckerlin
ARG wwwuser="nginx"

## configuration variables

# nginx
ENV WEB_ROOT_PATH       /app
ENV WEB_ROOT            /
ENV MAX_BODY_SIZE       0
ENV AUTOINDEX           off
ENV ERROR_PAGE          ""
ENV LOCATION_ROOT_RULES ""

# ldap - untested
ENV LDAP_HOST           ""
ENV LDAP_BASE_DN        ""
ENV LDAP_BIND_DN        ""
ENV LDAP_BIND_PASS      ""
ENV LDAP_REALM          "Restricted"


## compile time variables
ENV HTTP_PORT           8080
ENV WWWUSER             "${wwwuser}"
ENV CONTAINERNAME       "nginx"
ADD default.conf /etc/nginx/conf.d/default.conf
ADD config-nginx.sh /config-nginx.sh
RUN ${PKG_INSTALL} nginx \
 && echo "daemon off;" >> /etc/nginx/nginx.conf \
 && sed -i '/error_log/d' /etc/nginx/nginx.conf \
 && echo "error_log stderr notice;" >> /etc/nginx/nginx.conf \
 && sed -i 's,access_log .*,access_log /dev/stdout combined;,' /etc/nginx/nginx.conf \
 && touch /var/lib/nginx/logs/error.log \
 && mkdir -p /usr/share/nginx \
 && mkdir /run/nginx \
 && chown -R $WWWUSER /run/nginx /etc/nginx \
 && chgrp -R 0 /run/nginx /etc/nginx /var/tmp/nginx /var/lib/nginx \
 && chmod -R g=u /run/nginx /etc/nginx /var/tmp/nginx /var/lib/nginx \
 && rm -r /var/log/nginx \
 && mv /var/lib/nginx/html /app
USER $WWWUSER

EXPOSE ${HTTP_PORT}
