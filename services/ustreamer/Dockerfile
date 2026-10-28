# syntax=docker/dockerfile:1
FROM debian:bookworm-slim AS builder

ARG USTREAMER_REPO="https://github.com/pikvm/ustreamer.git"
ARG USTREAMER_BRANCH="master"
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    ca-certificates \
    libevent-dev \
    libjpeg-dev \
    libbsd-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 --branch ${USTREAMER_BRANCH} ${USTREAMER_REPO} /opt/ustreamer
WORKDIR /opt/ustreamer
# Allow UVC webcams without input channel selectors to proceed
RUN sed -i 's/return -1;/;/' src/libs/capture.c
RUN make

# --- Runtime Stage ---
FROM debian:bookworm-slim AS runner

ARG USER=streamer
ARG UID=1000
ARG GID=1000
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    libevent-2.1-7 \
    libevent-pthreads-2.1-7 \
    libjpeg62-turbo \
    libbsd0 \
    v4l-utils \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd -g ${GID} ${USER} || true && \
    useradd -u ${UID} -g ${GID} -m -s /bin/bash ${USER} && \
    usermod -a -G video ${USER}

COPY --from=builder /opt/ustreamer/ustreamer /usr/local/bin/ustreamer
COPY --chmod=755 entrypoint.sh /usr/local/bin/entrypoint.sh

USER ${USER}
EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

