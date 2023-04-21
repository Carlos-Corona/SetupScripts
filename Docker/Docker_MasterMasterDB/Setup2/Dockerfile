# Dockerfile
FROM mariadb:10.5

RUN echo "bind-address = 0.0.0.0" >> /etc/mysql/mariadb.conf.d/50-server.cnf
COPY ./my.cnf /etc/mysql/mariadb.conf.d/99-replication.cnf
