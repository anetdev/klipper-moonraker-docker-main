#!/bin/sh
set -e

# Generate templated config files at container start
TEMPLATES_DIR=/etc/templates
SUPERVISOR_DIR=/etc/supervisord
MOON_CONF_DIR=/home/klippy/printer_data/config

if [ -d "$TEMPLATES_DIR" ]; then
  # Generate moonraker.conf from template
  if [ -f "$TEMPLATES_DIR/moonraker.conf.template" ]; then
    mkdir -p "$MOON_CONF_DIR"
    envsubst < "$TEMPLATES_DIR/moonraker.conf.template" > "$MOON_CONF_DIR/moonraker.conf"
    chown klippy:klippy "$MOON_CONF_DIR/moonraker.conf" || true
  fi

  # Process supervisor templates: output to /etc/supervisord/*.ini
  for t in "$TEMPLATES_DIR"/*.ini.template; do
    [ -e "$t" ] || continue
    out="$SUPERVISOR_DIR/$(basename "$t" .template)"
    envsubst < "$t" > "$out"
  done
fi

exec "$@"
