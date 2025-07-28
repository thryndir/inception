FROM alpine:3.21.3

# Installer nginx ET openssl en même temps
RUN apk update && apk add --no-cache nginx openssl

# Créer l'utilisateur www
RUN adduser -D -g 'www' www

# Créer les répertoires nginx
RUN mkdir /www && \
    chown -R www:www /var/lib/nginx && \
    chown -R www:www /www

# Copier la configuration AVANT de générer les certificats
COPY conf/nginx.conf /etc/nginx/nginx.conf

# Générer les certificats SSL APRÈS l'installation de nginx
RUN mkdir -p /etc/nginx/certs && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/certs/privkey.pem \
    -out /etc/nginx/certs/fullchain.pem \
    -subj "/C=FR/ST=Paris/L=Paris/O=42/OU=42/CN=lgalloux.42.fr"

# Vérifier que les certificats existent
RUN ls -la /etc/nginx/certs/

WORKDIR /www

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]
