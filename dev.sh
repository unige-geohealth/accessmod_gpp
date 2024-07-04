docker run -ti --rm \
  -v $(pwd)/shared:/data \
  -v $(pwd)/03_create_start_points:/app \
  fredmoser/inaccessmod:latest \
  /bin/bash 
