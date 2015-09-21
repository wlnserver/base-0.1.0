#
# WlnServer Base-0.1.0 Dockerfile
#
# https://github.com/wlnserver/base-0.1.0
#
# Pull base image.
#FROM ubuntu:latest
FROM debian:jessie
ENV NODE_VERSION 0.10.39
ENV NPM_VERSION 2.11.3
ENV WLNIAO_PORT 80
MAINTAINER WlniaoStudio <admin@wlniao.com>
    
RUN apt-get update \
    && apt-get install -y vim \
    && apt-get install -y unzip \
    && apt-get install -y curl \
    && apt-get install -y gcc \
    && apt-get install -y automake \
    && apt-get install -y make \
    && apt-get install -y autoconf \
    && apt-get install -y libtool \
    && apt-get install -y ca-certificates \
    && apt-get install -y git \
    && apt-get install -y subversion 

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF \
    && echo "deb http://download.mono-project.com/repo/debian wheezy main" | tee /etc/apt/sources.list.d/mono-xamarin.list \
    && echo "deb http://download.mono-project.com/repo/debian wheezy-apache24-compat main" | tee -a /etc/apt/sources.list.d/mono-xamarin.list \
    && apt-get install -y mono-complete 
    
RUN curl -sSL https://github.com/libuv/libuv/archive/v1.4.2.tar.gz | tar zxfv - -C /usr/local/src \
    && cd /usr/local/src/libuv-1.4.2 \
    && sh autogen.sh \
    && ./configure \
    && make \
    && make install \
    && rm -rf /usr/local/src/libuv-1.4.2 && cd ~/ \
    && ldconfig
    
#RUN curl -sSL https://raw.githubusercontent.com/aspnet/Home/dev/dnvminstall.sh | DNX_BRANCH=dev sh && source ~/.dnx/dnvm/dnvm.sh
RUN curl -sSL https://raw.githubusercontent.com/aspnet/Home/dev/dnvminstall.sh | DNX_BRANCH=dev sh && source ~/.dnx/dnvm/dnvm.sh && dnvm upgrade -r coreclr

    
    
# verify gpg and sha256: http://nodejs.org/dist/v0.10.31/SHASUMS256.txt.asc
RUN gpg --keyserver pool.sks-keyservers.net --recv-keys 7937DFD2AB06298B2293C3187D33FF9D0246406D 114F43EE0176B71C7BC219DD50A3051F888C628D
RUN buildDeps='curl ca-certificates' \
    && set -x \
    && apt-get install -y $buildDeps --no-install-recommends \
    && rm -rf /var/lib/apt/lists/* \
    && curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz" \
    && curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
    && gpg --verify SHASUMS256.txt.asc \
    && grep " node-v$NODE_VERSION-linux-x64.tar.gz\$" SHASUMS256.txt.asc | sha256sum -c - \
    && tar -xzf "node-v$NODE_VERSION-linux-x64.tar.gz" -C /usr/local --strip-components=1 \
    && rm "node-v$NODE_VERSION-linux-x64.tar.gz" SHASUMS256.txt.asc \
    && apt-get purge -y --auto-remove $buildDeps \
    && npm install -g npm@"$NPM_VERSION" \
    && npm install -g nodemon
    

EXPOSE $WLNIAO_PORT
RUN mkdir /src 
WORKDIR /src
