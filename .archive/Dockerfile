FROM debian:buster
# Git branch to build from
ARG BV_SYN=master
# use --build-arg REBUILD=$(date) to invalidate the cache and upgrade all
# packages
ARG REBUILD=0

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
        curl postgresql-client\
        coreutils \
        file \
        gcc \
        git \
        libevent-2.1-6 \
        libevent-dev \
        libffi-dev \
        libffi6 \
        libgnutls28-dev \
        libjpeg62-turbo \
        libjpeg62-turbo-dev \
        libldap-2.4-2 \
        libldap2-dev \
        libsasl2-dev \
        libsqlite3-dev \
        libssl-dev \
        libssl1.1 \
        libtool \
        libxml2 \
        libxml2-dev \
        libxslt1-dev \
        libxslt1.1 \
        linux-headers-amd64 \
        make \
        pwgen \
        python \
        python-dev \
        libpq5 libpq-dev\
        sqlite \
        zlib1g \
        zlib1g-dev;\
    :;\
    curl -O https://bootstrap.pypa.io/get-pip.py;\
    python get-pip.py;\
    apt-get install -y \
        python-virtualenv;\
    pip install --upgrade pip;\
    pip install --upgrade supervisor
# Git branch to build from
RUN set -ex;\
    :;\
    git clone https://github.com/maxidor/matrix-synapse-rest-auth.git;\
    cd matrix-synapse-rest-auth;\
    for i in /usr/lib/python*/dist-packages/; do\
      cp -fv rest_auth_provider.py "$i";\
    done;\
    cd /;\
    :;\
    git clone --branch $BV_SYN --depth 1 ${MATRIX_URL}.git;\
    cd /synapse;\
    python synapse/python_dependencies.py | grep -v eliot|xargs pip install --upgrade;\
    pip install --upgrade python-ldap;\
    pip install --upgrade enum34;\
    pip install --upgrade ipaddress;\
    pip install --upgrade lxml;\
    pip install --upgrade $(pwd)[all];\
    GIT_SYN=$(git ls-remote ${MATRIX_URL} $BV_SYN | cut -f 1);\
    echo "synapse: $BV_SYN ($GIT_SYN)" >> /synapse.version;\
    cd /;\
    rm -rf /synapse;\
    :;\
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
        python-dev \
        zlib1g-dev;\
    :;\
    apt-get autoremove -y ;\
    rm -rf /var/lib/apt/* /var/cache/apt/*

# install homerserver template
COPY adds/start.sh /start.sh
# add supervisor configs
COPY adds/supervisord-matrix.conf /conf/
COPY adds/supervisord.conf /
RUN sed -i -re "s/python3/python/g" /conf/*

# startup configuration
ENTRYPOINT ["/start.sh"]
ENV MATRIX_PYTHON=python3
CMD ["start"]
EXPOSE 8448

