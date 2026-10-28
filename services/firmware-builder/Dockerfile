# syntax=docker/dockerfile:1
FROM debian:bookworm-slim

ARG DEBIAN_FRONTEND=noninteractive
ARG KLIPPER_REPO="https://github.com/Klipper3d/klipper.git"
ARG KLIPPER_BRANCH="master"

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    ca-certificates \
    python3 \
    python3-dev \
    libncurses-dev \
    libusb-1.0-0-dev \
    pkg-config \
    gcc-arm-none-eabi \
    binutils-arm-none-eabi \
    libnewlib-arm-none-eabi \
    gcc-avr \
    binutils-avr \
    avr-libc \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/klipper
RUN git clone --depth 1 --branch ${KLIPPER_BRANCH} ${KLIPPER_REPO} /opt/klipper

WORKDIR /opt/klipper
CMD ["make"]

