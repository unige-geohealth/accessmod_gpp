docker run --rm \
  -v $(pwd)/data:/data \
  -v $(pwd)/01_get_data:/app \
  fredmoser/inaccessmod Rscript main.R
