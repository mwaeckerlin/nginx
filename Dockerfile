FROM mwaeckerlin/very-base AS envwrap
RUN $PKG_INSTALL g++
COPY envwrap.cpp .
RUN g++ -static -Os -flto=auto -fno-rtti -ffunction-sections -fdata-sections -Wl,--gc-sections -Wl,-s -std=c++20 -o envwrap envwrap.cpp
RUN strip -s -R .comment -R .gnu.version --strip-unneeded envwrap

FROM mwaeckerlin/very-base AS nginx
RUN $PKG_INSTALL nginx
RUN rm -rf /var/lib/nginx/html
RUN mv /etc/nginx /etc/nginx.template
RUN mkdir /etc/nginx
RUN $ALLOW_USER /var/lib/nginx /run/nginx /var/log/nginx /etc/nginx
ENV PHP_FPM_HOST "php-fpm"
ENV PHP_FPM_PORT "9000"
COPY --from=envwrap envwrap /usr/bin/envwrap
COPY app /app
COPY conf /etc/nginx.template

# create /root with only the nginx executable, modules, dependencies and configurations:
RUN tar cph \
    /app /etc/nginx /etc/nginx.template /usr/lib/nginx/modules /var/lib/nginx \
    /run/nginx /var/log/nginx /usr/bin/envwrap \
    $(which nginx) \
    $(for f in $(which nginx) /usr/lib/nginx/modules/*; do \
    ldd $f | sed -n 's,.* => \([^ ]*\) .*,\1,p'; \
    done 2> /dev/null) 2> /dev/null \
    | tar xpC /root/

#### build the final image ####
# the final image has no shell and nothing that is not required
FROM mwaeckerlin/scratch
ENV CONTAINERNAME "nginx"
ENV PHP_FPM_HOST "php-fpm"
ENV PHP_FPM_PORT "9000"
EXPOSE 8080
WORKDIR /app
CMD ["/usr/bin/envwrap", "/etc/nginx.template", "/etc/nginx", "/usr/sbin/nginx"]
COPY --from=nginx /root/ /
