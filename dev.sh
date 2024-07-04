#!/bin/bash

# Function to display the menu
display_menu() {
    echo "Select the part to load:"
    echo "1) 01_get_data"
    echo "2) 02_build_merged_landcover"
    echo "3) 03_create_start_points"
    echo "4) 04_analyze"
    echo "5) Exit"
}

# Function to run the docker command with the selected part
run_docker() {
    local part=$1
    docker run -ti --rm \
      -v $(pwd)/helpers:/helpers \
      -v $(pwd)/shared:/data \
      -v $(pwd)/${part}:/app \
      fredmoser/inaccessmod:latest \
      /bin/bash
}

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
            run_docker "04_analyze"
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
