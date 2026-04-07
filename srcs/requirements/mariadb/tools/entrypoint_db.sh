#!/bin/bash

# Script de entrada para inicializar o MariaDB, criar banco de dados e usuários

set -e

echo "Iniciando inicialização do MariaDB..."

# Inicializar diretório de dados MySQL se não existir
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Inicializando diretório de dados..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null
fi

# Iniciar o servidor (sem rede para configuração)
echo "Iniciando servidor MariaDB temporário para configuração..."
mysqld --skip-networking --socket=/run/mysqld/mysqld.sock --user=mysql &
pid="$!"

# Aguardar o MariaDB estar pronto
echo "Aguardando o MariaDB estar pronto..."
until mysqladmin --socket=/run/mysqld/mysqld.sock ping >/dev/null 2>&1; do
    sleep 1
done
echo "MariaDB está pronto!"

# Executar SQL de configuração: criar banco de dados e usuários
echo "Executando SQL de configuração..."
mysql --socket=/run/mysqld/mysqld.sock -u root << EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

# Desligar servidor temporário
echo "Desligando MariaDB temporário..."
mysqladmin --socket=/run/mysqld/mysqld.sock -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown

# Aguardar desligamento
wait "$pid" || true

# Iniciar MariaDB normalmente (com rede)
echo "Inicialização completa. Iniciando MariaDB..."
exec mysqld --user=mysql --datadir=/var/lib/mysql --socket=/run/mysqld/mysqld.sock