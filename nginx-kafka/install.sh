#!/bin/sh
# Installation script for Nginx with Kafka module on Alpine Linux
# Compiles Nginx 1.28.0 from source with ngx_kafka_module for HTTP-to-Kafka forwarding
# Includes librdkafka dependency and minimizes final image size by cleaning up build artifacts

set -e  # Exit immediately on any error

# Update package index and install build dependencies
# - build-base: GCC, make, and other compilation tools
# - pcre-dev, openssl-dev, zlib-dev: Development headers for PCRE, OpenSSL, and zlib (required by Nginx)
# - wget: For downloading source archives
# - git: For cloning repositories
# - bash: Shell for scripting
apk update
apk add --no-cache build-base pcre-dev openssl-dev zlib-dev wget git bash

# Install librdkafka (C library for Kafka communication, required by ngx_kafka_module)
# Clone the latest stable version from GitHub
git clone https://github.com/edenhill/librdkafka
cd librdkafka
./configure  # Generate Makefile with default options
make         # Compile the library
make install # Install headers and libraries to /usr/local
cd ..
rm -rf librdkafka  # Remove source code to save space

# Download and extract Nginx source code (version 1.28.0)
wget http://nginx.org/download/nginx-1.28.0.tar.gz
tar -xzf nginx-1.28.0.tar.gz
rm nginx-1.28.0.tar.gz

# Clone the Nginx Kafka module (provides ngx_kafka directives)
git clone https://github.com/brg-liuwei/ngx_kafka_module

# Configure and build Nginx with the Kafka module
cd nginx-1.28.0
./configure --add-module=../ngx_kafka_module  # Include the Kafka module in the build
make          # Compile Nginx with all modules
make install  # Install to /usr/local/nginx
cd ..

# Create dedicated nginx user and group for security
addgroup nginx
adduser -D -G nginx nginx

# Create necessary directories and set ownership
# Nginx needs /var/log/nginx for logs and /var/run/nginx for PID file
mkdir -p /var/log/nginx /var/run/nginx
touch /var/log/nginx/error.log  # Pre-create log file to avoid permission issues
chown -R nginx:nginx /var/log/nginx /var/run/nginx

# Clean up build artifacts and remove development packages to minimize image size
rm -rf nginx-1.28.0 ngx_kafka_module  # Remove source directories
apk del build-base pcre-dev openssl-dev zlib-dev wget git bash  # Remove build dependencies
apk add pcre  # Re-add runtime PCRE library (removed with dev package)
rm -rf /var/cache/apk/*  # Clear package manager cache