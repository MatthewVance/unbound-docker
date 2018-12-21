FROM debian:stretch
MAINTAINER Matthew Vance

RUN set -x && \
    apt-get update && apt-get install -y --no-install-recommends \
      bsdmainutils \
      ldnsutils && \
      rm -rf /var/lib/apt/lists/*

ENV LIBRESSL_VERSION=2.8.3 \
    LIBRESSL_SHA256=9b640b13047182761a99ce3e4f000be9687566e0828b4a72709e9e6a3ef98477 \
    LIBRESSL_DOWNLOAD_URL=https://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-2.8.3.tar.gz

RUN BUILD_DEPS='ca-certificates curl gcc libc-dev make' && \
    set -x && \
    DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y --no-install-recommends \
      $BUILD_DEPS && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /tmp/src && \
    cd /tmp/src && \
    curl -sSL $LIBRESSL_DOWNLOAD_URL -o libressl.tar.gz && \
    echo "${LIBRESSL_SHA256} *libressl.tar.gz" | sha256sum -c - && \
    tar xzf libressl.tar.gz && \
    rm -f libressl.tar.gz && \
    cd libressl-2.8.3 && \
    ./configure --disable-dependency-tracking --prefix=/opt/libressl && \
    make check && make install && \
    rm -fr /opt/libressl/share/man && \
    echo /opt/libressl/lib > /etc/ld.so.conf.d/libressl.conf && ldconfig && \
    apt-get purge -y --auto-remove $BUILD_DEPS && \
    rm -fr /tmp/* /var/tmp/*

ENV UNBOUND_VERSION=1.6.8 \
    UNBOUND_SHA256=e3b428e33f56a45417107448418865fe08d58e0e7fea199b855515f60884dd49 \
    UNBOUND_DOWNLOAD_URL=https://nlnetlabs.nl/downloads/unbound/unbound-1.6.8.tar.gz

RUN BUILD_DEPS='ca-certificates curl gcc libc-dev make' && \
    set -x && \
    DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y --no-install-recommends \
      $BUILD_DEPS \
      libevent-2.0 \
      libevent-dev \
      libexpat1 \
      libexpat1-dev && \
    mkdir -p /tmp/src && \
    cd /tmp/src && \
    curl -sSL $UNBOUND_DOWNLOAD_URL -o unbound.tar.gz && \
    echo "${UNBOUND_SHA256} *unbound.tar.gz" | sha256sum -c - && \
    tar xzf unbound.tar.gz && \
    rm -f unbound.tar.gz && \
    cd unbound-1.6.8 && \
    groupadd _unbound && \
    useradd -g _unbound -s /etc -d /dev/null _unbound && \
    ./configure --disable-dependency-tracking --prefix=/opt/unbound --with-pthreads \
        --with-username=_unbound --with-ssl=/opt/libressl --with-libevent \
        --enable-event-api && \
    make install && \
    mv /opt/unbound/etc/unbound/unbound.conf /opt/unbound/etc/unbound/unbound.conf.example && \
    rm -fr /opt/unbound/share/man && \
    apt-get purge -y --auto-remove \
      $BUILD_DEPS \
      libexpat-dev \
      libevent-dev && \
    apt-get autoremove -y && apt-get clean && \
    rm -fr /tmp/* /var/tmp/* /var/lib/apt/lists/*

COPY unbound.sh /
RUN chmod +x /unbound.sh

COPY a-records.conf /opt/unbound/etc/unbound/

EXPOSE 53/udp
CMD ["/unbound.sh"]
