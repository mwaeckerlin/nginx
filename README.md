NGINX Webserver
===============

Simple nginx webserver with optional LDAP based basic authentictaion. If you need PHP, use [waeckerlin/php-fpm]. To enable LDAP based basic authentication,  link to [mwaeckerlin/ldap-auth].


Port
----

Exposes nginx on port `8080`.


Configuration
-------------

Configuration is done with the following environment variables:

 - `WEB_ROOT_PATH`: Sets the path to the web files, defaults to `/app`.
 
 - `WEB_ROOT`: Path in the url, e.g. to access nginx on http://localhost:8080/mypath, set `-e ENV_WEB_ROOT=/mypath`. Defaults to `/`.
 
 - `MAX_BODY_SIZE`: Set maximum size of http client request body, defaults to `0` (no check).
 
 - `AUTOINDEX`: Flag whether a directory index should be created automatically when no index file exists. Default: `off`.
 
 - `ERROR_PAGE`: Optional rules to setup an error page. Empty by default.
 
 - `LOCATION_ROOT_RULES`: Optional additional rules that are copied inside the location rule. Empty by default.
 
 
Data Path
---------

The files in `WEB_ROOT_PATH` are served by the webserver. You can either copy your web data there, mount a volume to `WEB_ROOT_PATH` or set a different `WEB_ROOT_PATH` and provide your web data there.


### LDAP - Untested

Please note: The LDAP basic authentication feature is untested since a while, so it my or may not work. Open a ticket, if you need it and it does not work.

For LDAP basic authentication, you can either link to a [mwaeckerlin/ldap-auth] container, or configure the following variables:

 - `LDAP_HOST`: LDAP host name
 
 - `LDAP_BASE_DN`: LDAP base distinguished name
 
 - `LDAP_BIND_DN`: Bind distinguished name if authentication is required.
 
 - `LDAP_BIND_PASS`: Bind password if authentication is required.
 
 - `LDAP_REALM`: Arbitrary realm text that is shown to the user at login. Defaults to `Restricted`.
 

Examples
--------

### Simple Example With Default Page

    docker run -it --rm --name myservice -p 8005:8080 mwaeckerlin/nginx

Got to http://localhost:8005. Cleans up when you press `Ctrl+C`.


### Simple Example To Serve A Directory

    docker run -it --rm --name myservice -p 8005:8080 \
               -e AUTOINDEX=on \
               -v ${HOME}:/app:ro \
               mwaeckerlin/nginx

Got to http://localhost:8005. Shows your home directory. Cleans up when you press `Ctrl+C`.


### Example With LDAP Authentication

    docker run -d --name myservice-ldap […] mwaeckerlin/ldap-auth
    docker run -d --name myservice --link myservice-ldap:ldap -p 8005:8080 mwaeckerlin/nginx



[waeckerlin/php-fpm]:    https://hub.docker.com/r/mwaeckerlin/php-fpm   "image in docker hub"
[mwaeckerlin/ldap-auth]: https://hub.docker.com/r/mwaeckerlin/ldap-auth "image in docker hub"
