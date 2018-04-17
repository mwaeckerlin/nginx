#!/bin/sh -e

# call option with parameters: $1=name $2=value $3=file
function option() {
    sed -i \
    -e '/^#\?\(\s*'"${1//\//\//}"'\s*=\s*\).*/{s//\1'"${2//\//\//}"'/;:a;n;:ba;q}' \
    -e '$a'"${1//\//\//}"'='"${2//\//\//}" $3
}

export ENV_WEB_ROOT_PATH=$(env | grep ENV_WEB_ROOT_PATH | head -1 | sed 's,[^=]*=,,')
sed -i '/client_max_body_size/d;/http *{/aclient_max_body_size '${MAX_BODY_SIZE}'\;' /etc/nginx/nginx.conf
sed -i 's,\${HTTP_PORT},'"${HTTP_PORT}"',g;s,\${WEB_ROOT_PATH},'"${WEB_ROOT_PATH}"',g' /etc/nginx/conf.d/default.conf
sed -i '/autoindex/d;s,^\([ \t]*root[ \t]*\).*$,\1'${ENV_WEB_ROOT_PATH:-$WEB_ROOT_PATH}';,;/^[ \t]*root.*/aautoindex '${AUTOINDEX}'\;\n'"${ERROR_PAGE}" /etc/nginx/conf.d/default.conf
if test -n "${PHP_PORT}"; then
    sed -i -e 's,^\([ \t]*index .*\);,\1 index.php;,;/^[ \t]*#location ~ \\.php$ {/,/^[ \t]*#}/{s/#//;s/127.0.0.1/php/;/sock/d}' -e 's,^include snippets/fastcgi-php.conf;,include fastcgi.conf;,g' /etc/nginx/conf.d/default.conf
    echo "PHP Enabled"
fi
if test -n "$LDAP_HOST" -a -n "$LDAP_BIND_DN" -a -n "$LDAP_BIND_PASS"; then
    LDAP_PORT=${LDAP_PORT:-389}
    LDAP_BASE_DN="${LDAP_BASE_DN:-dc=${LDAP_HOST//./,dc=}}"
    LDAP_BIND_DN="${LDAP_BIND_DN%${LDAP_BASE_DN}}${LDAP_BASE_DN}"
    sed -i '/location \/ {/a      satisfy any;    auth_request /auth-proxy;' /etc/nginx/conf.d/default.conf
    sed -i 's,location / {,location ${WEB_ROOT} {\n'"${LOCATION_ROOT_RULES}"'\n,' /etc/nginx/conf.d/default.conf
    sed -i '/^}/i  location = /auth-proxy {\n    #internal;\n    fastcgi_param LDAP_HOST "'${LDAP_HOST}'";\n    fastcgi_param LDAP_BASE_DN "'${LDAP_BASE_DN}'";\n    fastcgi_param LDAP_BIND_DN "'${LDAP_BIND_DN}'";\n    fastcgi_param LDAP_BIND_PASS "'${LDAP_BIND_PASS}'";\n    fastcgi_param LDAP_REALM "'${LDAP_REALM}'";\n    include fastcgi.conf;\n    fastcgi_param  SCRIPT_FILENAME    $document_root/index.php;\n    fastcgi_param  SCRIPT_NAME        index.php;\n    fastcgi_pass ldap:9000;\n    fastcgi_pass_request_body off;\n  }' /etc/nginx/conf.d/default.conf
    echo "LDAP Authentication Enabled"
fi

/usr/sbin/nginx

