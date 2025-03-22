#!/bin/bash

# Make sure the script exits on any error
set -e

# Get host IP (more robust method)
HOST_IP=$(ip route get 1.1.1.1 | awk '{print $NF; exit}')
if [ -z "$HOST_IP" ]; then
  echo "Error: Could not determine host IP. Ensure network is configured correctly."
  exit 1
fi
echo "TV should use DNS IP: $HOST_IP"

# Configure dnsmasq (using config file from /app/config)
# Create a new config file instead of modifying in place
sed "s/{{HOST_IP}}/$HOST_IP/g" /app/config/dnsmasq.conf > /etc/dnsmasq.conf

# Generate SSL certificates (if they don't exist)
if [ ! -f /app/certs/server.key ] || [ ! -f /app/certs/server.crt ]; then
    echo "Generating self-signed SSL certificates..."
    mkdir -p /app/certs # Ensure certs dir exists
    
    # Create OpenSSL config for multiple domains
    cat > /app/certs/openssl.conf << EOF
[req]
default_bits = 4096
prompt = no
default_md = sha256
x509_extensions = v3_req
distinguished_name = dn

[dn]
CN = vidaahub.com

[v3_req]
subjectAltName = @alt_names

[alt_names]
DNS.1 = vidaahub.com
DNS.2 = vidaahubimg.com
DNS.3 = *.vidaahub.com
DNS.4 = *.vidaahubimg.com
EOF

    # Generate certificate with SAN support
    openssl req -x509 -newkey rsa:4096 \
        -keyout /app/certs/server.key \
        -out /app/certs/server.crt \
        -days 3650 -nodes \
        -config /app/certs/openssl.conf
    
    chmod 600 /app/certs/server.key
    chmod 644 /app/certs/server.crt
    rm -f /app/certs/openssl.conf
    echo "Certificates generated in /app/certs"
else
    echo "Using existing SSL certificates from /app/certs"
fi

# Create symbolic links for images
mkdir -p /app/data/web/images/ui

# Set proper permissions
chown -R nginx:nginx /app/data/web

# Start services using supervisord
echo "Starting services via supervisord..."
/usr/bin/supervisord -c /app/supervisord.conf 