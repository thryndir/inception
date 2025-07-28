FROM alpine:3.21.3

RUN apk update && apk add --no-cache nginx openssl

RUN adduser -D -g 'www' www

RUN mkdir /www && \
    chown -R www:www /var/lib/nginx && \
    chown -R www:www /www

COPY conf/nginx.conf /etc/nginx/nginx.conf

RUN mkdir -p /etc/nginx/certs && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/certs/lgalloux.42.fr.key \
    -out /etc/nginx/certs/lgalloux.42.fr.crt \
    -subj "/C=FR/ST=Paris/L=Paris/O=42/OU=42/CN=lgalloux.42.fr"

RUN chmod 600 /etc/nginx/certs/lgalloux.42.fr.key && \
    chmod 644 /etc/nginx/certs/lgalloux.42.fr.crt

RUN ls -la /etc/nginx/certs/

WORKDIR /www

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]
