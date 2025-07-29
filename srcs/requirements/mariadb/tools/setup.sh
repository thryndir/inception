#!/bin/sh

echo "Starting MariaDB setup..."

# Créer les dossiers nécessaires
mkdir -p /run/mysqld
mkdir -p /var/lib/mysql

# Fix permissions (en tant que root dans le container)
chown -R mysql:mysql /run/mysqld
chown -R mysql:mysql /var/lib/mysql

# Initialiser MariaDB si pas déjà fait
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB..."
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql --skip-test-db
fi

echo "Starting MariaDB server temporarily for setup..."
mariadbd --user=mysql --datadir=/var/lib/mysql --skip-grant-tables --skip-networking=0 --bind-address=0.0.0.0 &
MYSQL_PID=$!

# Attendre que MariaDB soit prêt
echo "Waiting for MariaDB to start..."
sleep 10
while ! mariadb-admin ping --silent 2>/dev/null; do
    echo "Still waiting..."
    sleep 2
done

echo "MariaDB is ready, configuring database..."

# Configuration avec les nouveaux noms de commandes
mariadb -u root << EOF
FLUSH PRIVILEGES;

-- Nettoyer les utilisateurs anonymes
DELETE FROM mysql.user WHERE User='';

-- Définir le mot de passe root
ALTER USER 'root'@'localhost' IDENTIFIED BY '$(cat /run/secrets/mysql_root_password)';

-- Créer la base de données
CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE;

-- Créer l'utilisateur avec accès réseau
CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$(cat /run/secrets/mysql_user_password)';
GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';

FLUSH PRIVILEGES;
EOF

echo "Database configured successfully!"

# Arrêter MariaDB
echo "Stopping temporary MariaDB..."
kill $MYSQL_PID
wait $MYSQL_PID 2>/dev/null

echo "Starting MariaDB in normal mode..."
exec mariadbd --user=mysql --console --bind-address=0.0.0.0
