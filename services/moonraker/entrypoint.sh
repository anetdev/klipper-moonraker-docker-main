#!/bin/sh
set -e

PRINTER_DATA="${PRINTER_DATA:-/home/klippy/printer_data}"
CONFIG_DIR="${PRINTER_DATA}/config"
COMMS_DIR="${PRINTER_DATA}/comms"
LOGS_DIR="${PRINTER_DATA}/logs"
DB_DIR="${PRINTER_DATA}/database"
GCODES_DIR="${PRINTER_DATA}/gcodes"

mkdir -p "${CONFIG_DIR}" "${COMMS_DIR}" "${LOGS_DIR}" "${DB_DIR}" "${GCODES_DIR}"

# Seed initial moonraker.conf if not present (non-destructive)
if [ ! -f "${CONFIG_DIR}/moonraker.conf" ]; then
    if [ -f "/etc/moonraker/template/moonraker.conf" ]; then
        echo "[entrypoint] No moonraker.conf found. Seeding initial configuration from template..."
        cp "/etc/moonraker/template/moonraker.conf" "${CONFIG_DIR}/moonraker.conf"
    else
        echo "[entrypoint] Creating default starter moonraker.conf..."
        cat << 'EOF' > "${CONFIG_DIR}/moonraker.conf"
[server]
host: 0.0.0.0
port: 7125
klippy_uds_address: /home/klippy/printer_data/comms/klippy.sock

[file_manager]
enable_object_processing: True

[data_store]
temperature_store_size: 600
gcode_store_size: 1000

[authorization]
cors_domains:
    *://app.mainsail.xyz
    *://my.mainsail.xyz
    *://*.local
    *://*
trusted_clients:
    10.0.0.0/8
    127.0.0.0/8
    169.254.0.0/16
    172.16.0.0/12
    192.168.0.0/16
    FE80::/10
    ::1/128

[octoprint_compat]

[history]
EOF
    fi
fi

exec "$@"

