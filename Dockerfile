# syntax=docker/dockerfile:1
ARG BV_SYN=master
FROM matrixdotorg/synapse:${BV_SYN} as base
RUN set -ex;\
    export DEBIAN_FRONTEND=noninteractive;\
    mkdir -p /var/cache/apt/archives;\
    touch /var/cache/apt/archives/lock;\
    apt-get clean;\
    apt-get update -y;\
    apt-get install -y \
        bash \
        coreutils \
        file \
        libevent-2.1-7 \
        libldap-2.5-0 \
        libpq5 \
        postgresql-client\
    && rm -rf /var/lib/apt/lists/*

FROM base as builder
RUN set -ex;\
    export DEBIAN_FRONTEND=noninteractive;\
    apt-get clean;\
    apt-get update -y;\
    apt-get install -y \
        gcc \
        git \
        libtool \
        rustc \
        linux-headers-amd64 \
        libevent-dev \
        libffi-dev \
        libgnutls28-dev \
        libjpeg62-turbo-dev \
        libldap2-dev \
        libpq-dev\
        libsasl2-dev \
        libsqlite3-dev \
        libwebp-dev \
        libxml2-dev \
        libxslt1-dev \
        python3-dev \
        libpython3-dev \
        zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*
RUN python3 -m pip install --prefix=/install --upgrade supervisor
RUN python3 -m pip install --prefix=/install --upgrade python-ldap ipaddress lxml
RUN python3 -m pip install --prefix=/install git+https://github.com/ma1uta/matrix-synapse-rest-password-provider

FROM corpusops/debian-bare:buster as helpers
FROM base as runner
COPY --from=helpers /cops_helpers /usr/local/bin
COPY --from=builder /install /usr/local
