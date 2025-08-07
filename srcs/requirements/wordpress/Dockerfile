# Use the oldstable version of Debian as the base image
FROM debian:oldstable

# Update the package lists for upgrades and installations
RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    php7.4 \
    php-fpm \
    php-mysql \
    mariadb-client \
    curl \
    tini \
    vim && \
    # Clean up the local repository of retrieved package files to reduce the image size
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy script files and configuration
COPY requirements/wordpress/conf/cnf /etc/php/7.4/fpm/pool.d/www.conf
COPY requirements/wordpress/tools/init.sh /scripts/init.sh

# Set permissions for the entry script
RUN chmod +x /scripts/init.sh

# Use tini as the entrypoint, which allows it to catch signals and forward them to the application
ENTRYPOINT ["/usr/bin/tini", "--"]

# Run the entrypoint script when the Docker container starts
CMD ["bash", "/scripts/init.sh"]

