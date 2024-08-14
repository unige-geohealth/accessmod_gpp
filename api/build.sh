#!/bin/bash

#  docker buildx use am_builder

docker build --push \
  --platform linux/amd64,linux/arm64 \
  -t fredmoser/accessmod_api:latest \
  -f ./Dockerfile \
  ..

docker pull fredmoser/accessmod_api:latest
