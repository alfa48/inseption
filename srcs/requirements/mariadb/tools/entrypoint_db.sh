#!/bin/bash

set -e

echo "Iniciando MariaDB..."

# Garantir diretórios necessários
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

mkdir -p /var/log/mysql
chown -R mysql:mysql /var/log/mysql

# Verificar se já foi inicializado
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Primeira inicialização do banco..."

    mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null

    echo "Iniciando MariaDB temporário..."
    mysqld --skip-networking --socket=/run/mysqld/mysqld.sock --user=mysql &
    pid="$!"

    echo "Aguardando MariaDB..."
    until mysqladmin --socket=/run/mysqld/mysqld.sock ping >/dev/null 2>&1; do
        sleep 1
    done

    echo "Configurando banco..."

    mysql --socket=/run/mysqld/mysqld.sock -u root << EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

    echo "Parando MariaDB temporário..."
    mysqladmin --socket=/run/mysqld/mysqld.sock -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown

    wait "$pid" || true

    echo "Configuração concluída!"
else
    echo "Banco já inicializado — pulando configuração"
fi

# Iniciar MariaDB normalmente
echo "🚀 Iniciando MariaDB (modo normal)..."
exec mysqld --user=mysql --datadir=/var/lib/mysql --socket=/run/mysqld/mysqld.sock