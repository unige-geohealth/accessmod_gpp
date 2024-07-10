#!/bin/bash

docker build --push \
  --platform linux/amd64,linux/arm64 \
  -t fredmoser/accessmod_api:latest \
  -f ./Dockerfile \
  ..

