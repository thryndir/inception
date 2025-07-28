#!/bin/sh

WP_PATH=${WP_PATH:-/var/www/html}
DB_HOST=${DB_HOST:-mariadb}

echo "Starting WordPress setup..."

# Attendre MariaDB
until nc -z "$DB_HOST" 3306; do sleep 2; done
until mysql -h"$DB_HOST" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE" -e "SELECT 1;" >/dev/null 2>&1; do sleep 2; done

# Configuration (comme avant)
if [ ! -f "$WP_PATH/wp-config.php" ]; then
    wp config create --dbname="$MYSQL_DATABASE" --dbuser="$MYSQL_USER" --dbpass="$MYSQL_PASSWORD" --dbhost="$DB_HOST" --path="$WP_PATH" --allow-root
fi

if ! wp core is-installed --path="$WP_PATH" --allow-root 2>/dev/null; then
    wp core install --url="$WP_URL" --title="$WP_TITLE" --admin_user="$WP_ADMIN" --admin_password="$WP_ADMIN_PASS" --admin_email="$WP_ADMIN_MAIL" --path="$WP_PATH" --allow-root
fi

if [ -n "$WP_USER" ]; then
    wp user create "$WP_USER" "$WP_MAIL" --role=editor --user_pass="$WP_PASS" --path="$WP_PATH" --allow-root 2>/dev/null || echo "User exists"
fi

exec php-fpm
