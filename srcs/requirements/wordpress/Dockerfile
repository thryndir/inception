FROM php:8.3-fpm-alpine

RUN apk add --no-cache \
    wget unzip mariadb-client curl \
    libpng-dev libjpeg-turbo-dev freetype-dev libzip-dev bash

RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install mysqli pdo pdo_mysql zip gd

RUN wget https://wordpress.org/wordpress-6.8.1.zip -O /tmp/wordpress.zip \
    && unzip /tmp/wordpress.zip -d /tmp \
    && mv /tmp/wordpress/* /var/www/html \
    && rm -rf /tmp/wordpress /tmp/wordpress.zip

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

COPY conf/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

RUN chown -R www-data:www-data /var/www/html

USER www-data

EXPOSE 9000
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
