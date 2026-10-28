.PHONY: help build up down logs ps clean firmware

help:
	@echo "Klipper & Moonraker Docker Management"
	@echo "--------------------------------------"
	@echo "make build       - Build all service images (klipper, moonraker, ustreamer, bot)"
	@echo "make up          - Start core services (klipper + moonraker) in background"
	@echo "make up-all      - Start all services (including webcam and telegram bot)"
	@echo "make down        - Stop and tear down services"
	@echo "make logs        - Tail live logs of running services"
	@echo "make ps          - View service status and health"
	@echo "make firmware    - Launch firmware configuration (make menuconfig)"

build:
	docker compose build

up:
	docker compose up -d klipper moonraker

up-all:
	docker compose --profile all up -d

down:
	docker compose down

logs:
	docker compose logs -f

ps:
	docker compose ps

firmware:
	./build_firmware.sh menuconfig

