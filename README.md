<!-- ![Mainsail Multiarch Image CI](https://github.com/dimalo/klipper-fluidd-control-docker/workflows/Mainsail%20Multiarch%20Image%20CI/badge.svg)
![Klipper Moonraker Multiarch Image CI](https://github.com/dimalo/klipper-fluidd-control-docker/workflows/Klipper%20Moonraker%20Multiarch%20Image%20CI/badge.svg) -->

- [klipper-fluidd-control-docker](#klipper-fluidd-control-docker)
  - [Features](#features)
  - [Getting started](#getting-started)
    - [Install the services](#install-the-services)
    - [If things are running fine now...](#if-things-are-running-fine-now)
    - [If things are not running...](#if-things-are-not-running)
  - [Features not implemented or not tested (yet)](#features-not-implemented-or-not-tested-yet)
  - [Credits](#credits)
# klipper-fluidd-control-docker
__Klipper with Moonraker shipped with Fluidd__
- forked from https://github.com/dimalo/klipper-web-control-docker
- removed Mainsail
- added mjpg_streamer support
- Added Klipper-Adaptive-Meshing-Purging (KAMP)
- Build with Github actions and deployed to ghcr.io


## Features
- Dockerhub images support x64, ARM64, ARM32v7 & ARM32v6
- Docker multistage builds for optimized image sizes
- fully integrated klipper image with moonraker enabled
  - startup management with supervisord & dependent startup (klipper starts first, then only if klipper is running moonraker is started)
- complete Klipper setup with [Fluidd](https://github.com/cadriel/fluidd)
  - only your printer.cfg is required
  - the services start without it, so you can supply your config through the web UI
  - you can mount your config file to /home/klippy/printer_data/config/printer.cfg, and klipper will pick it up after a restart
- Fluidd cam support using mjpg_streamer
- Support for Klipper-Adaptive-Meshing-Purging (https://github.com/kyleisah/Klipper-Adaptive-Meshing-Purging)

## Getting started

___Prerequisites:___
- _Your klipper host machine runs Linux or MacOS (Windows was not tested yet)_
    - (MacOS) Currently it is not possible to expose serial devices to a container in MacOS Docker. This is a known issue with Docker (https://github.com/docker/for-mac/issues/900)
- _You have docker and docker-compose installed on your machine_
- _You have flashed your printer with the appropriate .bin_
- _You have your printer connected to your machine and you know it's serial mount point (e.g. /dev/ttyACM0 or /dev/ttyUSB0)_
- _ARM32v6 (Raspberry Pi Zero and 1) requires [Docker 20](https://docs.docker.com/engine/install/debian/#install-using-the-convenience-script). Fluidd is not yet supported_

### Install the services

1. clone this repository and open it or navigate to it in your terminal
1. modify docker-compose.yml to your needs
    - set serial port of your printer
    - mount printer.cfg if already prepared (else you will be able to set it up later as well...)
1. run ```docker-compose pull && docker-compose up``` if you want to use the provided dockerhub images, else run ```docker-compose up``` to first build them on your host
1. watch the services being set up
    - make sure you have no port conflicts on 7125, 8010 and 8011 
    - make sure klipper and moonraker started
    - leave the compose session running
1. test the frontends
    - http://{dockerserver}:8010
1. configure your printer
    - modify / upload printer.cfg, if not mounted already
    - check if klipper is able to connect to the printer
    - follow klippers documentation to test your printers functionality

### If things are running fine now...
Quit the compose session with ```Ctrl+C```and run ```docker-compose up -d```.

__Happy 3D Printing!__

### If things are not running...

__No serial connection:__

Check the permissions on the serial device in the klipper host.

```ls -lsa /dev/ttyACM0```

Supply the group permissions to the docker-compose config in docker-compose.yml build args for klipper.

Run ```docker-compose build```

After build run ```docker-compose up -d``` and see if it works.

This article was very helpful [how-to-access-serial-devices-in-docker](https://www.losant.com/blog/how-to-access-serial-devices-in-docker)

## Features not implemented or not tested (yet)
- compiling klipper.bin for your printer 

- CI pipeline to build images as upstream repos change

## Credits
- [dimalo](https://github.com/dimalo/klipper-web-control-docker) thanks for docker image.  
- [Klipper](https://github.com/KevinOConnor/klipper)
- [Moonraker](https://github.com/Arksine/moonraker)
- [Fluidd](https://github.com/cadriel/fluidd)
- [KAMP](https://github.com/kyleisah/Klipper-Adaptive-Meshing-Purging)
