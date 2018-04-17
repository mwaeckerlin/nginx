FROM mwaeckerlin/base
MAINTAINER mwaeckerlin

ENV WEB_ROOT_PATH /var/lib/nginx/html
ENV WEB_ROOT /
ENV MAX_BODY_SIZE 10M
ENV AUTOINDEX off
ENV HTTP_PORT 80
ENV HTTPS_PORT 443

ENV LDAP_HOST           ""
ENV LDAP_BASE_DN        ""
ENV LDAP_BIND_DN        ""
ENV LDAP_BIND_PASS      ""
ENV LDAP_REALM          "Restricted"

ENV ERROR_PAGE          ""
ENV LOCATION_ROOT_RULES ""

ENV CONTAINERNAME       "nginx"
RUN apk add nginx
ADD default.conf /etc/nginx/conf.d/default.conf
RUN echo "daemon off;" >> /etc/nginx/nginx.conf
RUN sed '/error_log/d' /etc/nginx/nginx.conf
RUN echo "error_log stderr notice;" >> /etc/nginx/nginx.conf
RUN sed -i 's,access_log .*,access_log /dev/stdout combined;,' /etc/nginx/nginx.conf
RUN mkdir -p /usr/share/nginx
RUN mkdir /run/nginx
RUN chown $WWWUSER /run/nginx
RUN /cleanup.sh

VOLUME /etc/nginx
VOLUME ${WEB_ROOT_PATH}
EXPOSE ${HTTP_PORT} ${HTTPS_PORT}
