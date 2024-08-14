#!/bin/bash

# URL of the API endpoint
URL="http://localhost:3030/compute_travel_time"

# JSON payload for the request
DATA='{"location": "Madrid", "force": true}'

# Send POST request using curl
curl -X POST $URL \
  -H "Content-Type: application/json" \
  -d "$DATA" \
  -w "\n\nHTTP Status Code: %{http_code}\n"
