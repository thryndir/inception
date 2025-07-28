FROM alpine:3.21.3

RUN apk update && apk add mariadb mariadb-client

COPY conf/mariadb-server.cnf /etc/my.cnf.d/mariadb-server.cnf

RUN mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld

RUN mkdir -p /var/lib/mysql && chown -R mysql:mysql /var/lib/mysql

COPY conf/init.sh /init.sh
RUN chmod +x /init.sh

EXPOSE 3306

CMD ["/init.sh"]
