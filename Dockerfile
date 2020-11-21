FROM mwaeckerlin/very-base as nginx
RUN $PKG_INSTALL nginx
COPY default.conf /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/nginx.conf
COPY error /etc/nginx/error
RUN rm -rf /var/lib/nginx/html
RUN mkdir /run/nginx
RUN $ALLOW_USER /var/lib/nginx /run/nginx /var/log/nginx
RUN tar cph \
    /etc/nginx /usr/lib/nginx/modules /var/lib/nginx /run/nginx  \
    $(which nginx) \
    $(for f in $(which nginx) /usr/lib/nginx/modules/*; do \
    ldd $f | sed -n 's,.* => \([^ ]*\) .*,\1,p'; \
    done 2> /dev/null) 2> /dev/null \
    | tar xpC /root/

FROM mwaeckerlin/scratch
ENV CONTAINERNAME "nginx"
EXPOSE 8080
COPY --from=nginx /root/ /
COPY index.html /app/
CMD ["/usr/sbin/nginx"]