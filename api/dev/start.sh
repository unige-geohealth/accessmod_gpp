#!/bin/bash 
# Required to provide the correct context for binds. /proc/self/mountinfo are 
# not usable : docker alters the paths. This is a workaround for dev
echo "BIND_PATH=$(realpath ../..)" > .env
echo "NODE_ENV=development" >> .env

docker compose up
