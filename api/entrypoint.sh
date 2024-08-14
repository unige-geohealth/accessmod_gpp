#!/bin/sh
set -e


if [ "$1" = "app" ]; then
    exec node /api/app.js
elif [ "$1" = "cli" ]; then
    shift
    exec node /api/cli.js "$@"
else
    exec "$@"
fi

