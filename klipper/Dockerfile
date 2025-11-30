FROM python:3.10-slim-bullseye AS builder

ARG DEBIAN_FRONTEND=noninteractive
ARG KLIPPER_BRANCH="master"
ARG MOONRAKER_BRANCH="master"

ARG USER=klippy
ARG HOME=/home/${USER}
ARG KLIPPER_VENV_DIR=${HOME}/klippy-env
ARG MOONRAKER_VENV_DIR=${HOME}/moonraker-env

ENV WHEELS=/wheels
ENV PYTHONUNBUFFERED=1

RUN useradd -d ${HOME} -ms /bin/bash ${USER}
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    locales \
    git \
    sudo \
    wget \
    curl \
    gzip \
    tar \
    libffi-dev \
    build-essential \
    libncurses-dev \
    libusb-dev \
    gpiod \
    libopenjp2-7 \
    liblmdb-dev \
    libsodium-dev \
    imagemagick \
    libv4l-dev \
    libjpeg-dev \
    libjpeg62-turbo-dev \
    cmake \
    unzip && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# RUN sed -i -e 's/# en_GB.UTF-8 UTF-8/en_GB.UTF-8 UTF-8/' /etc/locale.gen
# RUN locale-gen
RUN --mount=type=cache,target=/root/.cache/pip python -m pip install -U pip setuptools wheel && \
    pip wheel --no-cache-dir -w ${WHEELS} supervisord-dependent-startup gpiod numpy matplotlib

# ENV LC_ALL en_GB.UTF-8 
# ENV LANG en_GB.UTF-8  
# ENV LANGUAGE en_GB:en   

USER ${USER}
WORKDIR ${HOME}

### Klipper setup ###
RUN git clone --single-branch --branch ${KLIPPER_BRANCH} https://github.com/Klipper3d/klipper.git klipper
# klipper_z_calibration plugin removed — not used in this build
RUN [ ! -d ${KLIPPER_VENV_DIR} ] && python3 -m venv ${KLIPPER_VENV_DIR}

WORKDIR ${HOME}/klipper
RUN --mount=type=cache,target=/root/.cache/pip ${KLIPPER_VENV_DIR}/bin/python -m pip install --upgrade pip setuptools wheel && \
    ${KLIPPER_VENV_DIR}/bin/pip install --no-cache-dir -f ${WHEELS} -r scripts/klippy-requirements.txt
RUN ${KLIPPER_VENV_DIR}/bin/python klippy/chelper/__init__.py
RUN ${KLIPPER_VENV_DIR}/bin/python -m compileall klippy

COPY .config_linux_mcu ./.config
RUN make

WORKDIR ${HOME}
# Install moonraker
RUN git clone --single-branch --branch ${MOONRAKER_BRANCH} https://github.com/Arksine/moonraker.git moonraker
RUN [ ! -d ${MOONRAKER_VENV_DIR} ] && python3 -m venv ${MOONRAKER_VENV_DIR}

WORKDIR ${HOME}/moonraker
RUN --mount=type=cache,target=/root/.cache/pip ${MOONRAKER_VENV_DIR}/bin/python -m pip install --upgrade pip setuptools wheel && \
    ${MOONRAKER_VENV_DIR}/bin/pip install --no-cache-dir -f ${WHEELS} -r scripts/moonraker-requirements.txt
RUN ${MOONRAKER_VENV_DIR}/bin/python -m compileall moonraker


#webcam
WORKDIR ${HOME}
RUN git clone https://github.com/jacksonliam/mjpg-streamer.git
RUN cd mjpg-streamer/mjpg-streamer-experimental && make
RUN mv mjpg-streamer/mjpg-streamer-experimental/* mjpg-streamer && rm -rf mjpg-streamer/mjpg-streamer-experimental

FROM python:3.10-slim-bullseye AS image

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \    
    curl \
    git \
    ffmpeg \    
    iproute2 \
    libcurl4-openssl-dev \
    libjpeg-dev \
    liblmdb-dev \
    libopenjp2-7 \
    libsodium-dev \
    libssl-dev \
    # libtiff5 removed: not available on some slim bases; OpenCV package will pull required libs
    supervisor \
    gettext-base \
    libv4l-dev \
    zlib1g-dev \
    python3-opencv \
    x264         \
    libx264-dev \
    libwebp-dev && \
    # Clean up
    apt-get autoremove -y && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/*


ARG USER=klippy
ARG HOME=/home/${USER}
ENV CONFIG_DIR=${HOME}/printer_data/config
ENV KLIPPER_VENV_DIR=${HOME}/klippy-env
ENV MOONRAKER_VENV_DIR=${HOME}/moonraker-env

ENV WHEELS=/wheels
ENV PYTHONUNBUFFERED=1

# Allow overriding service ports so multiple container instances can run
# on a single host; map host ports to these container ports at runtime.
ENV MOONRAKER_PORT=7125
ENV MJPG_PORT=8080

ARG DEVICE_GROUP=device
ARG DEVICE_GID=987


RUN useradd --user-group --no-log-init --shell /bin/false -m -d ${HOME} ${USER} && \
    groupadd -g ${DEVICE_GID} ${DEVICE_GROUP} && \
    usermod -a -G ${DEVICE_GROUP} ${USER} && \
    usermod -a -G tty ${USER} && \
    usermod -a -G dialout ${USER} && \
    usermod -a -G video ${USER} && \
    mkdir -p /var/log/supervisor ${HOME}/.cache/pip && \
    mkdir -p /var/log/klipper && chown -R ${USER}:${USER} /var/log/klipper ${HOME}

COPY --chown=${USER}:${USER} --from=builder ${WHEELS} ${WHEELS}

RUN pip install --no-index -f ${WHEELS} supervisord-dependent-startup gpiod numpy matplotlib && \
    mkdir -p /usr/lib/python3 && \
    rm -Rf ${WHEELS}

USER ${USER}
WORKDIR ${HOME}

RUN mkdir -p ${HOME}/printer_data/gcodes ${CONFIG_DIR} ${HOME}/.moonraker_database 

VOLUME ${HOME}/printer_data/gcodes
VOLUME  ${HOME}/.moonraker_database 
VOLUME ${CONFIG_DIR}


EXPOSE 7125

USER root

COPY --chown=${USER}:${USER} --from=builder ${HOME}/klipper/out/klipper.elf /usr/local/bin/klipper_mcu
COPY --chown=${USER}:${USER} --from=builder ${HOME}/klipper ${HOME}/klipper
COPY --chown=${USER}:${USER} --from=builder ${KLIPPER_VENV_DIR} ${KLIPPER_VENV_DIR}
COPY --chown=${USER}:${USER} --from=builder ${HOME}/moonraker ${HOME}/moonraker
COPY --chown=${USER}:${USER} --from=builder ${MOONRAKER_VENV_DIR} ${MOONRAKER_VENV_DIR}

COPY --chown=${USER}:${USER} --chmod=700 config ${CONFIG_DIR}
COPY --chown=${USER}:${USER} --chmod=700 run_in_venv /usr/local/bin/run_in_venv


#mjpg streamer
COPY --chown=${USER}:${USER} --chmod=700 mjpgstreamer/index.html ${HOME}/www-mjpgstreamer/index.html
COPY --chown=${USER}:${USER} --from=builder ${HOME}/mjpg-streamer ${HOME}/mjpg-streamer

EXPOSE 8080

#telegram-bot
WORKDIR ${HOME}
ARG TEL_BOT_VENV=${HOME}/moonraker-telegram-bot/moonraker-telegram-bot-env
RUN git clone https://github.com/nlef/moonraker-telegram-bot.git
WORKDIR ${HOME}/moonraker-telegram-bot
RUN [ ! -d ${TEL_BOT_VENV} ] && python3 -m venv ${TEL_BOT_VENV}
RUN ${TEL_BOT_VENV}/bin/pip install --no-cache-dir -r scripts/requirements.txt
RUN ${TEL_BOT_VENV}/bin/pip install --no-cache-dir opencv-python
RUN chown -R ${USER}:${USER} ${HOME}/moonraker-telegram-bot
RUN chmod +x ${HOME}/moonraker-telegram-bot/bot/main.py

COPY supervisord.conf /etc/supervisord/conf.d/supervisord.conf
# copy templates to be processed at runtime
COPY supervisor/*.ini.template /etc/templates/
COPY config/moonraker.conf.template /etc/templates/
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

LABEL org.opencontainers.image.title="klipper-fluidd" \
    org.opencontainers.image.description="Klipper + Moonraker container (klipper-fluidd)" \
    org.opencontainers.image.license="MIT" \
    org.opencontainers.image.source="https://github.com/anetdev/klipper-fluidd-docker-main"

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["supervisord", "-c", "/etc/supervisord/conf.d/supervisord.conf"]
