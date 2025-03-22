FROM alpine:3.19

RUN apk add --no-cache \
    dnsmasq \
    nginx \
    openssl \
    supervisor \
    bash

# Create directories
RUN mkdir -p /app/config /app/data/web /app/certs /var/log/nginx \
    && mkdir -p /usr/share/nginx/html/images/ui

# Copy application files
COPY config/dnsmasq.conf /app/config/dnsmasq.conf
COPY config/nginx/app.conf /app/config/nginx/app.conf
COPY data/web/ /app/data/web/
COPY config.yaml /app/data/web/
COPY supervisord.conf /app/supervisord.conf
COPY entrypoint.sh /app/entrypoint.sh

# Create image directories
RUN mkdir -p /app/data/web/images/ui

# Set permissions and create symlinks
RUN chmod +x /app/entrypoint.sh && \
    ln -sf /app/config/nginx/app.conf /etc/nginx/http.d/app.conf && \
    rm -f /etc/nginx/http.d/default.conf

EXPOSE 53/udp 80 443

ENTRYPOINT ["/app/entrypoint.sh"] 