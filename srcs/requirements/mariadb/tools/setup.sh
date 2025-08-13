#!/bin/sh

echo "Starting MariaDB setup..."

mkdir -p /run/mysqld
mkdir -p /var/lib/mysql

chown -R mysql:mysql /run/mysqld
chown -R mysql:mysql /var/lib/mysql

if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB..."
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql --skip-test-db
fi

echo "Starting MariaDB server temporarily for setup..."
mariadbd --user=mysql --datadir=/var/lib/mysql --skip-grant-tables --skip-networking=0 --bind-address=0.0.0.0 &
MYSQL_PID=$!

echo "Waiting for MariaDB to start..."
sleep 10
while ! mariadb-admin ping --silent 2>/dev/null; do
    echo "Still waiting..."
    sleep 2
done

echo "MariaDB is ready, configuring database..."

mariadb -u root << EOF
FLUSH PRIVILEGES;

DELETE FROM mysql.user WHERE User='';

ALTER USER 'root'@'localhost' IDENTIFIED BY '$(cat /run/secrets/mysql_root_password)';

CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE;

CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$(cat /run/secrets/mysql_user_password)';
GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';

FLUSH PRIVILEGES;
EOF

echo "Database configured successfully!"

echo "Stopping temporary MariaDB..."
kill $MYSQL_PID
wait $MYSQL_PID 2>/dev/null

echo "Starting MariaDB in normal mode..."
exec mariadbd --user=mysql --console --bind-address=0.0.0.0
