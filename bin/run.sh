#!/bin/sh

cd /code && gunicorn \
    -w 4 \
    -k uvicorn.workers.UvicornWorker \
    -b :8080 \
    -e DEV=true \
    --log-level warning \
    leaderboard.app:app
