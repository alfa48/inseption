FROM debian:bookworm

# instalar MariaDB
RUN apt-get -o Acquire::ForceIPv4=true update && \
    apt-get install -y mariadb-server && \
    rm -rf /var/lib/apt/lists/*

# Criar diretórios necessários
RUN mkdir -p /var/run/mysqld /var/log/mysql && \
    chown -R mysql:mysql /var/run/mysqld /var/log/mysql && \
    chmod 755 /var/run/mysqld

# Copiar configs
COPY conf/mariadb_server.cnf /etc/mysql/mariadb.conf.d/
COPY tools/entrypoint_db.sh /usr/local/bin/

# Permissões
RUN chmod +x /usr/local/bin/entrypoint_db.sh

EXPOSE 3306
ENTRYPOINT ["entrypoint_db.sh"]