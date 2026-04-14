#!/bin/bash
set -e

# Renderizar o template nginx.conf com envsubst antes de iniciar
if [ -f /etc/nginx/nginx.conf.template ]; then
    echo "Rendering nginx.conf from template..."
    envsubst '${DOMAIN_NAME}' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf
fi

# Garantir que o diretório SSL exista
mkdir -p /etc/nginx/ssl
# Ensure WordPress files are readable by www-data
chown -R www-data:www-data /var/www/html

# Domínio padrão se não for fornecido
: "${DOMAIN_NAME:=localhost}"

# Gerar o certificado SSL se ele não existir
if [ ! -f /etc/nginx/ssl/nginx.crt ]; then
    echo "Generating self-signed SSL certificate for ${DOMAIN_NAME}..."

    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/nginx.key \
        -out /etc/nginx/ssl/nginx.crt \
        -subj "/C=AO/ST=Luanda/L=Belas/O=Easy/CN=${DOMAIN_NAME}"

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