FROM r-base:4.4.1

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

WORKDIR /app

CMD ["R"]
