#!/bin/bash
# X-Platform Build and Push Script for X86_64 and ARM64.
# This script builds and pushes the backend and frontend images to Docker Hub.
# It uses the buildx feature of Docker to build images for multiple platforms.
# Author: Gilbert François Duivesteijn

set -e

# Change version here. You can leave the other settings as they are.
VERSION=1

USER=avaxgenesis
REPO=nvim
VERSION=1
BUILDER_CONTAINER_NAME=${REPO}-docker-builder

PLATFORM=linux/amd64,linux/arm64

# Create the builder container if it doesn't exist
if [[ $(docker container ls -a | grep ${BUILDER_CONTAINER_NAME} | wc -l) -eq 1 ]]; then
    echo "Builder container exists, skipping creation."
else
    docker buildx create --name ${BUILDER_CONTAINER_NAME}
    docker buildx use ${BUILDER_CONTAINER_NAME}
    docker buildx inspect --bootstrap
fi

# Build and push the images
docker buildx build --platform=${PLATFORM} \
    --tag ${USER}/${REPO}:${VERSION} \
    --tag ${USER}/${REPO}:latest \
    -f Dockerfile \
    --push \
    .
