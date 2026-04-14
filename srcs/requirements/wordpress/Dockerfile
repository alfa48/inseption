FROM debian:bookworm

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
 \
 # instalar wp-cli
 && curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
 && chmod +x wp-cli.phar \
 && mv wp-cli.phar /usr/local/bin/wp \
 \
 # corrigir PHP-FPM (ESSENCIAL)
 && sed -i 's|listen = .*|listen = 9000|' /etc/php/8.2/fpm/pool.d/www.conf \
 \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/html

COPY tools/entrypoint_wp.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint_wp.sh

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/entrypoint_wp.sh"]