FROM r-base:4.4.1

# Update and install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    && rm -rf /var/lib/apt/lists/*

RUN R -e "install.packages('pak')"
RUN R -e "pak::pkg_install('unige-geohealth/inAccessMod@438473e')"
RUN R -e "pak::pkg_install('purrr')"
RUN R -e "pak::pkg_install('dplyr')"
RUN R -e "pak::pkg_install('sf')"
RUN R -e "pak::pkg_install('terra')"

WORKDIR /run

CMD ["R"]
