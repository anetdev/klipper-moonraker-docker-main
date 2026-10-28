#!/bin/sh
set -e

PRINTER_DATA="${PRINTER_DATA:-/home/klippy/printer_data}"
CONFIG_DIR="${PRINTER_DATA}/config"
COMMS_DIR="${PRINTER_DATA}/comms"
LOGS_DIR="${PRINTER_DATA}/logs"
GCODES_DIR="${PRINTER_DATA}/gcodes"

# Ensure runtime directories exist
mkdir -p "${CONFIG_DIR}" "${COMMS_DIR}" "${LOGS_DIR}" "${GCODES_DIR}"

# Remove any stale Unix Domain Socket from previous runs
if [ -e "${COMMS_DIR}/klippy.sock" ]; then
    rm -f "${COMMS_DIR}/klippy.sock"
fi

# Seed initial printer.cfg if not present (non-destructive)
if [ ! -f "${CONFIG_DIR}/printer.cfg" ]; then
    if [ -f "/etc/klipper/template/printer.cfg" ]; then
        echo "[entrypoint] No printer.cfg found. Seeding initial configuration from template..."
        cp "/etc/klipper/template/printer.cfg" "${CONFIG_DIR}/printer.cfg"
    else
        echo "[entrypoint] Creating minimal starter printer.cfg..."
        cat << 'EOF' > "${CONFIG_DIR}/printer.cfg"
# Minimal starter printer.cfg created by klipper container
# Please configure your MCU serial port and printer settings.
[mcu]
serial: /dev/ttyUSB0

[printer]
kinematics: none
max_velocity: 300
max_accel: 3000
EOF
    fi
fi

exec "$@"

