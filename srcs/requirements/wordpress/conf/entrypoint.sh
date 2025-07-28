#!/bin/sh

WP_PATH=${WP_PATH:-/var/www/html}
DB_HOST=${DB_HOST:-mariadb}

echo "Starting WordPress setup..."

MYSQL_PASSWORD=$(cat /run/secrets/mysql_user_password)
WP_ADMIN_PASS=$(cat /run/secrets/wp_admin_password)
WP_PASS=$(cat /run/secrets/wp_user_password)

if [ -z "$MYSQL_PASSWORD" ] || [ -z "$WP_ADMIN_PASS" ] || [ -z "$WP_PASS" ]; then
    echo "Error: WordPress secrets not found!"
    exit 1
fi

until nc -z "$DB_HOST" 3306; do 
    echo "Waiting for MariaDB..."
    sleep 3
done

until mysql -h"$DB_HOST" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE" -e "SELECT 1;" >/dev/null 2>&1; do 
    echo "Waiting for MariaDB connection..."
    sleep 5
done

echo "MariaDB is ready, configuring WordPress..."

if [ ! -f "$WP_PATH/wp-config.php" ]; then
    echo "Creating wp-config.php..."
    wp config create --dbname="$MYSQL_DATABASE" --dbuser="$MYSQL_USER" --dbpass="$MYSQL_PASSWORD" --dbhost="$DB_HOST" --path="$WP_PATH" --allow-root
fi

if ! wp core is-installed --path="$WP_PATH" --allow-root 2>/dev/null; then
    echo "Installing WordPress..."
    wp core install --url="$WP_URL" --title="$WP_TITLE" --admin_user="$WP_ADMIN" --admin_password="$WP_ADMIN_PASS" --admin_email="$WP_ADMIN_MAIL" --path="$WP_PATH" --allow-root
fi

if [ -n "$WP_USER" ]; then
    echo "Creating additional user..."
    wp user create "$WP_USER" "$WP_MAIL" --role=editor --user_pass="$WP_PASS" --path="$WP_PATH" --allow-root 2>/dev/null || echo "User already exists"
fi

echo "WordPress setup complete!"

exec php-fpm
