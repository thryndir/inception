#!/bin/sh

# Créer les répertoires nécessaires
mkdir -p /var/lib/mysql /run/mysqld
chown -R mysql:mysql /var/lib/mysql /run/mysqld

# Initialiser MariaDB si pas encore fait
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql --auth-root-authentication-method=normal
fi

# Démarrer MariaDB temporairement pour la configuration
echo "Starting MariaDB for initial setup..."
mysqld_safe --user=mysql --datadir=/var/lib/mysql --skip-networking &

# Attendre que MariaDB soit prêt
echo "Waiting for MariaDB to start..."
while ! mysqladmin ping --silent; do
    sleep 1
done

echo "MariaDB is ready, configuring..."

# Configuration initiale - CORRIGER ICI
mysql -u root << EOF
-- Définir le mot de passe root
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';

-- Supprimer les utilisateurs anonymes et base test
DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';

-- Créer la base de données
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;

-- Créer l'utilisateur avec les bonnes permissions
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'localhost' IDENTIFIED BY '${MYSQL_PASSWORD}';
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'localhost';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';

-- Permettre les connexions root depuis le réseau (optionnel)
CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;

FLUSH PRIVILEGES;

-- Vérifier que l'utilisateur a été créé
SELECT User, Host FROM mysql.user WHERE User = '${MYSQL_USER}';
EOF

echo "MariaDB configured successfully!"

# Arrêter MariaDB temporaire
mysqladmin -u root -p${MYSQL_ROOT_PASSWORD} shutdown

# Démarrer MariaDB normalement avec écoute réseau
echo "Starting MariaDB server..."
exec mysqld --user=mysql --datadir=/var/lib/mysql --bind-address=0.0.0.0 --port=3306
