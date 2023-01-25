#### image to extract nginx executable with all dependencies ####
FROM mwaeckerlin/very-base as nginx
RUN $PKG_INSTALL nginx
RUN rm -rf /var/lib/nginx/html
# runtime user needs to write to those files:
RUN $ALLOW_USER /var/lib/nginx /run/nginx /var/log/nginx
COPY app /app
COPY conf /etc/nginx
USER $RUN_USER
RUN nginx -t
USER root
# create /root with only the nginx executable, modules, dependencies and configurations:
RUN tar cph \
    /app /etc/nginx /usr/lib/nginx/modules /var/lib/nginx \
    /run/nginx /var/log/nginx \
    $(which nginx) \
    $(for f in $(which nginx) /usr/lib/nginx/modules/*; do \
    ldd $f | sed -n 's,.* => \([^ ]*\) .*,\1,p'; \
    done 2> /dev/null) 2> /dev/null \
    | tar xpC /root/

#### build the final image ####
# the final image has no shell and nothing that is not required
FROM mwaeckerlin/scratch
ENV CONTAINERNAME "nginx"
EXPOSE 8080
WORKDIR /app
CMD ["/usr/sbin/nginx"]
# copy from alpine only what we need
COPY --from=nginx /root/ /
