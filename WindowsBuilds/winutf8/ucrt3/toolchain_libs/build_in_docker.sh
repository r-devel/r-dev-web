#! /bin/bash

# Build gcc10 (cross and native) toolchain to x86_84 Windows and a number of
# static libaries in an interactive docker container.  The container
# will be left running unless customized at the bottom of the script.

# IMAGE           DISTRIBUTION
#
# ubuntu:20.04    debian
# debian:10       debian
# debian:11       debian
#
# fedora:34       fedora
# fedora:33       fedora
# fedora:32       fedora
#
# Not supported:
#   debian:9 - too old to build e.g. flac (which needs aclocal-1.16)

IMAGE=ubuntu:20.04
DISTRIBUTION=debian

CID=`docker run -dit $IMAGE /bin/bash`

echo "Using container $CID"

mkdir -p build

docker stop $CID
docker cp mxe $CID:/root
docker cp build.sh $CID:/root
docker start $CID

if [ "X$DISTRIBUTION" == "Xdebian" ] ; then
  cat <<EOF | docker exec --interactive $CID bash
  apt-get update
  echo "Europe/Prague" > /etc/timezone
  env DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata

  # from MXE documentation
  apt-get install -y \
    autoconf \
    automake \
    autopoint \
    bash \
    bison \
    bzip2 \
    flex \
    g++ \
    g++-multilib \
    gettext \
    git \
    gperf \
    intltool \
    libc6-dev-i386 \
    libgdk-pixbuf2.0-dev \
    libltdl-dev \
    libssl-dev \
    libtool-bin \
    libxml-parser-perl \
    lzip \
    make \
    openssl \
    p7zip-full \
    patch \
    perl \
    python \
    ruby \
    sed \
    unzip \
    wget \
    xz-utils

  # texinfo for binutils
  # sqlite3 for proj
  apt-get install -y texinfo sqlite3 zstd
EOF

elif [ "X$DISTRIBUTION" == "Xfedora" ] ; then
  #dnf -y upgrade

  cat <<EOF | docker exec --interactive $CID bash
    # from MXE documentation
    dnf -y install \
      autoconf \
      automake \
      bash \
      bison \
      bzip2 \
      flex \
      gcc-c++ \
      gdk-pixbuf2-devel \
      gettext \
      git \
      gperf \
      intltool \
      libtool \
      lzip \
      make \
      openssl-devel \
      p7zip \
      patch \
      perl \
      python \
      ruby \
      sed \
      unzip \
      wget \
      xz

    # texinfo for binutils
    # sqlite for proj
    # python2, dash for libv8
    dnf -y install texinfo sqlite zstd python2 dash
    
    # for libv8
    ln -sf dash /bin/sh

    # needed by MXE
    dnf -y install which openssl
EOF

else
  echo "Unsupported DISTRIBUTION" >&2
  exit 1
fi

cat <<EOF | docker exec --interactive $CID bash
  cd /root
  bash -x ./build.sh 2>&1 | tee build.out
EOF

docker stop $CID

docker cp $CID:/root/build .
docker cp $CID:/root/build.out build

# remove container if needed
# docker rm -f $CID
