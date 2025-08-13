FROM alpine:3.21.3

RUN apk add --no-cache \
    php83 php83-fpm php83-mysqli php83-pdo php83-pdo_mysql \
    php83-zip php83-gd php83-intl php83-mbstring php83-xml \
    php83-curl php83-fileinfo php83-tokenizer php83-xmlwriter \
    php83-simplexml php83-session php83-iconv \
    php83-phar \
    wget unzip mariadb-client curl netcat-openbsd bash \
    && ln -sf /usr/bin/php83 /usr/bin/php \
    && ln -sf /usr/sbin/php-fpm83 /usr/sbin/php-fpm

RUN if ! id www-data > /dev/null 2>&1; then \
        adduser -u 82 -D -S -G www-data www-data; \
    fi

RUN mkdir -p /var/www/html /var/log/php83 /var/run/php-fpm83 \
    && chown -R www-data:www-data /var/www/html /var/run/php-fpm83 /var/log/php83

RUN ln -sf /usr/bin/php83 /usr/bin/php \
    && ln -sf /usr/sbin/php-fpm83 /usr/sbin/php-fpm

RUN mkdir -p /var/www/html \
    && chown -R www-data:www-data /var/www/html

RUN wget https://wordpress.org/wordpress-6.8.1.zip -O /tmp/wordpress.zip \
    && unzip /tmp/wordpress.zip -d /tmp \
    && cp -r /tmp/wordpress/* /var/www/html/ \
    && rm -rf /tmp/wordpress.zip /tmp/wordpress \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

RUN mkdir -p /var/log/php83 \
    && mkdir -p /var/run/php-fpm83 \
    && chown -R www-data:www-data /var/run/php-fpm83 \
    && chown -R www-data:www-data /var/log/php83

COPY tools/setup.sh /usr/local/bin/setup.sh
COPY conf/www.conf /etc/php83/php-fpm.d/www.conf

RUN chmod +x /usr/local/bin/setup.sh

WORKDIR /var/www/html

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/setup.sh"]
