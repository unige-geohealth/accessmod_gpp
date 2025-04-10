#!/bin/bash


curl -X POST https://api.accessmod.org/create_location_project -H "Content-Type: application/json" -d '{"location":"Zurich", "force":true}'

curl -X POST https://api.accessmod.org/compute_travel_time -H "Content-Type: application/json" -d '{"location":"Zurich"}'
