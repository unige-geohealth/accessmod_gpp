#!/bin/bash 
# Required to provide the correct context for binds. /proc/self/mountinfo are 
# not usable : docker alters the paths. This is a workaround for dev
BIND_PATH=$(cd ../.. ; pwd) docker compose up


