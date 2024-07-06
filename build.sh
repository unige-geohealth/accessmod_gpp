#!/bin/bash
echo "Build on push with github actions"

PLATFORMS=linux/amd64,linux/arm64
IMAGE=fredmoser/inaccessmod:latest

docker build --platform $PLATFORMS -t $IMAGE --push .
