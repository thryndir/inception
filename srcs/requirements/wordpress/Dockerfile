FROM php:8.3-fpm-alpine

# Installation des paquets nécessaires
RUN apk add --no-cache \
    wget unzip mariadb-client curl netcat-openbsd \
    libpng-dev libjpeg-turbo-dev freetype-dev libzip-dev bash

# Installation des extensions PHP
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install mysqli pdo pdo_mysql zip gd

# Créer le dossier et définir les permissions AVANT de télécharger
RUN mkdir -p /var/www/html && chown -R www-data:www-data /var/www/html

# Télécharger WordPress dans le bon dossier
RUN wget https://wordpress.org/wordpress-6.8.1.zip -O /tmp/wordpress.zip \
    && unzip /tmp/wordpress.zip -d /tmp \
    && cp -r /tmp/wordpress/* /var/www/html/ \
    && rm -rf /tmp/wordpress.zip /tmp/wordpress \
    && chown -R www-data:www-data /var/www/html

# Installer WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Script de démarrage
COPY tools/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

# Configuration PHP-FPM
COPY conf/www.conf /usr/local/etc/php-fpm.d/www.conf

WORKDIR /var/www/html

EXPOSE 9000

CMD ["/usr/local/bin/setup.sh"]
