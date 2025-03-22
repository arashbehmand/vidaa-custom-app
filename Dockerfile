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
COPY supervisord.conf /app/supervisord.conf
COPY entrypoint.sh /app/entrypoint.sh

# Create image directories and log files
RUN mkdir -p /app/data/web/images/ui && \
    touch /var/log/nginx/access.log && \
    touch /var/log/nginx/error.log && \
    chmod 644 /var/log/nginx/access.log /var/log/nginx/error.log

# Set permissions and create symlinks
RUN chmod +x /app/entrypoint.sh && \
    ln -sf /app/config/nginx/app.conf /etc/nginx/http.d/app.conf && \
    rm -f /etc/nginx/http.d/default.conf && \
    chown -R nginx:nginx /var/log/nginx && \
    chown -R nginx:nginx /app/data/web && \
    chmod -R 755 /app/data/web

EXPOSE 53/udp 80 443

ENTRYPOINT ["/app/entrypoint.sh"]