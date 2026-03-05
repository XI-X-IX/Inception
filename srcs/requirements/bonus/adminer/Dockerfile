FROM debian:bullseye

RUN apt-get update && \
    apt-get install -y \
        php7.4-fpm \
        php7.4-mysql \
        curl \
        nginx && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Adminer est un seul fichier PHP — interface web pour gérer MariaDB
RUN mkdir -p /var/www/adminer && \
    curl -o /var/www/adminer/index.php \
        https://www.adminer.org/latest.php && \
    chown -R www-data:www-data /var/www/adminer

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/start.sh   /start.sh
RUN chmod +x /start.sh

EXPOSE 8080

CMD ["/start.sh"]