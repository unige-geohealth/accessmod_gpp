#!/bin/bash
set -euo pipefail

IMAGE_BASE="fredmoser/accessmod_api_curl"
BUILDER_NAME="accessmod_builder"
DOCKERFILE="./Dockerfile"

# Default settings
USE_BUILDX=false
TAG="local"

# Parse optional args
if [[ "${1:-}" == "--multiarch" ]]; then
  USE_BUILDX=true
  TAG="latest"
fi

IMAGE="${IMAGE_BASE}:${TAG}"

if [ "$USE_BUILDX" = true ]; then
  echo "🔧 Multi-platform build using buildx"

  # Check if the builder exists
  if ! docker buildx inspect "$BUILDER_NAME" &>/dev/null; then
    echo "Creating buildx builder: $BUILDER_NAME"
    docker buildx create --name "$BUILDER_NAME" --use
    docker buildx inspect --bootstrap
  else
    echo "Using existing builder: $BUILDER_NAME"
    docker buildx use "$BUILDER_NAME"
  fi

  docker buildx inspect --bootstrap

  echo "🚀 Building image $IMAGE for amd64 + arm64..."
  docker buildx build \
    --builder "$BUILDER_NAME" \
    --platform linux/amd64,linux/arm64 \
    -t "$IMAGE" \
    -f "$DOCKERFILE" \
    . \
    --output type=image,name="$IMAGE",push=false

else
  echo "🐳 Simple local build (no buildx)..."
  docker build \
    -t "$IMAGE" \
    -f "$DOCKERFILE" \
    --load \
    .
fi

echo "✅ Build complete: $IMAGE"
