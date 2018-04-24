FROM debian:stretch as openssl
LABEL maintainer="Matthew Vance"

ENV VERSION_OPENSSL=openssl-1.1.0h
ENV SHA256_OPENSSL=5835626cde9e99656585fc7aaa2302a73a7e1340bf8c14fd635a62c66802a517
ENV SOURCE_OPENSSL=https://www.openssl.org/source/
ENV GPG_OPENSSL=8657ABB260F056B1E5190839D9C4D26D0E604491

WORKDIR /tmp/src

RUN set -e -x && \
    BUILD_DEPS='build-essential ca-certificates curl dirmngr gnupg libidn2-0-dev libssl-dev' && \
    DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y --no-install-recommends \
      $BUILD_DEPS && \
    curl -L $SOURCE_OPENSSL$VERSION_OPENSSL.tar.gz -o openssl.tar.gz && \
    echo "${SHA256_OPENSSL} ./openssl.tar.gz" | sha256sum -c - && \
    curl -L $SOURCE_OPENSSL$VERSION_OPENSSL.tar.gz.asc -o openssl.tar.gz.asc && \
    export GNUPGHOME="$(mktemp -d)" && \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$GPG_OPENSSL" && \
    gpg --batch --verify openssl.tar.gz.asc openssl.tar.gz && \
    tar xzf openssl.tar.gz && \
    cd $VERSION_OPENSSL && \
    make clean && \
    ./config --prefix=/opt/openssl no-weak-ssl-ciphers no-ssl3 no-shared enable-ec_nistp_64_gcc_128 -DOPENSSL_NO_HEARTBEATS -fstack-protector-strong && \
    make depend && \
    make && \
    make install_sw && \
    apt-get purge -y --auto-remove \
      $BUILD_DEPS && \
    rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/*

FROM debian:stretch
LABEL maintainer="Matthew Vance"

ENV NAME=unbound \
    UNBOUND_VERSION=1.7.0 \
    UNBOUND_SHA256=94dd9071fb13d8ccd122a3ac67c4524a3324d0e771fc7a8a7c49af8abfb926a2 \
    UNBOUND_DOWNLOAD_URL=https://www.unbound.net/downloads/unbound-1.7.0.tar.gz \
    VERSION=0

ENV SUMMARY="${NAME} is a validating, recursive, and caching DNS resolver." \
    DESCRIPTION="${NAME} is a validating, recursive, and caching DNS resolver." 

LABEL summary="${SUMMARY}" \
      description="${DESCRIPTION}" \
      io.k8s.description="${DESCRIPTION}" \
      io.k8s.display-name="Unbound ${UNBOUND_VERSION}" \
      name="mvance/${NAME}" \
      maintainer="Matthew Vance"

EXPOSE 53

WORKDIR /tmp/src

COPY --from=openssl /opt/openssl /opt/openssl

RUN BUILD_DEPS='ca-certificates curl gcc libc-dev libevent-dev libexpat1-dev make' && \
    set -x && \
    DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y --no-install-recommends \
      $BUILD_DEPS \
      bsdmainutils \
      ldnsutils \
      libevent-2.0 \
      libexpat1 && \
    curl -sSL $UNBOUND_DOWNLOAD_URL -o unbound.tar.gz && \
    echo "${UNBOUND_SHA256} *unbound.tar.gz" | sha256sum -c - && \
    tar xzf unbound.tar.gz && \
    rm -f unbound.tar.gz && \
    cd unbound-1.7.0 && \
    groupadd _unbound && \
    useradd -g _unbound -s /etc -d /dev/null _unbound && \
    ./configure \
        --disable-dependency-tracking \
        --prefix=/opt/unbound \
        --with-pthreads \
        --with-username=_unbound \
        --with-ssl=/opt/openssl \
        --with-libevent \
        --enable-event-api && \
    make install && \
    mv /opt/unbound/etc/unbound/unbound.conf /opt/unbound/etc/unbound/unbound.conf.example && \
    rm -fr /opt/unbound/share/man && \
    apt-get purge -y --auto-remove \
      $BUILD_DEPS && \
    rm -fr /tmp/* /var/tmp/* /var/lib/apt/lists/*

COPY a-records.conf /opt/unbound/etc/unbound/
COPY unbound.sh /

RUN chmod +x /unbound.sh

WORKDIR /opt/unbound/

ENV PATH /opt/unbound/sbin:$PATH

CMD ["/unbound.sh"]
