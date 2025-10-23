#!/bin/bash
set -e

DATA_DIR="/var/lib/mysql"
SOCKET="/run/mysqld/mysqld.sock"

DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password.txt)
DB_PASSWORD=$(cat /run/secrets/db_password.txt)

INIT_DB=0
if [ ! -d "${DATA_DIR}/mysql" ]; then
	mysql_install_db --user=mysql --datadir="${DATA_DIR}"
	INIT_DB=1
fi

mysqld --user=mysql \
	--datadir="${DATA_DIR}" \
	--skip-networking \
	--socket="${SOCKET}" &
mysql_pid=$!

if [ "${INIT_DB}" -eq 1 ]; then
	until mysqladmin --socket="${SOCKET}" --user=root ping --silent; do
		sleep 1
	done
	MYSQL_AUTH=()
else
	until mysqladmin --socket="${SOCKET}" --user=root --password="${DB_ROOT_PASSWORD}" ping --silent; do
		sleep 1
	done
	MYSQL_AUTH=(--password="${DB_ROOT_PASSWORD}")
fi

mysql --socket="${SOCKET}" --user=root "${MYSQL_AUTH[@]}" <<-SQL
	CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
	CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
	ALTER USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
	GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
	ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
	FLUSH PRIVILEGES;
SQL

mysqladmin --socket="${SOCKET}" --user=root --password="${DB_ROOT_PASSWORD}" shutdown
wait "${mysql_pid}"

exec mysqld --user=mysql --datadir="${DATA_DIR}"