#!/bin/bash


# Set source and destination
SRC_DIR="."
REMOTE_SERVER="root@srv560729.hstgr.cloud"
REMOTE_DEST="/data/"

# Run rsync with specific include and exclude patterns
rsync -avz --delete \
  --include='config/' \
  --include='config/**' \
  --include='location/' \
  --include='location/*/' \
  --include='location/*/data/' \
  --include='location/*/data/zToAccessMod/' \
  --include='location/*/data/zToAccessMod/**' \
  --include='location/*/facilities/' \
  --include='location/*/facilities/**' \
  --include='location/*/landcover/' \
  --include='location/*/landcover/**' \
  --include='location/*/output/' \
  --include='location/*/output/**' \
  --exclude='*' \
  "$SRC_DIR" "${REMOTE_SERVER}:${REMOTE_DEST}"

echo "Rsync completed."
