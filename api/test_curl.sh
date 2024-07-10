#!/bin/bash

curl -X POST http://localhost:3030/compute_travel_time -H "Content-Type: application/json" -d '{"location":"Dubai"}'
