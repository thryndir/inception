#!/bin/bash

echo "Starting WordPress setup..."

echo "Waiting for MariaDB..."
while ! nc -z mariadb 3306; do
    echo "Waiting for MariaDB to be ready..."
    sleep 2
done

sleep 15
echo "MariaDB is ready!"

cd /var/www/html

if [ ! -f "wp-config-sample.php" ]; then
    echo "WordPress files missing, downloading..."
    wget https://wordpress.org/wordpress-6.8.1.zip -O /tmp/wordpress.zip
    unzip /tmp/wordpress.zip -d /tmp
    cp -r /tmp/wordpress/* .
    rm -rf /tmp/wordpress.zip /tmp/wordpress
    chown -R www-data:www-data /var/www/html
fi

echo "Testing database connection..."
for i in {1..10}; do
    if mysql -h"$DB_HOST" -u"$MYSQL_USER" -p"$(cat /run/secrets/mysql_user_password)" "$MYSQL_DATABASE" -e "SELECT 1;" > /dev/null 2>&1; then
        echo "Database connection successful!"
        break
    else
        echo "Database connection failed, retry $i/10..."
        sleep 5
    fi
done

if [ ! -f wp-config.php ]; then
    echo "Creating wp-config.php..."
    wp config create \
        --dbname="$MYSQL_DATABASE" \
        --dbuser="$MYSQL_USER" \
        --dbpass="$(cat /run/secrets/mysql_user_password)" \
        --dbhost="$DB_HOST" \
        --allow-root
fi

if ! wp core is-installed --allow-root 2>/dev/null; then
    echo "Installing WordPress..."
    wp core install \
        --url="$WP_URL" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN" \
        --admin_password="$(cat /run/secrets/wp_admin_password)" \
        --admin_email="$WP_ADMIN_MAIL" \
        --allow-root
        
    echo "Creating additional user..."
    wp user create "$WP_USER" "$WP_MAIL" \
        --user_pass="$(cat /run/secrets/wp_user_password)" \
        --role=author \
        --allow-root
else
    echo "WordPress already installed"
fi

echo "WordPress setup complete!"

chown -R www-data:www-data /var/www/html
find /var/www/html -type d -exec chmod 755 {} \;
find /var/www/html -type f -exec chmod 644 {} \;

exec php-fpm83 --nodaemonize --fpm-config /etc/php83/php-fpm.conf
