FROM mvance/debian:jessie-minbase
MAINTAINER Matthew Vance

RUN set -x && \
    apt-get update && apt-get install -y --no-install-recommends \
      bsdmainutils \
      ldnsutils && \
      rm -rf /var/lib/apt/lists/*

ENV LIBRESSL_VERSION 2.4.2
ENV LIBRESSL_SHA256 5f87d778e5d62822d60e38fa9621c1c5648fc559d198ba314bd9d89cbf67d9e3
ENV LIBRESSL_DOWNLOAD_URL http://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-2.4.2.tar.gz

RUN BUILD_DEPS='curl gcc libc-dev make' && \
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
    cd libressl-2.4.2 && \
    ./configure --disable-dependency-tracking --prefix=/opt/libressl && \
    make check && make install && \
    rm -fr /opt/libressl/share/man && \
    echo /opt/libressl/lib > /etc/ld.so.conf.d/libressl.conf && ldconfig && \
    apt-get purge -y --auto-remove $BUILD_DEPS && \
    rm -fr /tmp/* /var/tmp/* \

ENV UNBOUND_VERSION 1.5.9
ENV UNBOUND_SHA256 01328cfac99ab5b8c47115151896a244979e442e284eb962c0ea84b7782b6990
ENV UNBOUND_DOWNLOAD_URL http://www.unbound.net/downloads/unbound-1.5.9.tar.gz

RUN BUILD_DEPS='curl gcc libc-dev make' && \
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
    cd unbound-1.5.9 && \
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
