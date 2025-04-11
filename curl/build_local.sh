#!/bin/bash
set -euo pipefail

# Build a local image for testing
LOCAL_IMAGE="fredmoser/accessmod_api_curl:local"

echo "Building local image for testing: $LOCAL_IMAGE"
docker build -t "$LOCAL_IMAGE" -f ./Dockerfile .
echo "Build completed successfully."