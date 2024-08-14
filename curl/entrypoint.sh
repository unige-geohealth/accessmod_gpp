#!/bin/sh
set -e

# Default values
API_BASE_URL="https://accessmod.mapx.org"
CONTENT_TYPE="Content-Type: application/json"
LOCATION=""
SCENARIO=""
FORCE="false"
ACTION=""

# Function to print usage
print_usage() {
    echo "Usage: $0 [OPTIONS]" >&2
    echo "Options:" >&2
    echo "  -a, --action ACTION       Set the action to perform (required)" >&2
    echo "                            Available actions: location_create, travel_time, locations_list" >&2
    echo "  -l, --location LOCATION   Set the location (required for location_create and travel_time)" >&2
    echo "  -s, --scenario SCENARIO   Set the scenario (optional, for travel_time)" >&2
    echo "  -f, --force               Force create location project (optional, for location_create)" >&2
    echo "  -h, --help                Print this help message" >&2
}

# Parse command line arguments
while [ $# -gt 0 ]; do
    case "$1" in
        -a|--action)
            ACTION="$2"
            shift 2
            ;;
        -l|--location)
            LOCATION="$2"
            shift 2
            ;;
        -s|--scenario)
            SCENARIO="$2"
            shift 2
            ;;
        -f|--force)
            FORCE="true"
            shift
            ;;
        -h|--help)
            print_usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            print_usage
            exit 1
            ;;
    esac
done

# Check if action is provided
if [ -z "$ACTION" ]; then
    echo "Error: Action is required" >&2
    print_usage
    exit 1
fi

# Validate action
case "$ACTION" in
    location_create|travel_time)
        if [ -z "$LOCATION" ]; then
            echo "Error: Location is required for $ACTION action" >&2
            print_usage
            exit 1
        fi
        ;;
    locations_list)
        ;;
    *)
        echo "Error: Invalid action '$ACTION'" >&2
        print_usage
        exit 1
        ;;
esac

# Function to make API calls
make_api_call() {
    local method="$1"
    local endpoint="$2"
    local data="$3"

    if [ "$method" = "GET" ]; then
        curl -s -X GET "$API_BASE_URL$endpoint" -H "$CONTENT_TYPE"
    else
        curl -s -X POST "$API_BASE_URL$endpoint" -H "$CONTENT_TYPE" -d "$data"
    fi
}

# Compute travel time
compute_travel_time() {
    local base_data
    local final_data
    base_data=$(printf '{"location":"%s"}' "$LOCATION")
    if [ -n "$SCENARIO" ]; then
        final_data=$(printf '%s' "$base_data" | sed 's/}$/,"scenario":'"$SCENARIO"'}/')
    else
        final_data="$base_data"
    fi
    make_api_call "POST" "/compute_travel_time" "$final_data"
}

# Create location project
create_location_project() {
    local base_data
    local final_data
    base_data=$(printf '{"location":"%s"}' "$LOCATION")
    if [ "$FORCE" = "true" ]; then
        final_data=$(printf '%s' "$base_data" | sed 's/}$/,"force":true}/')
    else
        final_data="$base_data"
    fi
    make_api_call "POST" "/create_location_project" "$final_data"
}

# List available locations
list_locations() {
    make_api_call "GET" "/get_list_locations"
}

# Execute the selected action
case "$ACTION" in
    location_create)
        create_location_project
        ;;
    travel_time)
        compute_travel_time
        ;;
    locations_list)
        list_locations
        ;;
esac
