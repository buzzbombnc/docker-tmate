FROM alpine:edge AS base

RUN apk update && \
    apk upgrade && \
    apk add --no-cache \
        libc6-compat \
        msgpack-c \
        ncurses-libs \
        libevent \
        openssh-keygen


FROM base AS build

ADD backtrace.patch /

RUN apk add --no-cache --virtual build-dependencies \
        build-base \
        ca-certificates \
        bash \
        wget \
        git \
        automake \
        autoconf \
        zlib-dev \
        libevent-dev \
        msgpack-c-dev \
        ncurses-dev \
        libexecinfo-dev \
        cmake \
        openssl-dev \
        libgcrypt-dev \
        mbedtls-dev && \
    mkdir /src && \
    git clone https://github.com/tmate-io/tmate-slave.git /src/tmate-server && \
    cd /src/tmate-server && \
    git apply /backtrace.patch && \
    ./create_keys.sh && \
    mv keys /etc/tmate-keys && \
    ./autogen.sh && \
    ./configure CFLAGS="-D_GNU_SOURCE" && \
    make -j && \
    cp tmate-slave /bin/tmate-slave && \
    /bin/sh /tmp/message.sh && \
    apk del build-dependencies && \
    rm -rf /src

ENTRYPOINT ["/tmate-slave.sh"]
