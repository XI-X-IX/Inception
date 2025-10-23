#!/bin/sh

MYSQL_PASSWORD=$(cat /run/secrets/db_password.txt)
USER2_PASSWORD=$(cat /run/secrets/user2_password.txt)
WP_ADMIN_PASSWORD=$(cat /run/secrets/admin_password.txt)

# attend que la DB se lance
until mysqladmin --host=mariadb --user="${MYSQL_USER}" --password="${MYSQL_PASSWORD}" ping --silent; do
  echo "[wordpress] waiting for mariadb..."
  sleep 1
done

if [ ! -f /var/www/wordpress/wp-config.php ]; then
    echo "Creating wp-config.php..." | tee /var/log/wp-setup.log

    wp --allow-root config create \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${MYSQL_PASSWORD}" \
        --dbhost="mariadb:3306" \
        --path='/var/www/wordpress'

    wp --allow-root core install \
        --url="${WP_URL}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --path='/var/www/wordpress'

    wp --allow-root user create "${WP_SECOND_USER}" "${WP_SECOND_EMAIL}" \
        --user_pass="${USER2_PASSWORD}" \
        --role=editor \
        --path='/var/www/wordpress'
fi

exec "$@"