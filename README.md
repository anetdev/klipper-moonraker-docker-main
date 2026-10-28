# Klipper & Moonraker Modular Docker Stack (v2)

A modern, unprivileged, microservices-based Docker Compose stack for running **Klipper**, **Moonraker**, **uStreamer**, and **Telegram Bot** on **Python 3.12**.

---

## Highlights

* **Decoupled Microservices**: Separate containers for Klipper, Moonraker, uStreamer (webcam), and Telegram Bot. No `supervisord` required.
* **Latest Python 3.12**: Both Klipper and Moonraker run natively on clean Python 3.12 Debian Bookworm bases with pre-compiled C-helpers (`chelper`).
* **Unprivileged & Secure**: No `privileged: true` or broad `/dev` mounts. Uses granular `/dev/serial/by-id/...` device mapping and host group permissions (`dialout`, `video`).
* **Standard `printer_data` Directory**: Follows the official ecosystem layout (`config`, `gcodes`, `logs`, `comms`, `database`).
* **High-Performance Webcam**: Fast, low-latency MJPEG streaming via `ustreamer` (PiKVM) instead of legacy `mjpg-streamer`.
* **Zero Config Overwrite**: Initial configurations are seeded safely on first run and never overwritten on container restarts.
* **Multi-Printer Ready**: Run one printer with the default `docker-compose.yml`, or multiple independent printers using `docker-compose.multi-instance.yml.example`.
* **Built-in Firmware Builder**: Compile `.bin`/`.elf` MCU firmware via Docker without installing cross-compilers on the host.

---

## Architecture

```text
Host Hardware:
  ├── /dev/serial/by-id/...  --> Passed to Klipper container
  └── /dev/video0            --> Passed to uStreamer container

Persistent Volume (./printer_data):
  ├── config/        # printer.cfg, moonraker.conf, macros.cfg
  ├── gcodes/        # Uploaded print files
  ├── logs/          # klippy.log, moonraker.log
  ├── comms/         # klippy.sock (Unix Domain Socket)
  └── database/      # Moonraker LMDB state

Network & Services:
  ├── klipper        # Runs Klippy host software
  ├── moonraker      # Port 7125 (HTTP / WebSockets API)
  ├── ustreamer      # Port 8080 (MJPEG Webcam Stream)
  └── telegram-bot   # Optional Telegram integration (profile: bots)
```

---

## Getting Started

### 1. Prerequisites
* Linux host machine (Docker & Docker Compose installed)
* Connected 3D printer via USB

### 2. Configure Environment
Find your printer's persistent serial device path:
```bash
ls -l /dev/serial/by-id/
```

Copy the example environment file and edit it:
```bash
cp .env.example .env
nano .env
```
Set your `PRINTER_DEVICE` to match your device ID, for example:
```env
PRINTER_DEVICE=/dev/serial/by-id/usb-1a86_USB2.0-Serial-if00-port0
DIALOUT_GID=dialout
MOONRAKER_PORT=7125
CAMERA_DEVICE=/dev/video0
WEBCAM_PORT=8080
WEBCAM_RESOLUTION=640x480
WEBCAM_FPS=30
WEBCAM_FORMAT=MJPEG
```

### 3. Launch Services
Using `make`:
```bash
# Build all images
make build

# Start core services (Klipper + Moonraker)
make up

# Or start all services including Webcam and Telegram Bot
make up-all
```

Or using `docker compose`:
```bash
docker compose --profile webcam up -d
```

### 4. Connect Web Frontend (Mainsail / Fluidd)
Point your web interface to your host IP on port `7125` (e.g. `http://<host-ip>:7125`).

---

## Compiling MCU Firmware

Compile firmware for your printer mainboard (e.g., STM32, RP2040, AVR) in an isolated container:

```bash
# Open interactive Klipper menuconfig
./build_firmware.sh menuconfig

# Compile firmware (outputs to build/out/klipper.bin)
./build_firmware.sh
```

---

## Directory Structure

```text
├── .env.example                             # Environment defaults
├── Makefile                                 # Management shortcuts
├── docker-compose.yml                       # Primary Compose stack
├── docker-compose.multi-instance.yml.example # Dual-printer setup example
├── build_firmware.sh                        # Firmware compilation script
├── config.template/                         # First-run boilerplate configs
│   ├── printer.cfg
│   ├── moonraker.conf
│   ├── macros.cfg
│   └── telegram.conf
└── services/
    ├── klipper/                             # Klipper service (Python 3.12)
    ├── moonraker/                           # Moonraker service (Python 3.12)
    ├── ustreamer/                           # uStreamer webcam service
    ├── telegram-bot/                        # Moonraker Telegram Bot service
    └── firmware-builder/                    # MCU compiler toolchain container
```

---

## License
MIT License.
