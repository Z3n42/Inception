# Use the oldstable version of Debian as the base image
FROM debian:oldstable

# Update the package lists for upgrades and installations

RUN apt-get update && apt-get install -y \
    mariadb-server \
    tini \
    gettext-base \
    vim && \
    # Clean up the local repository of retrieved package files to reduce the image size
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy script files and configuration
COPY requirements/mariadb/tools/init.sh /scripts/init.sh
COPY requirements/mariadb/conf/init.sql /scripts/init.sql
COPY requirements/mariadb/conf/50-server.cnf /etc/mysql/mariadb.conf.d/

# Set permissions for the entry script
RUN chmod +x /scripts/init.sh
RUN chown -R mysql:mysql /var/lib/mysql

# Use tini as the entrypoint, which allows it to catch signals and forward them to the application
ENTRYPOINT ["/usr/bin/tini", "--"]

# Run the entrypoint script when the Docker container starts
CMD ["/scripts/init.sh"]
