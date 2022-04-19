FROM corpusops/debian-bare:buster
# Git branch to build from
# use --build-arg REBUILD=$(date) to invalidate the cache and upgrade all
# packages
ARG REBUILD=0
ARG PY_VER=3.7

VOLUME ["/data"]

# https://github.com/python-pillow/Pillow/issues/1763
ENV LIBRARY_PATH=/lib:/usr/lib
# user configuration
ENV MATRIX_UID=991 MATRIX_GID=991
ENV MATRIX_URL=https://github.com/corpusops/synapse
ENV MATRIX_URL=https://github.com/matrix-org/synapse

RUN set -ex;\
    mkdir /uploads;\
    export DEBIAN_FRONTEND=noninteractive;\
    mkdir -p /var/cache/apt/archives;\
    touch /var/cache/apt/archives/lock;\
    apt-get clean;\
    apt-get update -y;\
    apt-get install -y \
        bash \
        coreutils \
        curl \
        file \
        gcc \
        git \
        gosu \
        libevent-2.1-6 \
        libevent-dev \
        libffi6 \
        libffi-dev \
        libgnutls28-dev \
        libjpeg62-turbo \
        libjpeg62-turbo-dev \
        libldap-2.4-2 \
        libldap2-dev \
        libpq5 \
        libpq-dev\
        libsasl2-dev \
        libsqlite3-dev \
        libssl1.1 \
        libssl-dev \
        libtool \
        libwebp6 \
        libwebp-dev \
        xmlsec1 \
        libjemalloc2 \
        libxml2 \
        libxml2-dev \
        libxslt1.1 \
        libxslt1-dev \
        openssl \
        rustc \
        linux-headers-amd64 \
        make \
        postgresql-client\
        pwgen \
        python${PY_VER} \
        python${PY_VER}-distutils \
        python${PY_VER}-lib2to3 \
        libpython${PY_VER} \
        python${PY_VER}-dev \
        libpython${PY_VER}-dev \
        sqlite \
        xmlsec1 \
        zlib1g \
        zlib1g-dev
RUN curl -O https://bootstrap.pypa.io/get-pip.py;\
    python3 get-pip.py;\
    python3 -m pip install --upgrade pip virtualenv supervisor
RUN python3 -m pip install --upgrade python-ldap ipaddress lxml
# Git branch to build from
WORKDIR /synapse
ARG BV_SYN=master
RUN set -ex;\
    :;\
    git clone --branch $BV_SYN --depth 1 ${MATRIX_URL}.git .
RUN set -ex;\
    : hack as synapse/types.py does a messy shadow ;\
    cp synapse/python_dependencies.py /tmp;\
    python3 /tmp/python_dependencies.py|grep -v eliot|sed -re "s/;python_version.*//g" > reqs.txt;\
    echo installing;cat reqs.txt;\
    python3 -m pip install --upgrade -r reqs.txt
RUN python3 -m pip install git+https://github.com/ma1uta/matrix-synapse-rest-password-provider
RUN set -ex;\
    python3 -m pip install --upgrade $(pwd)[all];\
    GIT_SYN=$(git ls-remote ${MATRIX_URL} $BV_SYN | cut -f 1);\
    echo "synapse: $BV_SYN ($GIT_SYN)" >> /synapse.version
WORKDIR /
RUN set -ex;\
    rm -rf /synapse;\
    apt-get autoremove -y \
        file \
        gcc \
        git \
        libevent-dev \
        libffi-dev \
        libjpeg62-turbo-dev \
        libldap2-dev \
        libsqlite3-dev \
        libssl-dev \
        libtool \
        libpq-dev \
        libxml2-dev \
        libxslt1-dev \
        linux-headers-amd64 \
        make \
        python${PY_VER}-dev \
        libpython${PY_VER}-dev \
        zlib1g-dev;\
    :;\
    apt-get autoremove -y ;\
    rm -rf /var/lib/apt/* /var/cache/apt/*

# install homerserver template
COPY adds/start.sh /start.sh
# add supervisor configs
COPY adds/supervisord-matrix.conf /conf/
COPY adds/supervisord.conf /

# startup configuration
ENTRYPOINT ["/start.sh"]
CMD ["start"]
EXPOSE 8448

