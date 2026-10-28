#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${SCRIPT_DIR}/build"
CONFIG_FILE="${BUILD_DIR}/.config"
IMAGE_NAME="klipper-firmware-builder"

mkdir -p "${BUILD_DIR}/out"
touch "${CONFIG_FILE}"

echo "==> Building firmware builder container image..."
docker build -t "${IMAGE_NAME}" "${SCRIPT_DIR}/services/firmware-builder"

if [ "$1" = "menuconfig" ]; then
    echo "==> Launching make menuconfig..."
    docker run --rm -it \
        -v "${CONFIG_FILE}:/opt/klipper/.config" \
        "${IMAGE_NAME}" make menuconfig
fi

echo "==> Compiling MCU firmware..."
docker run --rm \
    -v "${CONFIG_FILE}:/opt/klipper/.config:ro" \
    -v "${BUILD_DIR}/out:/opt/klipper/out" \
    "${IMAGE_NAME}" make

echo "==> Build complete! Output firmware is in: ${BUILD_DIR}/out"
