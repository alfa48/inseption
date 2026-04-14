FROM debian:bookworm

# Instalar nginx, openssl e envsubst
RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    gettext-base \
    && rm -rf /var/lib/apt/lists/*

# Garantir que nginx seja executado como www-data com UID(user id) correto
RUN usermod -u 33 www-data && groupmod -g 33 www-data

# Criar diretório para certificados SSL
RUN mkdir -p /etc/nginx/ssl

# Copiar arquivos de configuração
# COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/nginx.conf.template /etc/nginx/nginx.conf.template
COPY tools/generate_ssl.sh /usr/local/bin/

# Definir permissões de execução
RUN chmod +x /usr/local/bin/*.sh

EXPOSE 443

ENTRYPOINT ["/usr/local/bin/generate_ssl.sh"]