# syntax=docker/dockerfile:1
FROM python:3.12-slim-bookworm AS builder

ARG MOONRAKER_REPO="https://github.com/Arksine/moonraker.git"
ARG MOONRAKER_BRANCH="master"
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    liblmdb-dev \
    libsodium-dev \
    curl \
    git \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

RUN pip install --no-cache-dir --upgrade pip setuptools wheel

RUN git clone --depth 1 --branch ${MOONRAKER_BRANCH} ${MOONRAKER_REPO} /opt/moonraker
RUN git clone --depth 1 https://github.com/Klipper3d/klipper.git /opt/klipper
WORKDIR /opt/moonraker
RUN pip install --no-cache-dir -r scripts/moonraker-requirements.txt
RUN python -m compileall moonraker

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
    liblmdb0 \
    libsodium23 \
    libopenjp2-7 \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd -g ${GID} ${USER} || true && \
    useradd -u ${UID} -g ${GID} -m -d ${HOME} -s /bin/bash ${USER}

COPY --from=builder /opt/venv /opt/venv
COPY --from=builder --chown=${USER}:${USER} /opt/moonraker ${HOME}/moonraker
# Provide example configs and docs so Mainsail can browse sample printer configs
COPY --from=builder --chown=${USER}:${USER} /opt/klipper/config ${HOME}/klipper/config
COPY --from=builder --chown=${USER}:${USER} /opt/klipper/docs ${HOME}/klipper/docs

RUN mkdir -p ${PRINTER_DATA}/config ${PRINTER_DATA}/gcodes ${PRINTER_DATA}/logs ${PRINTER_DATA}/comms ${PRINTER_DATA}/database && \
    chown -R ${USER}:${USER} ${PRINTER_DATA}

COPY --chmod=755 entrypoint.sh /usr/local/bin/entrypoint.sh

USER ${USER}
WORKDIR ${HOME}

EXPOSE 7125

VOLUME ["${PRINTER_DATA}"]

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["python", "/home/klippy/moonraker/moonraker/moonraker.py", \
     "-c", "/home/klippy/printer_data/config/moonraker.conf", \
     "-l", "/home/klippy/printer_data/logs/moonraker.log"]

