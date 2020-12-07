#! /bin/bash

# Build gcc10 (cross and native) toolchain to x86_84 Windows and a number of
# static libaries in an interactive Ubuntu docker container.  The container
# will be left running unless customized at the bottom of the script.

CID=`docker run -dit ubuntu:20.04 /bin/bash`
echo "Using container $CID"

mkdir -p build

docker stop $CID
docker cp mxe $CID:/root
docker cp build.sh $CID:/root
docker start $CID

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
apt-get install -y texinfo sqlite3

cd /root
bash -x ./build.sh 2>&1 | tee build.out
EOF

docker stop $CID

docker cp $CID:/root/build .
docker cp $CID:/root/build.out build

# remove container if needed
# docker rm -f $CID
