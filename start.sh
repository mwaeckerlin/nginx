#!/bin/sh -e

/config-nginx.sh
echo "**** starting nginx"
/usr/sbin/nginx
