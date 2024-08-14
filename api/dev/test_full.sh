#!/bin/bash

# URL of the API endpoint
URL="http://localhost:3030/create_location_project"

# JSON payload for the request
DATA='{"location": "Madrid", "force": true}'

# Send POST request using curl
curl -X POST $URL \
  -H "Content-Type: application/json" \
  -d "$DATA" \
  -w "\n\nHTTP Status Code: %{http_code}\n"
