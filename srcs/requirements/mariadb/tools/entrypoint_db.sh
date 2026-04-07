Ir para o conteúdo
Comunidade DEV
Find related posts...
Desenvolvido por Algolia 
Conecte-se
Criar uma conta

0
Ir para os comentários

2
Salvar

Impulsionar

alejiri
alejiri
Publicado em16/10/2025 • Editado em03/11/2025



2


1


1


2
Tutorial de Docker NGINX + WordPress + MariaDB - Inception42
#
desenvolvimento web
#
docker
#
WordPress
#
programação
Um tutorial completo, passo a passo e aprofundado sobre MVPs.
Como parte da minha jornada de aprendizado de programação na 42Berlin, criei este tutorial para compartilhar minha experiência com meus colegas e outras pessoas que possam se beneficiar dele.

Este tutorial segue as especificações do projeto Inception e irá guiá-lo pelos conceitos básicos do Docker.

O que você vai construir
Ao final deste tutorial, você terá:

✅ Proxy reverso NGINX com criptografia TLS
✅ WordPress com PHP-FPM
✅ Banco de dados MariaDB
✅ Redes e volumes do Docker
Parte 1: Compreendendo os Fundamentos
O que é Docker?
Pense no Docker como uma mini-máquina virtual capaz de executar um aplicativo ou serviço. É isso que chamamos de contêiner. A ideia é ter cada aplicativo rodando em um único contêiner. Para cada contêiner que executa um aplicativo, temos uma receita, o Dockerfile. E a receita para coordenar vários contêineres é chamada de Docker Compose.

Os contêineres Docker empacotam sua aplicação com tudo o que ela precisa para ser executada de forma consistente em diferentes ambientes.

Questão para reflexão : Se você tivesse que explicar o Docker para um amigo sem conhecimento técnico em uma frase, o que você diria?

Docker vs. Máquinas Virtuais
Aspecto	Contêineres Docker	Máquinas Virtuais
Utilização de recursos	Compartilhar kernel do sistema operacional host	Cada máquina virtual possui um sistema operacional completo.
Hora de inicialização	Segundos	Minutos
Memória	MB	GB
Portabilidade	Alto	Médio
Pense nisso : por que você escolheria contêineres em vez de máquinas virtuais para uma aplicação web?

Parte 2: Preparando seu ambiente
Pré-requisitos
Máquina virtual (Ubuntu 22.04 ou 24.04 recomendado) com acesso de root ou sudo.
Instalando o Docker
# Update package index
sudo apt update

# Install required packages
sudo apt install apt-transport-https ca-certificates curl gnupg lsb-release

# Add Docker's GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker repository
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Add your user to docker group
sudo usermod -aG docker $USER

# Log out and back in, then test
docker --version
Experimento : Execute docker run hello-worldo comando. O que você acha que ele faz?

Parte 3: Noções básicas de Docker - Elementos fundamentais
Compreendendo os conceitos-chave
Imagens vs. Contêineres
# List images
docker images

# List running containers
docker ps

# List all containers (including stopped)
docker ps -a
Pergunta : Qual a diferença entre uma imagem e um recipiente? Pense nisso como a diferença entre uma receita e um bolo!

Pergunta 2 : Um contêiner parado é o mesmo que uma imagem Docker?

Seu primeiro contêiner
Para garantir que você possa experimentar o poder do Docker em breve, você pode seguir este exercício que utiliza uma imagem pré-configurada do nginx (proibido para o Inception, mas ótimo para entender o Docker).

# Run a simple nginx container
docker run -d -p 8080:80 --name my-nginx nginx
O que você acha que acontecerá se executar este comando?

O que -dfaz?
O que -p 8080:80significa?
O que --name my-nginxfaz?
Visite o local http://localhost:8080para ver o resultado!

Parte 4: Criando seu primeiro Dockerfile
O que é um Dockerfile?
Um Dockerfile é como uma receita que diz ao Docker como construir sua imagem.

# Simple nginx Dockerfile
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/
EXPOSE 80
Em resumo :

FROMQual imagem base usar como ponto de partida?
COPYCopiar arquivos do host para o contêiner (mesma pasta do Dockerfile)
EXPOSEDocumente qual porta o contêiner utiliza (apenas documente!).
Construindo sua imagem
# Build the image
docker build -t my-custom-nginx .

# Run your custom image
docker run -d -p 8080:80 my-custom-nginx
Experimento : Crie um index.htmlarquivo com seu nome e construa a imagem. O que acontece?

Parte 5: A Arquitetura do Projeto Inception
Antes de começarmos a construir, vamos entender o que estamos criando:

Estrutura do Projeto
inception/
├── Makefile
├── secrets/
│   ├── db_password.txt
│   └── db_root_password.txt
└── srcs/
    ├── docker-compose.yml
    ├── .env
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile
        │   ├── conf/
        │   └── tools/
        ├── nginx/
        │   ├── Dockerfile
        │   ├── conf/
        │   └── tools/
        └── wordpress/
            ├── Dockerfile
            ├── conf/
            └── tools/
Reflexão : Por que você acha que separamos cada serviço em seu próprio diretório?

Parte 6: Configurando redes Docker
Entendendo a rede Docker
# Create a custom network
docker network create inception-network

# List networks
docker network ls

# Inspect the network
docker network inspect inception-network
Pense : Por que não podemos simplesmente usar a rede padrão?

A rede bridge padrão possui limitações:

Os contêineres só podem se comunicar por endereço IP.
Sem resolução automática de DNS
Menos seguro
Experimento : Crie dois contêineres na mesma rede personalizada e tente pingar um do outro usando os nomes dos contêineres.

# Connect a running container
docker network connect inception-network <container_id_or_name>

# Create a httpd apache server connected to the network
docker run --rm --name client --network inception-network -d httpd

# To enter shell
docker exec -it client sh
# If ping is missing
apk add iputils    # For Alpine
apt-get update && apt-get install iputils-ping   # For Debian/Ubuntu

# To get an IP address
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' <container_id_or_name>
Parte 7: Contêiner MariaDB - A Camada de Banco de Dados
Agora é hora de começar a construir Inception. Você pode acessar uma nova pasta para salvar seu trabalho final.

Criando o Dockerfile do MariaDB
FROM debian:bookworm

# Install MariaDB
RUN apt-get update && apt-get install -y \
    mariadb-server \
    && rm -rf /var/lib/apt/lists/*

# Create directories
RUN mkdir -p /var/run/mysqld \
    && chown -R mysql:mysql /var/run/mysqld \
    && chmod 755 /var/run/mysqld

# Copy configuration
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/
COPY tools/init_db.sh /usr/local/bin/

# Set permissions
RUN chmod +x /usr/local/bin/init_db.sh

# Environment variables (can be overridden at runtime)
ENV MYSQL_ROOT_PASSWORD=root \
    MYSQL_DATABASE=app_db \
    MYSQL_USER=app_user \
    MYSQL_PASSWORD=app_pass

EXPOSE 3306

ENTRYPOINT ["init_db.sh"]
Questões para reflexão :

Por que estamos criando /var/run/mysqld?
O que chownfaz?
Por que precisamos de um script de inicialização?
Arquivo de configuração do MariaDB
Criar conf/50-server.cnf:

[mysqld]
bind-address = 0.0.0.0
port = 3306
socket = /var/run/mysqld/mysqld.sock
datadir = /var/lib/mysql
log-error = /var/log/mysql/error.log
pid-file = /var/run/mysqld/mysqld.pid
Pensamento crítico : por que é bind-address = 0.0.0.0importante neste contexto?

Script de inicialização do banco de dados
Criar tools/init_db.sh:

#!/bin/bash

set -e

echo "Starting MariaDB initialization..."

# Initialize MySQL data directory if it doesn't exist
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing data directory..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null
fi

# Start the server (no networking for setup)
echo "Starting temporary MariaDB server for setup..."
mysqld --skip-networking --socket=/run/mysqld/mysqld.sock --user=mysql &
pid="$!"

# Wait for MariaDB to be ready
echo "Waiting for MariaDB to be ready..."
until mysqladmin --socket=/run/mysqld/mysqld.sock ping >/dev/null 2>&1; do
    sleep 1
done
echo "MariaDB is ready!"

# Run setup SQL: create database and users
echo "Running setup SQL..."
mysql --socket=/run/mysqld/mysqld.sock -u root << EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

# Shut down temporary server
echo "Shutting down temporary MariaDB..."
mysqladmin --socket=/run/mysqld/mysqld.sock -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown

# Wait for shutdown
wait "$pid" || true

# Start MariaDB normally (with networking)
echo "Initialization complete. Starting MariaDB..."
exec mysqld --user=mysql --datadir=/var/lib/mysql --socket=/run/mysqld/mysqld.sock

Pergunta do experimento : O que aconteceria se não esperássemos o MySQL iniciar antes de criar o banco de dados?

# To check if socket file exist on container
docker exec -it <container_id_or_name> ls -l /run/mysqld/mysqld.sock

# To check maria db
docker exec -it <container_id_or_name> mysqladmin ping -u root -p

Parte 8: WordPress com contêiner PHP-FPM
Entendendo o PHP-FPM
O PHP-FPM (FastCGI Process Manager) é uma implementação do PHP perfeita para atender sites com alto tráfego. Ao contrário da execução do PHP como um módulo do Apache, o PHP-FPM é executado como um processo separado.

Por que usar PHP-FPM em vez de Apache com mod_php?

Melhor desempenho sob alta carga
Isolamento de processo separado
Melhor gestão de recursos
Dockerfile do WordPress
FROM debian:bookworm

# Install PHP-FPM and required extensions
RUN apt-get update && apt-get install -y \
  php8.2-fpm \
  php8.2-mysql \
  php8.2-curl \
  php8.2-gd \
  php8.2-intl \
  php8.2-mbstring \
  php8.2-soap \
  php8.2-xml \
  php8.2-zip \
  wget \
  curl \
  && ln -s /usr/sbin/php-fpm8.2 /usr/local/bin/php-fpm \
  && rm -rf /var/lib/apt/lists/*

# Create WordPress directory
WORKDIR /var/www/html

# Copy PHP-FPM configuration (correct version)
COPY conf/www.conf /etc/php/8.2/fpm/pool.d/

# Copy and set permissions for setup script
COPY tools/setup_wordpress.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/setup_wordpress.sh

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/setup_wordpress.sh"]

Reflexão : Por que precisamos de tantas extensões do PHP?

Configuração do PHP-FPM
Criar conf/www.conf:

[www]
user = www-data
group = www-data
listen = 9000
listen.owner = www-data
listen.group = www-data
pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3
Pergunta desafiadora : O que aconteceria se você acessasse pm.max_children = 1um site com muito tráfego?

Script de configuração do WordPress
Criar tools/setup_wordpress.sh:

Observação: Se a variável for usada apenas pelo próprio script , não é necessário usar ` export. Se ela precisar ser acessada por outro processo (por exemplo, PHP, nginx, Python etc.), então você deve exportusá-la.

#!/bin/bash
set -e

WP_PATH="/var/www/html"

# Read password from secret file
if [ -n "$WORDPRESS_DB_PASSWORD_FILE" ] && [ -f "$WORDPRESS_DB_PASSWORD_FILE" ]; then
    WORDPRESS_DB_PASSWORD=$(cat "$WORDPRESS_DB_PASSWORD_FILE")
    export WORDPRESS_DB_PASSWORD
fi

echo "Setting up WordPress..."

# Download and configure WordPress if not present
if [ ! -f "$WP_PATH/wp-config.php" ]; then
    echo "Downloading WordPress..."
    wget -q https://wordpress.org/latest.tar.gz -O /tmp/wordpress.tar.gz
    tar -xzf /tmp/wordpress.tar.gz -C /tmp
    rm /tmp/wordpress.tar.gz

    # Copy only missing files (avoid overwriting existing content)
    cp -rn /tmp/wordpress/* "$WP_PATH" || true
    rm -rf /tmp/wordpress

    # Fetch security salts from WordPress API
    WP_SALTS=$(wget -qO- https://api.wordpress.org/secret-key/1.1/salt/)

    # Create wp-config.php
    cat > "$WP_PATH/wp-config.php" << EOF
<?php
define('DB_NAME', '${WORDPRESS_DB_NAME}');
define('DB_USER', '${WORDPRESS_DB_USER}');
define('DB_PASSWORD', '${WORDPRESS_DB_PASSWORD}');
define('DB_HOST', '${WORDPRESS_DB_HOST}');
define('DB_CHARSET', 'utf8');
define('DB_COLLATE', '');

\$table_prefix = '${WORDPRESS_TABLE_PREFIX:-wp_}';

${WP_SALTS}

define('WP_DEBUG', false);

if ( !defined('ABSPATH') )
    define('ABSPATH', __DIR__ . '/');

require_once ABSPATH . 'wp-settings.php';
EOF

    # Set secure permissions
    find "$WP_PATH" -type d -exec chmod 750 {} \;
    find "$WP_PATH" -type f -exec chmod 640 {} \;
    chown -R www-data:www-data "$WP_PATH"

    echo "WordPress setup complete."
else
    echo "WordPress already initialized, skipping setup."
fi

echo "Starting PHP-FPM..."
exec php-fpm8.2 -F


Experimento : O que você acha que acontece se os arquivos do WordPress já existirem?


# If we want to test wp container we can use this:
docker run -d \
  -e WORDPRESS_DB_HOST=dummyhost \
  -e WORDPRESS_DB_NAME=dummydb \
  -e WORDPRESS_DB_USER=dummyuser \
  -e WORDPRESS_DB_PASSWORD=dummypassword \
  mywp

# Then
docker exec -it docker_id_name cat /var/www/html/wp-config.php


# And then check with:
cat /var/www/html/wp-config.php

Parte 9: NGINX com TLS - A Porta de Entrada
Entendendo o papel do NGINX
O NGINX atua como um proxy reverso, o que significa que ele:

Recebe solicitações de usuários
Encaminha-os para PHP-FPM
Retorna a resposta aos usuários.
Por que não acessar o PHP-FPM diretamente?

O PHP-FPM não lida diretamente com HTTP.
O NGINX lida com arquivos estáticos de forma eficiente.
Terminação SSL
Dockerfile do NGINX
FROM debian:bullseye

# Install nginx and openssl
RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    && rm -rf /var/lib/apt/lists/*

# Ensure nginx runs as www-data with correct UID
RUN usermod -u 33 www-data && groupmod -g 33 www-data

# Create SSL directory
RUN mkdir -p /etc/nginx/ssl

# Copy configuration files
COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY tools/generate_ssl.sh /usr/local/bin/

# Set permissions
RUN chmod +x /usr/local/bin/*.sh

EXPOSE 443

ENTRYPOINT ["/usr/local/bin/generate_ssl.sh"]
Script para geração de certificado SSL
Criar tools/generate_ssl.sh:

#!/bin/bash
set -e

# Ensure SSL directory exists
mkdir -p /etc/nginx/ssl

# Default domain if not provided
: "${DOMAIN_NAME:=localhost}"

# Generate SSL certificate if it doesn't exist
if [ ! -f /etc/nginx/ssl/nginx.crt ]; then
    echo "Generating self-signed SSL certificate for ${DOMAIN_NAME}..."

    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/nginx.key \
        -out /etc/nginx/ssl/nginx.crt \
        -subj "/C=US/ST=State/L=City/O=Organization/CN=${DOMAIN_NAME}"

    chmod 600 /etc/nginx/ssl/nginx.key
    chmod 644 /etc/nginx/ssl/nginx.crt

    echo "SSL certificate generated at /etc/nginx/ssl/"
else
    echo "SSL certificate already exists. Skipping generation."
fi

# Test nginx configuration before starting
echo "Testing nginx configuration..."
nginx -t
echo "Nginx configuration test passed."

# Start nginx in foreground (PID 1)
echo "Starting Nginx..."
exec nginx -g "daemon off;"
Questão de segurança : Por que definimos permissões diferentes para os arquivos de chave e certificado?

Configuração do NGINX
Criar conf/nginx.conf:

user www-data;
events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    server {
        listen 80;
        server_name ${DOMAIN_NAME};
        return 301 https://$host$request_uri;
    }

    server {
        listen 443 ssl http2;
        server_name ${DOMAIN_NAME};

        ssl_certificate /etc/nginx/ssl/nginx.crt;
        ssl_certificate_key /etc/nginx/ssl/nginx.key;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384;

        root /var/www/html;
        index index.php index.html;
        client_max_body_size 64M;

        # Security headers
        add_header X-Frame-Options "SAMEORIGIN";
        add_header X-Content-Type-Options "nosniff";
        add_header X-XSS-Protection "1; mode=block";

        location / {
            try_files $uri $uri/ /index.php?$args;
        }

        location ~ \.php$ {
            fastcgi_pass wordpress:9000;
            fastcgi_index index.php;
            include fastcgi_params;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        }

        location ~ /\.ht {
            deny all;
        }

        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1M;
        access_log off;
        add_header Cache-Control "public";
        }
    }
}
Análise crítica :

Por que fastcgi_passusar wordpress:9000em vez de um endereço IP?
O que try_filesfaz?
# Check certificate
docker exec -it docker_id_name ls /etc/nginx/ssl/
Parte 10: Volumes do Docker - Persistência de Dados
Entendendo os Volumes do Docker
O que acontece aos dados quando um contêiner é excluído?

Sem volumes, todos os dados são perdidos! Os volumes fornecem armazenamento persistente que sobrevive a reinicializações e exclusões de contêineres.

# Create volumes
docker volume create mariadb_data
docker volume create wordpress_data

# Inspect a volume
docker volume inspect mariadb_data
Pense : Onde o Docker armazena os dados de volume no host?

Comparação de Tipos de Volume
Tipo	Caso de uso	Desempenho	Portabilidade
Volumes Nomeados	Bancos de dados, dados de aplicativos	Alto	Alto
Montagens de ligação	Desenvolvimento, registros	Médio	Baixo
Montagens tmpfs	Dados temporários	Mais alto	N / D
Parte 11: Variáveis ​​de Ambiente e Segredos
O Desafio da Segurança
NUNCA faça isso em produção:

ENV MYSQL_ROOT_PASSWORD=supersecret
Em vez disso, use variáveis ​​de ambiente:

Criar .envarquivo:

DOMAIN_NAME=login.42.fr
MYSQL_ROOT_PASSWORD=secure_root_password
MYSQL_DATABASE=wordpress_db
MYSQL_USER=wp_user
MYSQL_PASSWORD=secure_user_password

# WordPress settings
WORDPRESS_DB_NAME=wordpress_db
WORDPRESS_DB_USER=wp_user
WORDPRESS_DB_PASSWORD=secure_user_password
WORDPRESS_DB_HOST=mariadb
WORDPRESS_TABLE_PREFIX=wp_
Boa prática de segurança : Armazene as senhas em arquivos separados:

# Create secrets directory
mkdir -p secrets
echo "root" > secrets/db_root_password.txt
echo "pass" > secrets/db_password.txt

# Set strict permissions
chmod 600 secrets/*
Questão de segurança : Por que as variáveis ​​de ambiente não são ideais para guardar segredos?

Parte 12: Docker Compose - Orquestrando tudo
O que é Docker Compose?
O Docker Compose permite definir e executar aplicações com vários contêineres usando um arquivo YAML.

Criar srcs/docker-compose.yml:

services:
  mariadb:
    build: 
      context: requirements/mariadb
    image: mariadb:inception
    container_name: mariadb
    networks:
      - inception-network
    volumes:
      - mariadb_data:/var/lib/mysql
    environment:
      MYSQL_ROOT_PASSWORD_FILE: /run/secrets/db_root_password
      MYSQL_DATABASE: ${MYSQL_DATABASE}
      MYSQL_USER: ${MYSQL_USER}
      MYSQL_PASSWORD_FILE: /run/secrets/db_password
    secrets:
      - db_root_password
      - db_password
    restart: always

  wordpress:
    build:
      context: requirements/wordpress
    image: wordpress:inception
    container_name: wordpress
    depends_on:
      - mariadb
    networks:
      - inception-network
    volumes:
      - wordpress_data:/var/www/html
    environment:
      WORDPRESS_DB_HOST: mariadb
      WORDPRESS_DB_NAME: ${MYSQL_DATABASE}
      WORDPRESS_DB_USER: ${MYSQL_USER}
      WORDPRESS_DB_PASSWORD_FILE: /run/secrets/db_password
      WORDPRESS_TABLE_PREFIX: wp_
    secrets:
      - db_password
    restart: always

  nginx:
    build:
      context: requirements/nginx
    image: nginx:inception
    container_name: nginx
    depends_on:
      - wordpress
    networks:
      - inception-network
    volumes:
      - wordpress_data:/var/www/html
    environment:
      DOMAIN_NAME: ${DOMAIN_NAME}
    restart: always

networks:
  inception-network:
    driver: bridge

volumes:
  mariadb_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /home/${USER}/data/mariadb
  wordpress_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /home/${USER}/data/wordpress

secrets:
  db_root_password:
    file: ../secrets/db_root_password.txt
  db_password:
    file: ../secrets/db_password.txt
Questões de análise :

Por que wordpressdepende de quê mariadb?
O que restart: alwaysfaz?
Por que os volumes são mapeados para diretórios do host?
# For testing we need to create data folders
mkdir -p /home/user/data/mariadb
mkdir -p /home/user/data/wordpress

Parte 13: O Makefile - Automação
Por que usar um Makefile?
Um Makefile fornece comandos simples para gerenciar seu projeto:

# Variables
COMPOSE_FILE = srcs/docker-compose.yml
DATA_DIR = /home/$(USER)/data

.PHONY: all build up down clean fclean re

all: build up

# Create data directories
$(DATA_DIR)/mariadb:
    mkdir -p $(DATA_DIR)/mariadb

$(DATA_DIR)/wordpress:
    mkdir -p $(DATA_DIR)/wordpress

# Build images
build: $(DATA_DIR)/mariadb $(DATA_DIR)/wordpress
    docker compose -f $(COMPOSE_FILE) build

# Start services
up:
    docker compose -f $(COMPOSE_FILE) up -d

# Stop services
down:
    docker compose -f $(COMPOSE_FILE) down

# Clean containers and images
clean:
    docker compose -f $(COMPOSE_FILE) down
    docker system prune -af

# Full clean including volumes
fclean: clean
    docker volume prune -f
    sudo rm -rf $(DATA_DIR)

# Rebuild everything
re: fclean all
Entendendo o processo de fabricação :

Por que criamos diretórios primeiro?
Parte 14: Testes e Depuração
Teste passo a passo
Criar e iniciar serviços:
make all
Verificar o estado do contêiner:
docker ps
Exercício de depuração : Se um contêiner não estiver em execução, como você investigaria?

# Check container logs
docker logs mariadb
docker logs wordpress
docker logs nginx

# Access container shell
docker exec -it mariadb bash
Testar conexão com o banco de dados:
docker exec -it mariadb mysql -u root -p
Testar o WordPress:
Visite https://login.42.fr(ou seu domínio)

Perguntas para resolução de problemas :

E se você receber a mensagem "conexão recusada"?
E se você vir o nginx, mas não o WordPress?
E se a conexão com o banco de dados falhar?
Problemas comuns e soluções
Emitir	Sintoma	Solução
Conflito portuário	bind: address already in use	Interrompa os serviços conflitantes
Permissão negada	mkdir: cannot create directory	Verificar permissões de arquivo
Problemas de rede	could not connect to mariadb	Verifique a configuração da rede.
Avisos SSL	Aviso de segurança do navegador	Espera-se que os certificados sejam assinados pelo próprio solicitante.
Parte 15: Conceitos Avançados e Melhores Práticas
Entendendo o PID 1
🤔 Por que o PID 1 é especial em contêineres?

Em sistemas Unix, o PID 1 é o processo init que:

Gerencia processos filhos
Gerencia sinais do sistema
Limpa processos zumbis
Pensamento crítico : O que acontece se o seu processo de contêiner não lidar com o sinal SIGTERM?

# Good - process runs as PID 1
ENTRYPOINT ["nginx", "-g", "daemon off;"]

# Bad - shell runs as PID 1
ENTRYPOINT nginx -g "daemon off;"
Parte 16: Montagem Final do Projeto
Estrutura completa do diretório
inception/
├── Makefile
├── secrets/
│   ├── db_password.txt
│   └── db_root_password.txt
└── srcs/
    ├── docker-compose.yml
    ├── .env
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile
        │   ├── conf/
        │   │   └── 50-server.cnf
        │   └── tools/
        │       └── init_db.sh
        ├── nginx/
        │   ├── Dockerfile
        │   ├── conf/
        │   │   └── nginx.conf
        │   └── tools/
        │       └── generate_ssl.sh
        └── wordpress/
            ├── Dockerfile
            ├── conf/
            │   └── www.conf
            └── tools/
                └── setup_wordpress.sh
Lista de verificação final
✅ Requisitos de infraestrutura :

[ ] NGINX somente com TLSv1.2 ou TLSv1.3
[ ] WordPress com php-fpm (sem nginx)
[ ] MariaDB (sem nginx)
[ ] Dois volumes: arquivos de banco de dados e WordPress
[ ] Contêineres de rede Docker
[ ] Os contêineres reiniciam em caso de falha
✅ Requisitos de segurança :

[ ] Sem senhas em Dockerfiles
[ ] Variáveis ​​de ambiente utilizadas
[ ] Segredos devidamente gerenciados
[ ] Nenhum comando proibido (tail -f, sleep infinity, etc.)
✅ Requisitos de arquitetura :

[ ] Cada serviço em contêiner dedicado
[ ] Dockerfiles personalizados (sem usar imagens prontas)
[ ] NGINX como único ponto de entrada na porta 443
[ ] Configuração adequada do nome de domínio
Comandos de inicialização
# Build everything
make all

# Check status
docker ps

# View logs
docker logs nginx
docker logs wordpress
docker logs mariadb

# Test the website
curl -k https://login.42.fr

# Stop everything
make down

# Clean everything
make fclean
Parte 17: Guia de Solução de Problemas
Cenários comuns
Cenário 1: O contêiner não inicia.

# Check the logs
docker logs <container_name>

# Check the Dockerfile
# Common issues: wrong base image, missing packages, permission issues
Desafio de depuração : Se o contêiner do MariaDB for encerrado imediatamente, quais são as três primeiras coisas que você verificaria?

Cenário 2: Não é possível conectar ao banco de dados

# Test network connectivity
docker exec wordpress ping mariadb

# Check database is listening
docker exec mariadb netstat -tuln | grep 3306

# Test database connection
docker exec mariadb mysql -u ${MYSQL_USER} -p${MYSQL_PASSWORD} -e "SHOW DATABASES;"
Cenário 3: O NGINX retorna o erro 502 Bad Gateway.

Análise : O que significa o código 502 e o que você verificaria?

# Check if WordPress container is running
docker ps | grep wordpress

# Check PHP-FPM is listening
docker exec wordpress netstat -tuln | grep 9000

# Check NGINX configuration
docker exec nginx nginx -t
Problemas de desempenho
Questões para investigação :

O problema está relacionado à CPU, à memória ou à entrada/saída de dados?
Há algum gargalo nas consultas ao banco de dados?
A conectividade da rede é ideal?
# Monitor resource usage
docker stats

# Check disk usage
df -h
du -sh /home/${USER}/data/*

# Monitor network
docker exec nginx ss -tuln
comandos básicos de contêineres Docker

# To build
docker build -t <container_image_name> .

# To run
docker run -d <container_image_name>

# To run with name
docker run -d --name my_app image

# To check all docker containers
docker ps -a

# To stop containers and remove images
docker rm -f $(docker ps -aq) &&  docker rmi -f $(docker images -aq)

# To run a compose file
docker compose up

# Force rebuild in background 
docker compose up --build -d

# Down composer
docker compose down

# To delete content from data volumes
sudo rm -rf /home/user/data/wordpress/
sudo rm -rf /home/user/data/mariadb/

# To create again
mkdir -p /home/user/data/wordpress/
mkdir -p /home/user/data/mariadb/

# To check db connection manually (from wp contaier)
docker exec -it wordpress bash
apt-get update && apt-get install -y mariadb-client
mysql -h mariadb -u"$WORDPRESS_DB_USER" -p

# To acces mariadb user table from root (inside mariadb contaier)
docker exec -it mariadb mysql -u root -p

# And from wp_user (inside mariadb contaier)
docker exec -it mariadb mysql -u"$WORDPRESS_DB_USER" -p

# To check env values
docker exec -it mariadb env
docker exec -it wordpress env

Recursos
Documentação do Docker : https://docs.docker.com/
Melhores práticas do Docker : https://docs.docker.com/develop/best-practices/
Aprendizado sobre Kubernetes : https://kubernetes.io/docs/tutorials/
Segurança de contêineres : https://www.nist.gov/publications/application-container-security-guide
Comentários principais (0)
Inscreva-se
foto
Adicione à discussão
Código de Conduta • Denunciar abuso

alejiri
Seguir
Ingressou
16/10/2025
Em alta na comunidade DEV 
Foto de perfil de John Munsch
Eu desenvolvo software há 40 anos. Mas quero que *você* me conte como era o desenvolvimento em 1986...
# programação # discussão #desenvolvimento #batepapo​​
Foto de perfil de Mark Gyles
Armadilhas de custo exponencial em arquiteturas de banco de dados: como o SurrealDB quebra o ciclo.
# surrealdb # banco de dados # webdev # backend
Foto de perfil de Mike Dolan
Como eu construí memória persistente para o código Claude
#ai #llm #produtividade #showdev​​​​
#!/bin/bash

set -e

echo "Starting MariaDB initialization..."

# Initialize MySQL data directory if it doesn't exist
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing data directory..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null
fi

# Start the server (no networking for setup)
echo "Starting temporary MariaDB server for setup..."
mysqld --skip-networking --socket=/run/mysqld/mysqld.sock --user=mysql &
pid="$!"

# Wait for MariaDB to be ready
echo "Waiting for MariaDB to be ready..."
until mysqladmin --socket=/run/mysqld/mysqld.sock ping >/dev/null 2>&1; do
    sleep 1
done
echo "MariaDB is ready!"

# Run setup SQL: create database and users
echo "Running setup SQL..."
mysql --socket=/run/mysqld/mysqld.sock -u root << EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

# Shut down temporary server
echo "Shutting down temporary MariaDB..."
mysqladmin --socket=/run/mysqld/mysqld.sock -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown

# Wait for shutdown
wait "$pid" || true

# Start MariaDB normally (with networking)
echo "Initialization complete. Starting MariaDB..."
exec mysqld --user=mysql --datadir=/var/lib/mysql --socket=/run/mysqld/mysqld.sock