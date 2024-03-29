FROM alpine:3.12
# FROM alpine:edge

LABEL maintainer="yueyanglouji <343468684@qq.com>"

ARG TZ='Asia/Shanghai'

USER root

ENV TZ ${TZ}
ENV SS_LIBEV_VERSION v3.3.5
ENV KCP_VERSION 20210922
ENV V2RAY_PLUGIN_VERSION v1.3.1
ENV SS_DOWNLOAD_URL https://github.com/shadowsocks/shadowsocks-libev.git 
ENV KCP_DOWNLOAD_URL https://github.com/xtaci/kcptun/releases/download/v${KCP_VERSION}/kcptun-linux-amd64-${KCP_VERSION}.tar.gz
ENV PLUGIN_OBFS_DOWNLOAD_URL https://github.com/shadowsocks/simple-obfs.git
ENV PLUGIN_V2RAY_DOWNLOAD_URL https://github.com/shadowsocks/v2ray-plugin/releases/download/${V2RAY_PLUGIN_VERSION}/v2ray-plugin-linux-amd64-${V2RAY_PLUGIN_VERSION}.tar.gz
# ENV LINUX_HEADERS_DOWNLOAD_URL=http://dl-cdn.alpinelinux.org/alpine/v3.7/main/x86_64/linux-headers-4.4.6-r2.apk
# ENV POLIPO_DOWNLOAD_URL https://github.com/yueyanglouji/polipo

RUN apk upgrade \
    && apk add bash tzdata rng-tools runit privoxy tor iptables\
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
        perl \
     && git config --global http.proxy 10.48.211.3:8118 \
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
    # && git clone ${POLIPO_DOWNLOAD_URL} \
    # && (cd polipo \
    # && make all \
    # && make install) \
     && export http_proxy=http://10.48.211.3:8118 \
     && export https_proxy=http://10.48.211.3:8118 \
	&& cp /etc/privoxy/config.new /etc/privoxy/config \
	&& cp /etc/privoxy/default.filter.new /etc/privoxy/default.filter \
	&& cp /etc/privoxy/regression-tests.action.new /etc/privoxy/regression-tests.action \
	&& cp /etc/privoxy/user.action.new /etc/privoxy/user.action \
	&& cp /etc/privoxy/default.action.new /etc/privoxy/default.action \
	&& cp /etc/privoxy/match-all.action.new /etc/privoxy/match-all.action \
	&& cp /etc/privoxy/trust.new /etc/privoxy/trust \
	&& cp /etc/privoxy/user.filter.new /etc/privoxy/user.filter \
	&& sed -i 's/logfile privoxy.log/# logfile privoxy.log/g' /etc/privoxy/config \
	&& cp -r /etc/privoxy /etc/privoxy-local-only \
	&& cp -r /etc/privoxy /etc/privoxy-ss-only \
	&& sed -i 's/127.0.0.1:8118/0.0.0.0:8118/g' /etc/privoxy/config \
	&& sed -i 's/127.0.0.1:8118/0.0.0.0:8117/g' /etc/privoxy-ss-only/config \
	&& sed -i 's/127.0.0.1:8118/0.0.0.0:8116/g' /etc/privoxy-local-only/config \
	&& curl -4sSkLO https://raw.github.com/zfl9/gfwlist2privoxy/master/gfwlist2privoxy \
	&& bash gfwlist2privoxy 127.0.0.1:1080 \
	&& mv -f gfwlist.action /etc/privoxy/ \
	&& echo 'actionsfile gfwlist.action' >> /etc/privoxy/config \
	&& echo 'actionsfile user-rule/user-rule.action' >> /etc/privoxy/config \
	&& echo 'forward-socks5t / 127.0.0.1:1080 .' >> /etc/privoxy-ss-only/config \
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
    # && adduser -h /tmp -s /sbin/nologin -S -D -H polipo \
    && apk del .build-deps \
    && apk add --no-cache \
      $(scanelf --needed --nobanner /usr/bin/ss-* /usr/local/bin/obfs-* \
      | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
      | sort -u) \
    && rm -rf /linux-headers-4.4.6-r2.apk \
        kcptun-linux-amd64-${KCP_VERSION}.tar.gz \
        shadowsocks-libev \
        simple-obfs \
		# polipo \
        v2ray_plugin.tar.gz \
        /etc/service \
        /var/cache/apk/*

SHELL ["/bin/bash"]

COPY runit /etc/service
COPY entrypoint.sh /entrypoint.sh
COPY user-rule /etc/privoxy

ENTRYPOINT ["/entrypoint.sh"]
