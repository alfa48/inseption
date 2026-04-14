#!/bin/bash
set -e

WP_PATH="/var/www/html"

echo "Iniciando setup WordPress..."

# ler secrets
WORDPRESS_DB_PASSWORD=$(cat "$WORDPRESS_DB_PASSWORD_FILE")
ADMIN_PWD=$(cat "$WORDPRESS_USER_PWD_ADMIN_FILE")
EDITOR_PWD=$(cat "$WORDPRESS_USER_PWD_EDITOR_FILE")

# baixar wordpress se não existir
if [ ! -f "$WP_PATH/wp-config.php" ]; then
    echo "Baixando WordPress..."

    wget -q https://wordpress.org/latest.tar.gz -O /tmp/wp.tar.gz
    tar -xzf /tmp/wp.tar.gz -C /tmp
    cp -r /tmp/wordpress/* "$WP_PATH"
    rm -rf /tmp/wordpress /tmp/wp.tar.gz

    WP_SALTS=$(wget -qO- https://api.wordpress.org/secret-key/1.1/salt/)

    cat > "$WP_PATH/wp-config.php" << EOF
<?php
define('DB_NAME', '${WORDPRESS_DB_NAME}');
define('DB_USER', '${WORDPRESS_DB_USER}');
define('DB_PASSWORD', '${WORDPRESS_DB_PASSWORD}');
define('DB_HOST', '${WORDPRESS_DB_HOST}');
\$table_prefix = 'wp_';
${WP_SALTS}
define('WP_DEBUG', false);
if ( !defined('ABSPATH') )
 define('ABSPATH', __DIR__ . '/');
require_once ABSPATH . 'wp-settings.php';
EOF

    chown -R www-data:www-data "$WP_PATH"
fi

# 🚨 AQUI ESTÁ A CHAVE
echo "Esperando MariaDB subir..."
sleep 15

# instalar wordpress
if ! wp core is-installed --allow-root --path="$WP_PATH"; then
    echo "Instalando WordPress..."

    wp core install \
        --url="https://manandre.42.fr" \
        --title="Inception" \
        --admin_user="$WORDPRESS_USER_ADMIN" \
        --admin_password="$ADMIN_PWD" \
        --admin_email="admin@admin.com" \
        --skip-email \
        --allow-root \
        --path="$WP_PATH"

    wp user create \
        "$WORDPRESS_USER_EDITOR" \
        "editor@editor.com" \
        --role=editor \
        --user_pass="$EDITOR_PWD" \
        --allow-root \
        --path="$WP_PATH"
fi

echo "WordPress pronto!"

# 🚀 ISSO TEM QUE SEMPRE EXECUTAR
exec php-fpm8.2 -F