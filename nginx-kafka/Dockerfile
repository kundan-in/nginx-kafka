FROM alpine:latest

# Copy installation script
COPY install.sh /install.sh

# Install Nginx with Kafka module
RUN chmod +x /install.sh && /install.sh && rm /install.sh

# Expose HTTP port
EXPOSE 80

# Health check for Nginx
HEALTHCHECK --interval=10s --timeout=2s --start-period=2s --retries=2 \
  CMD wget -qO- http://localhost/ > /dev/null || exit 1

# Start Nginx
CMD ["/usr/local/nginx/sbin/nginx", "-g", "daemon off;"]