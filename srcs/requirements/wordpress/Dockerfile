FROM debian:bookworm

# Instalar PHP-FPM e extensões necessárias
RUN apt-get -o Acquire::ForceIPv4=true update && apt-get install -y \
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

# Criar diretório do WordPress
WORKDIR /var/www/html

# Copiar configuração do PHP-FPM (versão correta)
COPY conf/www.conf /etc/php/8.2/fpm/pool.d/

# Copiar e definir permissões para o script de configuração
COPY tools/entrypoint_wp.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint_wp.sh

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/entrypoint_wp.sh"]