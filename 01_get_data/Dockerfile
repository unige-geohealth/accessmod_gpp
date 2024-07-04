FROM r-base:latest

RUN apt-get update && apt-get install -y \
    build-essential \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    && rm -rf /var/lib/apt/lists/*
    
ENV pkgs="c('unige-geohealth/inAccessMod@438473e')"
RUN R -e "print('pak');install.packages('pak')"
RUN R -e "pak::pkg_install($pkgs)"


WORKDIR /app

CMD ["R"]
