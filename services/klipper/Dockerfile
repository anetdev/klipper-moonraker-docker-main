# syntax=docker/dockerfile:1
FROM python:3.12-slim-bookworm AS builder

ARG KLIPPER_REPO="https://github.com/Klipper3d/klipper.git"
ARG KLIPPER_BRANCH="master"
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libffi-dev \
    git \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

RUN pip install --no-cache-dir --upgrade pip setuptools wheel

RUN git clone --depth 1 --branch ${KLIPPER_BRANCH} ${KLIPPER_REPO} /opt/klipper
WORKDIR /opt/klipper
RUN pip install --no-cache-dir -r scripts/klippy-requirements.txt
RUN python klippy/chelper/__init__.py
RUN python -m compileall klippy

# --- Runtime Stage ---
FROM python:3.12-slim-bookworm AS runner

ARG USER=klippy
ARG UID=1000
ARG GID=1000
ENV HOME=/home/${USER}
ENV PRINTER_DATA=${HOME}/printer_data
ENV PATH="/opt/venv/bin:$PATH"
ENV PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    iproute2 \
    libffi8 \
    libusb-1.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Create unprivileged user with tty and dialout group memberships
RUN groupadd -g ${GID} ${USER} || true && \
    useradd -u ${UID} -g ${GID} -m -d ${HOME} -s /bin/bash ${USER} && \
    usermod -a -G dialout,tty ${USER}

# Copy pre-built virtual environment and Klipper source
COPY --from=builder /opt/venv /opt/venv
COPY --from=builder --chown=${USER}:${USER} /opt/klipper ${HOME}/klipper

# Set up printer_data directory structure
RUN mkdir -p ${PRINTER_DATA}/config ${PRINTER_DATA}/gcodes ${PRINTER_DATA}/logs ${PRINTER_DATA}/comms && \
    chown -R ${USER}:${USER} ${PRINTER_DATA}

COPY --chmod=755 entrypoint.sh /usr/local/bin/entrypoint.sh

USER ${USER}
WORKDIR ${HOME}

VOLUME ["${PRINTER_DATA}"]

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["python", "/home/klippy/klipper/klippy/klippy.py", \
     "-a", "/home/klippy/printer_data/comms/klippy.sock", \
     "-l", "/home/klippy/printer_data/logs/klippy.log", \
     "/home/klippy/printer_data/config/printer.cfg"]

