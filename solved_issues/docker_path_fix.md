# Docker Path Fix for MacOS

## Problem
When running Docker-in-Docker containers on MacOS, volume mounts using absolute paths like `/data` fail with this error:
```
Mounts denied: The path /data is not shared from the host and is not known to Docker.
```

## Root Cause
The API container creates nested Docker containers with volume mounts, but the BIND_PATH environment variable wasn't being passed to containers, so the path conversion function wasn't working:

```javascript
// In helpers.js
function bindPath(containerPath) {
  const bind_path = process.env.BIND_PATH;
  if (!bind_path) {
    return containerPath;  // This was returning "/data" directly
  }
  return path.join(bind_path, containerPath);
}
```

## Solution

1. Modified compose.yml to pass BIND_PATH environment variable to containers:
```yaml
services:
  accessmod-api:
    # ... other config
    environment:
      - BIND_PATH=${BIND_PATH}
    
  accessmod-api-dev:
    # ... other config  
    environment:
      - BIND_PATH=${BIND_PATH}
      - NODE_ENV=development
```

2. The start.sh script already sets BIND_PATH correctly:
```bash
echo "BIND_PATH=$(realpath ../..)" > .env
```

This ensures the nested Docker containers use the correct absolute paths for volume mounts that are shared with Docker Desktop on MacOS.