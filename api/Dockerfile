# Build stage
FROM fredmoser/accessmod:5.8.3-alpha.2 AS builder

# Install system dependencies for ggplot2
RUN apk add --no-cache \
    build-base \
    cairo-dev \
    pango-dev \
    freetype-dev \
    libpng-dev \
    libjpeg-turbo-dev \
    tiff-dev \
    R-dev

# Install ggplot2 using pak
RUN Rscript -e 'pak::pkg_install(c("ggplot2"))'

# Final stage
FROM fredmoser/accessmod:5.8.3-alpha.2

# Copy R libraries from builder stage
COPY --from=builder /usr/local/lib/R/library /usr/local/lib/R/library
# context = parent !
# Copying directories
COPY ./helpers /helpers
COPY ./01_get_data /01_get_data
COPY ./02_build_merged_landcover /02_build_merged_landcover
COPY ./03_create_start_points /03_create_start_points
COPY ./04_travel_time /04_travel_time
COPY ./api /api


# Install Node.js and npm
RUN apk add --no-cache nodejs npm


WORKDIR /api
RUN npm install &\
  mkdir -p /data/cache &\
  mkdir -p /data/config &\
  mkdir -p /data/logs &\
  mkdir -p /data/location &\
  mkdir -p /data/dbgrass 
 
VOLUME /data
EXPOSE 3000

ENTRYPOINT ["/api/entrypoint.sh"]
CMD ["app"]
