#!/bin/bash
set -e

ACCESSMOD_VERSION="5.8.3-alpha.1"
INACCESSMOD_VERSION="latest"
CITY_FILE=.gpp_location
IMAGE_ACCESSMOD="fredmoser/accessmod:$ACCESSMOD_VERSION"
IMAGE_INACCESSMOD="fredmoser/inaccessmod:$INACCESSMOD_VERSION"


if [ -e "$CITY_FILE" ]
then
  CITY_LAST=$(cat .gpp_location)
else 
  CITY_LAST=""
fi

if [ -z "$CITY_LAST" ]
then 
  DEFAULT_CITY="Bern"
else 
  DEFAULT_CITY=$CITY_LAST 
fi
DEV_MODE=false
CITY=$DEFAULT_CITY


build_dirs() {
  # Check if the ./data directory exists
  if [ ! -d "./data" ]; then
    echo "Error: ./data directory does not exist."
    return 1
  fi

    # List of directories to create
    dirs=("location" "cache" "dbgrass" "logs" "config")

    # Loop through the list and create directories if they don't exist
    for dir in "${dirs[@]}"; do
      mkdir -p "./data/$dir"
    done

    echo "Directories OK."
    return 0
  }

# Function to display the menu
display_menu() {
  echo "[ City $CITY ]"
  echo "[ Dev mode $DEV_MODE ]"
  echo "Select the part to load:"
  echo "1) 01_get_data"
  echo "2) 02_build_merged_landcover"
  echo "3) 03_create_start_points"
  echo "4) 04_travel_time"
  echo "5) Exit"
}

# Function to ask if the user wants to develop
ask_develop() {
  while true; do
    read -p "Do you want to develop? (y/N): " yn
    case $yn in
      [Yy]* ) echo "true"; return;;
      [Nn]* ) echo "false"; return;;
      * ) echo "false"; return;;
    esac
  done
}

# Function to ask for the city name
ask_city() {
  read -p "Enter the city name (default is $DEFAULT_CITY): " city
  if [ -z "$city" ]; then
    city=$DEFAULT_CITY
  fi
  DEFAULT_CITY=$city
  echo $DEFAULT_CITY > $CITY_FILE
  echo $city
}



update_images(){
  echo "Updating images"
  DOCKER_CLI_HINTS=false docker pull $IMAGE_ACCESSMOD
  DOCKER_CLI_HINTS=false docker pull $IMAGE_INACCESSMOD
}

# Function to run the docker command with the selected part
run_docker() {
  local part=$1
  local image=$IMAGE_INACCESSMOD
  local cmd="Rscript main.R"
  #local develop=$(ask_develop)
  #local city=$(ask_city)

  if [ "$part" == "04_travel_time" ]; then
    image=$IMAGE_ACCESSMOD
    cmd="/bin/bash -c '/part/main.sh'"
  fi

  if [ "$DEV_MODE" == "true" ]; then
    cmd="/bin/bash"
  fi
  docker run -ti --rm \
    -v $(pwd)/helpers:/helpers \
    -v $(pwd)/data:/data \
    -v $(pwd)/${part}:/part \
    -e GPP_LOCATION="$CITY" \
    $image \
    $cmd
  }

# Update images
update_images

# Build data directories if needed
build_dirs

# Set variables
CITY=$(ask_city)
DEV_MODE=$(ask_develop)

while true; do
  display_menu
  read -p "Enter your choice [1-5]: " choice

  case $choice in
    1)
      run_docker "01_get_data"
      ;;
    2)
      run_docker "02_build_merged_landcover"
      ;;
    3)
      run_docker "03_create_start_points"
      ;;
    4)
      run_docker "04_travel_time"
      ;;
    5)
      echo "Exiting..."
      break
      ;;
    *)
      echo "Invalid choice, please select again."
      ;;
  esac
done
