VERSION 0.6
FROM ubuntu:20.04

## for apt to be noninteractive
ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

RUN apt-get update && apt-get install -y build-essential cmake  m4 automake autoconf libtool pandoc pkg-config libevent-dev

WORKDIR /code

code:
  COPY pgbouncer pgbouncer

build:
    FROM +code
    RUN cd pgbouncer && ./autogen.sh
    RUN cd pgbouncer && ./configure --host="aarch64-linux-gnu" --build="x86_64-pc-linux-gnu"  --without-openssl
    RUN cd pgbouncer && make
    SAVE ARTIFACT pgbouncer/pgbouncer AS LOCAL build/demo

package:
    FROM +build
    RUN mkdir package
    RUN cp pgbouncer/pgbouncer package/pgbouncer
    RUN mkdir package/DEBIAN
    RUN cat <<EOF > package/DEBIAN/control \
Package: pgbouncer \
Version: 0.0.1 \
Maintainer: Gerry Bennett \<gerry.bennett@ninjaone.com\> \
Depends: libc6 \
Architecture: amd64 \
Homepage: https://www.pgbouncer.org/ \
Description: PGBouncer \
EOF
    RUN mkdir -pv release
    RUN dpkg --build package
    # SAVE ARTIFACT 