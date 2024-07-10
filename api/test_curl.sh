#!/bin/bash

curl -X POST https://accessmod.mapx.org/compute_travel_time -H "Content-Type: application/json" -d '{"location":"Zurich"}'
