#!/bin/bash

# Enable the shell option to exit immediately if a pipeline returns a non-zero status
# set -e
# set -o pipefail

echo "Linux release ==>"
cat /etc/*-release
echo -e "<== Linux release END\n"

# Install wp-cli
curl -OsS https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp
echo "Download wp-cli"

# Create directory for PHP if it doesn't exist
if [ ! -d /run/php ]; then
	echo "Create run"
    mkdir -p /run/php
fi

# Check if WordPress core files are present
if [ ! -f "$WP_DIR/wp-config.php" ]; then
    # Install WordPress if not already installed
	echo "WordPress not already installed"
	wp core download --version=6.4 --path=${WP_DIR} --allow-root
	# Move manually to WP_DIR because --path flag is broken
	cd ${WP_DIR}
	echo "WordPress core download"
	wp config create --dbname=${MYSQL_DATABASE} --dbhost=${WORDPRESS_DB_HOST} --dbuser=${MYSQL_USER} --dbpass=${MYSQL_PASSWORD} --allow-root
	echo "WordPress config create"
	wp core install --url=${DOMAIN_NAME} --title=${WORDPRESS_TITLE} --admin_user=${WORDPRESS_ADMIN_USER} --admin_password=${WORDPRESS_ADMIN_PASSWORD} --admin_email=${WORDPRESS_ADMIN_EMAIL} --allow-root --skip-email
	echo "WordPress core install"
	wp user create ${WORDPRESS_USER} ${WORDPRESS_USER_EMAIL} --role=${WORDPRESS_USER_ROLE} --user_pass=${WORDPRESS_USER_PASSWORD} --allow-root
	wp config set --raw WP_DEBUG true --allow-root && wp config set --raw WP_DEBUG_LOG true --allow-root && wp config set --raw WP_DEBUG_DISPLAY false --allow-root
	# # Assign appropriate permissions
  	chown -R www-data:www-data $WP_DIR

else
    echo "WordPress core files are already present at $WP_DIR."
fi

# Start php-fpm
echo "Starting php-fpm..."
exec php-fpm7.4 -F
