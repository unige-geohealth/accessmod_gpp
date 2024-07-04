FROM r-base:latest

RUN apt-get update && apt-get install -y \
    build-essential \
    build-essential \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    && rm -rf /var/lib/apt/lists/*

ENV pkgs="c('dplyr','sf','doParallel','foreach','snow','terra')"

RUN R -e "install.packages('pak')"
RUN R -e "pak::pkg_install($pkgs)"

# Set working directory
WORKDIR /app

# Set the default command to R
CMD ["R"]


