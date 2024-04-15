#!/bin/bash

# Enable the shell option to exit immediately if a pipeline returns a non-zero status
# set -e
# set -o pipefail

echo "Linux release ==>"
cat /etc/*-release
echo -e "<== Linux release END\n"

# Create necessary directories for MariaDB
mkdir -p /var/run/mysqld /run/mysqld
chown -R mysql:mysql /var/run/mysqld /run/mysqld

# Initialize the database if not present
if [ ! -d /var/lib/mysql/mysql ]; then
    echo "Initializing the database..."
    mysql_install_db --user=root
fi

# Start MariaDB service in the background
echo "Starting MariaDB service..."
service mariadb start

# Wait until MariaDB server is online
echo "Waiting for MariaDB server to be online..."
while ! mysqladmin ping -hlocalhost --silent 2>/dev/null; do
    echo "Waiting..."
	  sleep 1
done

# Execute initial SQL queries
if [[ -f /scripts/init.sql ]]; then
    echo "Executing initial SQL queries..."
    # Create a temporary SQL file with environment variables substituted
    envsubst < /scripts/init.sql > /tmp/init.sql
    # Execute the SQL queries in the temporary file
    mysql -u root -p${MYSQL_ROOT_PASSWORD} < /tmp/init.sql
    # Remove the temporary file
    rm /tmp/init.sql
fi

# Stop MariaDB service
echo "Stopping MariaDB service..."
service mariadb stop

# Wait until MariaDB server has stopped
echo "Waiting for MariaDB server to stop..."
while mysqladmin ping -hlocalhost --silent 2>/dev/null; do
    echo "Waiting..."
    sleep 1
done


# Trap SIGTERM and SIGINT signals and gracefully exit the script
trap 'echo "Caught signal, stopping MariaDB service..."; service mariadb stop; exit 0' SIGTERM SIGINT

# Start MariaDB server in the foreground
echo "Starting MariaDB server in the foreground..."
# killall mysqld
exec mysqld

