# syntax=docker/dockerfile:1
FROM python:3.12-slim-bookworm AS builder

ARG TELEGRAM_BOT_REPO="https://github.com/nlef/moonraker-telegram-bot.git"
ARG TELEGRAM_BOT_BRANCH="master"
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

RUN pip install --no-cache-dir --upgrade pip setuptools wheel

RUN git clone --depth 1 --branch ${TELEGRAM_BOT_BRANCH} ${TELEGRAM_BOT_REPO} /opt/moonraker-telegram-bot
WORKDIR /opt/moonraker-telegram-bot
RUN pip install --no-cache-dir -r scripts/requirements.txt
RUN pip install --no-cache-dir opencv-python-headless

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
    && rm -rf /var/lib/apt/lists/*

RUN groupadd -g ${GID} ${USER} || true && \
    useradd -u ${UID} -g ${GID} -m -d ${HOME} -s /bin/bash ${USER}

COPY --from=builder /opt/venv /opt/venv
COPY --from=builder --chown=${USER}:${USER} /opt/moonraker-telegram-bot ${HOME}/moonraker-telegram-bot

RUN mkdir -p ${PRINTER_DATA}/config ${PRINTER_DATA}/logs && \
    chown -R ${USER}:${USER} ${PRINTER_DATA}

COPY --chmod=755 entrypoint.sh /usr/local/bin/entrypoint.sh

USER ${USER}
WORKDIR ${HOME}

VOLUME ["${PRINTER_DATA}"]

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["python", "/home/klippy/moonraker-telegram-bot/bot/main.py", \
     "-c", "/home/klippy/printer_data/config/telegram.conf", \
     "-l", "/home/klippy/printer_data/logs/telegram.log"]

