#!/bin/sh
set -e

DEVICE="${DEVICE:-/dev/video0}"
HOST="${HOST:-0.0.0.0}"
PORT="${PORT:-8080}"
RESOLUTION="${RESOLUTION:-1280x720}"
FRAMERATE="${FRAMERATE:-30}"
FORMAT="${FORMAT:-MJPEG}"
WORKERS="${WORKERS:-3}"

echo "Starting ustreamer on ${HOST}:${PORT} for device ${DEVICE} (${RESOLUTION} @ ${FRAMERATE}fps, format ${FORMAT})..."

exec /usr/local/bin/ustreamer \
    --host="${HOST}" \
    --port="${PORT}" \
    --device="${DEVICE}" \
    --resolution="${RESOLUTION}" \
    --desired-fps="${FRAMERATE}" \
    --format="${FORMAT}" \
    --workers="${WORKERS}" \
    --drop-same-frames=30 \
    "$@"

