#!/bin/bash
# Multi-architecture build script for Nginx-Kafka Docker image
# Builds and pushes AMD64 and ARM64 variants to Docker Hub
# Requires Docker Buildx and Docker Hub credentials

set -e  # Exit on any error

# Configuration variables
IMAGE_NAME="kundandeveloper/nginx-kafka"  # Target Docker Hub repository
TAG="latest"                             # Image tag
PLATFORMS="linux/amd64,linux/arm64"      # Target architectures

# Verify required tools are installed
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed or not in PATH"
    exit 1
fi

if ! docker buildx version &> /dev/null; then
    echo "Error: Docker Buildx is not available (install Docker Desktop or buildx plugin)"
    exit 1
fi

# Check for required environment variables for Docker Hub authentication
if [ -z "$DOCKER_USERNAME" ] || [ -z "$DOCKER_PASSWORD" ]; then
    echo "Error: DOCKER_USERNAME and DOCKER_PASSWORD environment variables must be set"
    echo "Usage: DOCKER_USERNAME=youruser DOCKER_PASSWORD=yourpass ./build.sh"
    exit 1
fi

# Authenticate with Docker Hub
echo "Logging in to Docker Hub..."
echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin

# Set up Docker Buildx for multi-architecture builds
echo "Setting up Docker Buildx builder..."
docker buildx create --use --name multi-arch-builder 2>/dev/null || docker buildx use multi-arch-builder

# Build and push the multi-arch image
echo "Building and pushing multi-arch image..."
echo "Repository: $IMAGE_NAME:$TAG"
echo "Platforms: $PLATFORMS"
echo "Build context: ./nginx-kafka"

docker buildx build \
    --platform "$PLATFORMS" \
    --push \
    -t "$IMAGE_NAME:$TAG" \
    ./nginx-kafka

echo "✅ Multi-architecture image built and pushed successfully!"
echo "View at: https://hub.docker.com/r/$IMAGE_NAME/tags"