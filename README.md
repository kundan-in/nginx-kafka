# nginx-kafka

A minimal Docker image for Nginx compiled with the ngx_kafka_module, enabling direct forwarding of HTTP requests to Kafka topics.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Docker Image](https://img.shields.io/badge/Docker-kundandeveloper%2Fnginx--kafka-blue)](https://hub.docker.com/r/kundandeveloper/nginx-kafka)

## Overview

This repository provides a Docker image of Nginx (version 1.28.0) compiled with the [ngx_kafka_module](https://github.com/brg-liuwei/ngx_kafka_module) on Alpine Linux. The image allows you to run Nginx as a Kafka producer, forwarding HTTP POST requests directly to Kafka topics without additional application logic.

## Features

- **Nginx with Kafka Module**: Pre-compiled Nginx with ngx_kafka_module for HTTP-to-Kafka forwarding
- **Alpine Linux Base**: Minimal image size (~50MB)
- **Multi-Architecture**: Supports AMD64 and ARM64
- **Mountable Config**: Use your own `nginx.conf` by mounting it at runtime

## Prerequisites

- Docker

## Building the Image

### Local Build

1. Clone the repository:
   ```bash
   git clone https://github.com/kundan-in/kafka-nginx.git
   cd kafka-nginx
   ```

2. Build the image locally:
   ```bash
   docker build -t nginx-kafka:latest ./nginx-kafka
   ```

### Multi-Arch Build and Push

To build for multiple architectures and push to Docker Hub:

1. Set environment variables:
   ```bash
   export DOCKER_USERNAME=your_dockerhub_username
   export DOCKER_PASSWORD=your_dockerhub_password
   ```

2. Run the build script:
   ```bash
   ./build.sh
   ```

This builds for AMD64 and ARM64 and pushes to `kundandeveloper/nginx-kafka:latest`.

### Automated Builds

The repository includes GitHub Actions that automatically build and push the image on changes to the `nginx-kafka/` directory or build scripts. Ensure you have set up the following secrets in your GitHub repository:

- `DOCKER_USERNAME`: Your Docker Hub username
- `DOCKER_PASSWORD`: Your Docker Hub password or access token

## Using the Image

The image expects an `nginx.conf` file to be mounted. Here's an example configuration:

```nginx
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log warn;
pid /var/run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    include mime.types;
    default_type application/octet-stream;

    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    client_max_body_size 16M;

    # Kafka configuration
    kafka;
    kafka_broker_list kafka:9092;

    server {
        listen 80;
        server_name localhost;

        location /events {
            kafka_topic my_topic;
            kafka_partition 0;
        }
    }
}
```

Run the container:

```bash
docker run -d \
  -p 8080:80 \
  -v $(pwd)/nginx.conf:/usr/local/nginx/conf/nginx.conf \
  nginx-kafka:latest
```

## Example Usage

1. Create an `nginx.conf` file as shown above.
2. Run the container as described.
3. Post data to the endpoint:

```bash
curl -X POST http://localhost:8080/events \
  -H "Content-Type: application/json" \
  -d '{"message": "Hello Kafka"}'
```

The data will be forwarded to the Kafka topic specified in the config.

## Project Structure

- **nginx-kafka/Dockerfile**: Dockerfile for building the Nginx image with Kafka module
- **nginx-kafka/install.sh**: Build script that compiles Nginx with ngx_kafka_module and librdkafka

## How It Works

- The `install.sh` script downloads and compiles librdkafka (Kafka C library), then Nginx with the ngx_kafka_module.
- Build dependencies are removed after compilation to keep the image small.
- The resulting image contains Nginx ready to forward HTTP requests to Kafka.

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

Note: Refer to the licenses of individual components (Nginx, ngx_kafka_module).