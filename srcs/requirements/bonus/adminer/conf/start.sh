#!/bin/bash
set -e

# Lance PHP-FPM en arrière-plan (nécessaire pour traiter le .php d'Adminer)
/usr/sbin/php-fpm7.4 -D

# Lance Nginx en PID 1 (foreground)
exec nginx -g "daemon off;"