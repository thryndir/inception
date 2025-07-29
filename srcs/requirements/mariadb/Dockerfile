FROM alpine:3.21.3

RUN apk update && apk add --no-cache mariadb mariadb-client

# Configuration MariaDB
COPY conf/mariadb-server.cnf /etc/my.cnf.d/mariadb-server.cnf

# Script de démarrage
COPY tools/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

EXPOSE 3306

CMD ["/usr/local/bin/setup.sh"]
