#!/bin/sh

if [ ! -f /etc/nginx/ssl/inception.crt ]; then
  mkdir -p /etc/nginx/ssl
  openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/inception.key \
    -out /etc/nginx/ssl/inception.crt \
    -subj "/C=CH/ST=VD/L=Lausanne/O=42/OU=42/CN=${DOMAIN_NAME}"
fi

exec "$@"
