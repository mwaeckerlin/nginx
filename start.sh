#!/bin/bash -e

cp /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default
sed -i '/client_max_body_size/d;/http *{/aclient_max_body_size '${MAX_BODY_SIZE}'\;' /etc/nginx/nginx.conf
sed -i '/autoindex/d;s,^\([ \t]*root[ \t]*\).*$,\1'${WEB_ROOT_PATH}';,;/^[ \t]*root.*/aautoindex '${AUTOINDEX}'\;' /etc/nginx/sites-enabled/default
if test -n "${PHP_PORT}"; then
    sed -i -e '/^[ \t]*#location ~ \\.php$ {/,/^[ \t]*#}/{s/#//;s/127.0.0.1/php/;/sock/d}' -e 's,^include snippets/fastcgi-php.conf;,include fastcgi.conf;,g' /etc/nginx/sites-enabled/default
    echo "PHP Enabled"
fi
if test -n "${LDAP_PORT}" -a -n "$LDAP_HOST" -a -n "$LDAP_BIND_DN" -a -n "$LDAP_BIND_PASS"; then
    LDAP_BASE_DN="${LDAP_BASE_DN:-dc=${LDAP_HOST//./,dc=}}"
    LDAP_BIND_DN="${LDAP_BIND_DN%${LDAP_BASE_DN}}${LDAP_BASE_DN}"
    sed -i '/location \/ {/a      satisfy any;    auth_request /auth-proxy;' /etc/nginx/sites-enabled/default
    sed -i 's,location / {,location ${WEB_ROOT} {,' /etc/nginx/sites-enabled/default
    sed -i '/^}/i  location = /auth-proxy {\n    #internal;\n    fastcgi_param LDAP_HOST "'${LDAP_HOST}'";\n    fastcgi_param LDAP_BASE_DN "'${LDAP_BASE_DN}'";\n    fastcgi_param LDAP_BIND_DN "'${LDAP_BIND_DN}'";\n    fastcgi_param LDAP_BIND_PASS "'${LDAP_BIND_PASS}'";\n    fastcgi_param LDAP_REALM "'${LDAP_REALM}'";\n    include fastcgi.conf;\n    fastcgi_param  SCRIPT_FILENAME    $document_root/index.php;\n    fastcgi_param  SCRIPT_NAME        index.php;\n    fastcgi_pass ldap:9000;\n    fastcgi_pass_request_body off;\n  }' /etc/nginx/sites-enabled/default
    echo "LDAP Authentication Enabled"
fi
/usr/sbin/nginx
