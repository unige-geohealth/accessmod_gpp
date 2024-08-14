#!/bin/bash
set -e

#  docker buildx use am_builder
IMAGE="fredmoser/accessmod_api_curl:latest"

docker build --push \
  --platform linux/amd64,linux/arm64 \
  -t $IMAGE \
  -f ./Dockerfile \
  .

docker pull $IMAGE
