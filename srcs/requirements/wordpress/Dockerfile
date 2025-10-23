FROM debian:bullseye

# Installation des packages nécessaires
RUN apt-get update && \
    apt-get install -y \
    php7.4-fpm \
    php7.4-mysql \
    curl \
    default-mysql-client && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Téléchargement et installation de WordPress
RUN mkdir -p /var/www && \
    curl -O https://wordpress.org/latest.tar.gz && \
    tar -xzf latest.tar.gz -C /var/www/ && \
    rm latest.tar.gz && \
    chown -R www-data:www-data /var/www/wordpress

# Configuration PHP-FPM
RUN mkdir -p /run/php && \
    sed -i 's|^;*clear_env =.*|clear_env = no|' /etc/php/7.4/fpm/pool.d/www.conf && \
    sed -i 's|^listen = .*|listen = 0.0.0.0:9000|' /etc/php/7.4/fpm/pool.d/www.conf
# Installation WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

WORKDIR /var/www/wordpress

COPY conf/auto_config.sh /auto_config.sh
RUN chmod +x /auto_config.sh

ENTRYPOINT ["/auto_config.sh"]
CMD ["/usr/sbin/php-fpm7.4", "-F"]