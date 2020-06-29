#!/bin/sh -e

# @todo to be tested, use with mwaeckerlin/ldap-auth
if test -n "$LDAP_HOST" -a -n "$LDAP_BIND_DN" -a -n "$LDAP_BIND_PASS"; then
    LDAP_PORT=${LDAP_PORT:-389}
    LDAP_BASE_DN="${LDAP_BASE_DN:-dc=${LDAP_HOST//./,dc=}}"
    LDAP_BIND_DN="${LDAP_BIND_DN%${LDAP_BASE_DN}}${LDAP_BASE_DN}"
    if ! grep -q "satisfy any;" /etc/nginx/conf.d/default.conf; then
        sed -i '/location \${WEBROOT} {/a\
    satisfy any;\
    auth_request /auth-proxy;\
' /etc/nginx/conf.d/default.conf
        sed -i '/^}/i\
  location = /auth-proxy {\
    #internal;\
    include         fastcgi_params;\
    fastcgi_param   SCRIPT_FILENAME    $document_root/index.php;\
    fastcgi_param   SCRIPT_NAME        index.php;\
    fastcgi_param   LDAP_HOST          "'${LDAP_HOST}'";\
    fastcgi_param   LDAP_BASE_DN       "'${LDAP_BASE_DN}'";\
    fastcgi_param   LDAP_BIND_DN       "'${LDAP_BIND_DN}'";\
    fastcgi_param   LDAP_BIND_PASS     "'${LDAP_BIND_PASS}'";\
    fastcgi_param   LDAP_REALM         "'${LDAP_REALM}'";\
    fastcgi_pass    ldap:9000;\
    fastcgi_pass_request_body off;\
  }\
' /etc/nginx/conf.d/default.conf
    fi
    echo "**** ldap authentication enabled"
fi

sed -i '/client_max_body_size/d;
        /http *{/a\
  client_max_body_size '${ENV_POST_MAX_SIZE:-${MAX_BODY_SIZE}}'\;
' /etc/nginx/nginx.conf
sed -i 's,\${HTTP_PORT},'"${HTTP_PORT}"',g;
        s,\${WEB_ROOT_PATH},'"${ENV_WEB_ROOT_PATH:-${WEB_ROOT_PATH}}"',g
' /etc/nginx/conf.d/default.conf
if ! grep -q autoindex /etc/nginx/conf.d/default.conf; then
    sed -i '/autoindex/d;
            /^[ \t]*root.*/a\
  autoindex '${AUTOINDEX}'\;\
  '"${ERROR_PAGE}"'
' /etc/nginx/conf.d/default.conf
fi
sed -i 's,location \${WEB_ROOT} {,location '"${WEB_ROOT}"' {\n'"${LOCATION_ROOT_RULES}"'\n,
' /etc/nginx/conf.d/default.conf

echo "**** nginx configuration done"
