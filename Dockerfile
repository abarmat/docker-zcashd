FROM ubuntu:latest
MAINTAINER Ariel Barmat <abarmat@gmail.com>

ENV ZCASH_URL=https://github.com/zcash/zcash.git 
ENV ZCASH_VERSION=v2.0.1
ENV ZCASH_CONF=/home/zcash/.zcash/zcash.conf
ENV ZCASH_SRC_DIR=/src/zcash
ENV NPROC=2

# Base packages
RUN apt-get autoclean && apt-get autoremove && apt-get update && \
      apt-get install -y \
      build-essential pkg-config libc6-dev m4 g++-multilib \
      autoconf libtool ncurses-dev unzip git python python-zmq \
      zlib1g-dev wget curl bsdmainutils automake

RUN apt-get install pwgen 

# Cleanup
RUN rm -rf /var/lib/apt/lists/*

# Checkout
RUN mkdir -p ${ZCASH_SRC_DIR}; cd ${ZCASH_SRC_DIR} && \
      git clone ${ZCASH_URL} zcash && cd zcash && git checkout ${ZCASH_VERSION}

# Build
RUN cd ${ZCASH_SRC_DIR}/zcash && ./zcutil/build.sh -j${NPROC}

# Install
RUN cd ${ZCASH_SRC_DIR}/zcash/src && \
      /usr/bin/install -c zcash-tx zcashd zcash-cli zcash-gtest -t /usr/local/bin/ && \
      rm -rf ${ZCASH_SRC_DIR}

# Config
RUN adduser --uid 1000 --system zcash && \
      mkdir -p /home/zcash/.zcash/ && \
      chown -R zcash /home/zcash && \
      echo "Config location"

USER zcash
RUN echo "rpcuser=zcash" > ${ZCASH_CONF} && \
      echo "rpcpassword=`pwgen 20 1`" >> ${ZCASH_CONF} && \
      echo "addnode=mainnet.z.cash" >> ${ZCASH_CONF} && \
      echo "Config done!"

VOLUME /home/zcash/.zcash
VOLUME /home/zcash/.zcash-params
