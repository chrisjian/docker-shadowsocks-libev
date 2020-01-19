#
# Dockerfile for shadowsocks-libev
#

FROM alpine:3.10
MAINTAINER EasyPi Software Foundation

ARG SS_VER
ENV SS_URL https://github.com/shadowsocks/shadowsocks-libev/archive/v$SS_VER.tar.gz
ENV SS_DIR shadowsocks-libev-$SS_VER

ENV SIMPLE_OBFS_VER 0.0.5
ENV SIMPLE_OBFS_URL https://github.com/shadowsocks/simple-obfs/archive/v$SIMPLE_OBFS_VER.tar.gz
ENV SIMPLE_OBFS_DIR simple-obfs-$SIMPLE_OBFS_VER

RUN set -ex \
    && apk add --no-cache c-ares \
                          libcrypto1.1 \
                          libev \
                          libsodium \
                          mbedtls \
                          pcre \
    && apk add --no-cache --virtual TMP gcc make libtool zlib-dev openssl asciidoc xmlto libpcre32 g++ linux-headers \
    && apk add --no-cache \
               --virtual TMP autoconf \
                             automake \
                             build-base \
                             c-ares-dev \
                             curl \
                             gettext-dev \
                             libev-dev \
                             libsodium-dev \
                             libtool \
                             linux-headers \
                             mbedtls-dev \
                             openssl-dev \
                             pcre-dev \
                             tar \
    && curl -sSL $SS_URL | tar xz \
    && cd $SS_DIR \
        && curl -sSL https://github.com/shadowsocks/ipset/archive/shadowsocks.tar.gz | tar xz --strip 1 -C libipset \
        && curl -sSL https://github.com/shadowsocks/libcork/archive/shadowsocks.tar.gz | tar xz --strip 1 -C libcork \
        && curl -sSL https://github.com/shadowsocks/libbloom/archive/master.tar.gz | tar xz --strip 1 -C libbloom \
        && ./autogen.sh \
        && ./configure --disable-documentation \
        && make install \
        && cd .. \
        && rm -rf $SS_DIR \
    && curl -sSL $SIMPLE_OBFS_URL | tar xz \
    && cd $SIMPLE_OBFS_DIR \
        && curl -sSL https://github.com/shadowsocks/libcork/archive/shadowsocks.tar.gz | tar xz --strip 1 -C libcork \
        && ./autogen.sh \
        && ./configure --disable-documentation \
        && make install \
        && cd .. \
        && rm -rf $SIMPLE_OBFS_DIR \
    && apk del TMP

ENV SERVER_ADDR 0.0.0.0
ENV SERVER_PORT 8388
ENV METHOD      aes-256-cfb
ENV PASSWORD=
ENV TIMEOUT     60
ENV DNS_ADDR    8.8.8.8

EXPOSE $SERVER_PORT/tcp
EXPOSE $SERVER_PORT/udp

CMD ss-server -s "$SERVER_ADDR" \
              -p "$SERVER_PORT" \
              -m "$METHOD"      \
              -k "$PASSWORD"    \
              -t "$TIMEOUT"     \
              -d "$DNS_ADDR"    \
              --plugin obfs-server --plugin-opts "obfs=http" \
              -u                \
              --fast-open $OPTIONS \
              -v
