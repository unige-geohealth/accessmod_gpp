FROM r-base:4.4.0

RUN apt-get update && apt-get install -y \
    build-essential \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    && rm -rf /var/lib/apt/lists/*

ENV R_PACKAGES="\
    'unige-geohealth/inAccessMod@438473e',\
    'doParallel',\
    'snow',\
    'foreach',\
    'purrr',\
    'dplyr',\
    'sf',\
    'terra'\
"
    
RUN R -e "install.packages('pak')"
RUN R -e "pak::pkg_install(c(${R_PACKAGES}))"

# Copying directories
# context = parent !
COPY ./helpers /helpers
COPY ./01_get_data /01_get_data
COPY ./02_build_merged_landcover /02_build_merged_landcover
COPY ./03_create_start_points /03_create_start_points
COPY ./04_travel_time /04_travel_time

WORKDIR /part

CMD ["R"]
