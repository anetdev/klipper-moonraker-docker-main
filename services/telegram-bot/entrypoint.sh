#!/bin/sh
set -e

PRINTER_DATA="${PRINTER_DATA:-/home/klippy/printer_data}"
CONFIG_DIR="${PRINTER_DATA}/config"
LOGS_DIR="${PRINTER_DATA}/logs"

mkdir -p "${CONFIG_DIR}" "${LOGS_DIR}"

if [ ! -f "${CONFIG_DIR}/telegram.conf" ]; then
    if [ -f "/etc/telegram/template/telegram.conf" ]; then
        echo "[entrypoint] Seeding telegram.conf from template..."
        cp "/etc/telegram/template/telegram.conf" "${CONFIG_DIR}/telegram.conf"
    else
        echo "[entrypoint] Creating starter telegram.conf..."
        cat << 'EOF' > "${CONFIG_DIR}/telegram.conf"
# Sample Moonraker Telegram Bot configuration
# Update with your bot token and chat ID
[bot]
server: moonraker:7125
# bot_token: YOUR_BOT_TOKEN_HERE
# chat_id: YOUR_CHAT_ID_HERE

[camera]
host: http://ustreamer:8080/?action=stream
EOF
    fi
fi

exec "$@"

