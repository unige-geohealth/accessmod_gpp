#!/bin/bash

BASE=$(pwd)
DATA=$BASE"/data"
SCENARIO="$(cat ./assets/scenario_default.json)"
LOCATION="Yerevan"
#LOCATION="Milan"


docker run \
  --rm  \
  -e BIND_PATH=$BASE \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $DATA:/data \
  -v $BASE/api/cli.js:/api/cli.js \
  fredmoser/accessmod_api cli \
  action=travel_time \
  location=$LOCATION \
  scenario="$SCENARIO"

