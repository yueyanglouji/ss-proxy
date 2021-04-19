FROM alpine:3.12

LABEL maintainer="mritd <mritd@linux.com>"

ARG TZ='Asia/Shanghai'

ENV TZ ${TZ}
ENV SS_LIBEV_VERSION v3.3.5
ENV KCP_VERSION 20201126
ENV V2RAY_PLUGIN_VERSION v1.3.1
ENV SS_DOWNLOAD_URL https://github.com/shadowsocks/shadowsocks-libev.git 
ENV KCP_DOWNLOAD_URL https://github.com/xtaci/kcptun/releases/download/v${KCP_VERSION}/kcptun-linux-amd64-${KCP_VERSION}.tar.gz
ENV PLUGIN_OBFS_DOWNLOAD_URL https://github.com/shadowsocks/simple-obfs.git
ENV PLUGIN_V2RAY_DOWNLOAD_URL https://github.com/shadowsocks/v2ray-plugin/releases/download/${V2RAY_PLUGIN_VERSION}/v2ray-plugin-linux-amd64-${V2RAY_PLUGIN_VERSION}.tar.gz
#ENV LINUX_HEADERS_DOWNLOAD_URL=http://dl-cdn.alpinelinux.org/alpine/v3.7/main/x86_64/linux-headers-4.4.6-r2.apk
ENV POLIPO_DOWNLOAD_URL https://github.com/yueyanglouji/polipo

RUN apk upgrade \
    && apk add bash tzdata rng-tools runit squid \
    && apk add --virtual .build-deps \
        autoconf \
        automake \
        build-base \
        curl \
        linux-headers \
        c-ares-dev \
        libev-dev \
        libtool \
        libcap \
        libsodium-dev \
        mbedtls-dev \
        pcre-dev \
        tar \
        git \
		texinfo \
	&& git config --global http.proxy 10.48.211.15:1087 \
    && git clone ${SS_DOWNLOAD_URL} \
    && (cd shadowsocks-libev \
    && git checkout tags/${SS_LIBEV_VERSION} -b ${SS_LIBEV_VERSION} \
    && git submodule update --init --recursive \
    && ./autogen.sh \
    && ./configure --prefix=/usr --disable-documentation \
    && make install) \
    && git clone ${PLUGIN_OBFS_DOWNLOAD_URL} \
    && (cd simple-obfs \
    && git submodule update --init --recursive \
    && ./autogen.sh \
    && ./configure --disable-documentation \
    && make install) \
	&& git clone ${POLIPO_DOWNLOAD_URL} \
	&& (cd polipo \
	&& make all \
	&& make install) \
	&& export http_proxy=http://10.48.211.15:1087 \
	&& export https_proxy=http://10.48.211.15:1087 \
    && curl -o v2ray_plugin.tar.gz -sSL ${PLUGIN_V2RAY_DOWNLOAD_URL} \
    && tar -zxf v2ray_plugin.tar.gz \
    && mv v2ray-plugin_linux_amd64 /usr/bin/v2ray-plugin \
    && curl -sSLO ${KCP_DOWNLOAD_URL} \
    && tar -zxf kcptun-linux-amd64-${KCP_VERSION}.tar.gz \
    && mv server_linux_amd64 /usr/bin/kcpserver \
    && mv client_linux_amd64 /usr/bin/kcpclient \
    && for binPath in `ls /usr/bin/ss-* /usr/local/bin/obfs-* /usr/bin/kcp* /usr/bin/v2ray*`; do \
            setcap CAP_NET_BIND_SERVICE=+eip $binPath; \
       done \
    && ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo ${TZ} > /etc/timezone \
    && adduser -h /tmp -s /sbin/nologin -S -D -H shadowsocks \
    && adduser -h /tmp -s /sbin/nologin -S -D -H kcptun \
	&& adduser -h /tmp -s /sbin/nologin -S -D -H polipo \
	&& adduser -h /tmp -s /sbin/nologin -S -D -H squid \
	&& echo "0       5       1       *       *       squid /usr/sbin/squid -k rotate -f /etc/squid/squid.conf" >> /etc/crontabs/root \
    && apk del .build-deps \
    && apk add --no-cache \
      $(scanelf --needed --nobanner /usr/bin/ss-* /usr/local/bin/obfs-* \
      | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
      | sort -u) \
    && rm -rf /linux-headers-4.4.6-r2.apk \
        kcptun-linux-amd64-${KCP_VERSION}.tar.gz \
        shadowsocks-libev \
        simple-obfs \
        v2ray_plugin.tar.gz \
        /etc/service \
        /var/cache/apk/*

SHELL ["/bin/bash"]

COPY runit /etc/service
COPY entrypoint.sh /entrypoint.sh
COPY polipo.conf /etc

ENTRYPOINT ["/entrypoint.sh"]