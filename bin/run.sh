#!/bin/sh

gunicorn \
    -w 4 \
    -k uvicorn.workers.UvicornWorker \
    -b :8080 \
    --log-level warning example:app \
    --reload \
    leaderboard.app:app
