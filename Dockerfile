#### image to extract nginx executable with all dependencies ####
FROM mwaeckerlin/very-base as nginx
RUN $PKG_INSTALL nginx
COPY default.conf /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/nginx.conf
COPY ssl.conf /etc/nginx/conf.d/ssl.conf
COPY error /etc/nginx/error
RUN rm -rf /var/lib/nginx/html
# runtime user needs to write to those files:
RUN $ALLOW_USER /var/lib/nginx /run/nginx /var/log/nginx
# create /root with only the nginx executable, modules and dependencies:
RUN tar cp \
    /etc/nginx /usr/lib/nginx/modules /var/lib/nginx \
    /run/nginx /var/log/nginx \
    $(which nginx) \
    $(for f in $(which nginx) /usr/lib/nginx/modules/*; do \
    ldd $f | sed -n 's,.* => \([^ ]*\) .*,\1,p'; \
    done 2> /dev/null) 2> /dev/null \
    | tar xpC /root/
# find and add shared library dependencies in /root:
RUN tar cp \
    $(find /root -type l ! -exec test -e {} \; -exec echo -n "{} " \; -exec readlink {} \; | sed 's,/root\(.*\)/[^/]* \(.*\),\1/\2,') 2> /dev/null \
    | tar xpC /root/

#### build the final image ####
# the final image has no shell and nothing that is not required
FROM mwaeckerlin/scratch
ENV CONTAINERNAME "nginx"
EXPOSE 8080
# copy from alpine only nginx and its dependencies:
COPY --from=nginx /root/ /
# just a dummy, overwrite /app in your build:
COPY index.html /app/
WORKDIR /app
CMD ["/usr/sbin/nginx"]