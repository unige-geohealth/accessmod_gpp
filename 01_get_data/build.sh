#!/bin/bash

docker build --push \
  --platform linux/amd64,linux/arm64 \
  -t fredmoser/inaccessmod:latest \
  -f ./Dockerfile \
  ..

docker pull fredmoser/inaccessmod:latest
