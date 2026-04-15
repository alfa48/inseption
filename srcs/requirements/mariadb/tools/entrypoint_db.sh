#!/bin/bash
set -e

echo "Iniciando verificação do MariaDB..."

# Ler secrets
# Ler secrets (usar caminhos padrão caso as variáveis de ambiente não estejam definidas)
MYSQL_ROOT_PASSWORD_FILE=${MYSQL_ROOT_PASSWORD_FILE:-/run/secrets/db_root_password}
MYSQL_PASSWORD_FILE=${MYSQL_PASSWORD_FILE:-/run/secrets/db_password}

if [ -f "$MYSQL_ROOT_PASSWORD_FILE" ]; then
    MYSQL_ROOT_PASSWORD=$(cat "$MYSQL_ROOT_PASSWORD_FILE")
fi

if [ -f "$MYSQL_PASSWORD_FILE" ]; then
    MYSQL_PASSWORD=$(cat "$MYSQL_PASSWORD_FILE")
fi

# Garantir diretórios necessários
mkdir -p /var/run/mysqld
chown -R mysql:mysql /var/run/mysqld

mkdir -p /var/log/mysql
chown -R mysql:mysql /var/log/mysql

# Verificar se já foi inicializado
if [ ! -f "/var/lib/mysql/.setup_done" ]; then
    echo "Iniciando configuração de primeira execução..."

    if [ ! -d "/var/lib/mysql/mysql" ]; then
        mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null
    fi

    echo "Iniciando MariaDB temporário..."
    mysqld --skip-networking --socket=/var/run/mysqld/mysqld.sock --user=mysql &
    pid="$!"

    echo "Aguardando MariaDB..."
    until mysqladmin --socket=/var/run/mysqld/mysqld.sock ping >/dev/null 2>&1; do
        sleep 1
    done

    echo "Configurando banco..."

    mysql --socket=/var/run/mysqld/mysqld.sock -u root <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

    echo "Parando MariaDB temporário..."
    mysqladmin --socket=/var/run/mysqld/mysqld.sock -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown

    wait "$pid" || true

    touch /var/lib/mysql/.setup_done
    echo "Configuração concluída!"
else
    echo "Ficheiro .setup_done encontrado — pulando configuração"
fi

echo "Iniciando MariaDB (modo otimizado)..."
exec mysqld --user=mysql \
    --datadir=/var/lib/mysql \
    --socket=/var/run/mysqld/mysqld.sock \
    --bind-address=0.0.0.0 \
    --port=3306 \
    --innodb-buffer-pool-size=32M \
    --innodb-log-file-size=16M \
    --innodb-flush-log-at-trx-commit=2 \
    --max_connections=10 \
    --skip-name-resolve \
    --performance_schema=OFF