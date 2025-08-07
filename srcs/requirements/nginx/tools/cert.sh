# **************************************************************************** #

#                                                                              #
#                                                         :::      ::::::::    #
#    cert.sh                                            :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ingonzal <ingonzal@student.42urduli>       +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2023/09/16 18:49:55 by ingonzal          #+#    #+#              #
#    Updated: 2023/09/16 18:57:37 by ingonzal         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #
#!/bin/bash
echo "Linux release ==>"
cat /etc/*-release
echo -e "<== Linux release END\n"

# Directory where certificates will be stored
cert_dir="/tmp"
# mkdir $cert_dir

# Check if certificates already exist
if [ ! -f "$cert_dir/ingonzal.42.fr.crt" ] && [ ! -f "$cert_dir/ingonzal.42.fr.key" ]; then
    echo "Creating self-signed SSL certificates..."

    # Generate self-signed SSL certificates
    openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 \
        -subj "/C=US/ST=California/L=San Francisco/O=Example/CN=localhost" \
        -keyout "$cert_dir/ingonzal.42.fr.key" -out "$cert_dir/ingonzal.42.fr.crt" &&

    echo "Certificates created."

    # Move certificates to their final location
    mv "$cert_dir/ingonzal.42.fr.crt" /etc/ssl/
    mv "$cert_dir/ingonzal.42.fr.key" /etc/ssl/

    echo "Certificates moved to their final location."

	# Change permissions of the certificate files
    chmod 644 /etc/ssl/ingonzal.42.fr.crt
    chmod 600 /etc/ssl/ingonzal.42.fr.key

    echo "Permissions changed for the certificate files."
else
    echo "Certificates already exist in $cert_dir."
rm "$cert_dir/ingonzal.42.fr.key" && "$cert_dir/ingonzal.42.fr.crt"
fi

# Configure NGINX to use the certificates
echo "Creating nginx configuration"

# Change volume permissions and ownership
chmod 755 /var/www/inception/wordpress
chown -R www-data:www-data /var/www/inception/wordpress

# Start the NGINX server
echo "Starting NGINX server..."
nginx -g 'daemon off;'