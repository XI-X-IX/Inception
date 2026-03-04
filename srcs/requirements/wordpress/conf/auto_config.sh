#!/bin/bash
set -e

MYSQL_PASSWORD=$(cat /run/secrets/db_password.txt)
USER2_PASSWORD=$(cat /run/secrets/user2_password.txt)
WP_ADMIN_PASSWORD=$(cat /run/secrets/admin_password.txt)

# Attend que MariaDB soit disponible avant de continuer
until mysqladmin --host=mariadb --user="${MYSQL_USER}" --password="${MYSQL_PASSWORD}" ping --silent; do
    echo "[wordpress] Attente de MariaDB..."
    sleep 2
done

# Configure WordPress seulement si pas encore fait
if [ ! -f /var/www/wordpress/wp-config.php ]; then
    echo "[wordpress] Premier démarrage - configuration..."

    # Crée le fichier wp-config.php
    wp --allow-root config create \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${MYSQL_PASSWORD}" \
        --dbhost="mariadb:3306" \
        --path='/var/www/wordpress'

    # Installe WordPress
    wp --allow-root core install \
        --url="${WP_URL}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --path='/var/www/wordpress'

    # Crée un second utilisateur (éditeur)
    wp --allow-root user create "${WP_SECOND_USER}" "${WP_SECOND_EMAIL}" \
        --user_pass="${USER2_PASSWORD}" \
        --role=editor \
        --path='/var/www/wordpress'

    # Active le plugin Redis pour le cache
    wp --allow-root plugin install redis-cache --activate --path='/var/www/wordpress'

    # Configure Redis dans wp-config.php
    wp --allow-root config set WP_REDIS_HOST redis --path='/var/www/wordpress'
    wp --allow-root config set WP_REDIS_PORT 6379 --raw --path='/var/www/wordpress'

    # Active le cache Redis
    wp --allow-root redis enable --path='/var/www/wordpress'

    echo "[wordpress] Configuration terminée ✓"
fi

# Lance PHP-FPM en PID 1
exec "$@"