#! /bin/bash

# build_in_docker.sh [target] [compression_level]
#
# Build the cross and native toolchain and a number of static libraries in
# an interactive docker container.  The container is by default re-used
# across builds, particularly the downloaded source packages and the ccache
# cache of compiled object files, to speed up the builds.  The builds
# execute under root account in the container and the installation (/root).
#
# The first (optional) argument is the target, which can be x86_64 (the
# default), aarch64 and "all" (to build both of them).  For x86_64, this
# builds a gcc12 toolchain and the installation location is
# /usr/lib/mxe/usr, for aarch64, this uses an llvm16 toolchain and the
# /installation location is /usr/lib/mxe/usr_aarch64.
#
# The second (optional) argument is the zstd compression level used for the
# tarballs.  The default is 22 (maximum compression).  A different value can
# be set for faster builds, but producing larger tarballs.

# IMAGE           DISTRIBUTION
#
# ubuntu:22.04    debian
# ubuntu:20.04    debian
# debian:11       debian
#
# fedora:36       fedora
# fedora:35       fedora
#
# Not supported:
#   debian:9 - too old to build e.g. flac (which needs aclocal-1.16)
#
# Supported recently:
#   debian:10
#   fedora 34, 33, 32
#
# The script will create directory "build" in the current directory with tarballs
#
# gcc12_ucrt3_full.tar.zst         native compilers and full set of Rtools libraries
# (llvm16_ucrt3_full_aarch64.tar.zst)
#
# gcc12_ucrt3_full_cross.tar.zst   cross compiler and cross-tools from a full build
# (llvm16_ucrt3_full_cross_aarch64.tar.zst)
#
# gcc12_ucrt3_base.tar.zst         native compilers and a subset of Rtools libraries
# (llvm16_ucrt3_base_aarch64.tar.zst)
#
# gcc12_ucrt3_base_cross.tar.zst   cross compiler and cross-tools from a base build
#                                  (normally not used, but e.g. would be enough to
#                                   cross-compile R)
# (llvm16_ucrt3_base_cross_aarch64.tar.zst)
#
# This script is used to create builds available at
# https://www.r-project.org/nosvn/winutf8/ucrt3/
# as 
#
# gcc12_ucrt3_base_REV.tar.zst     copy of gcc12_ucrt3_base.tar.zst
# gcc12_ucrt3_cross_REV.tar.zst    copy of gcc12_ucrt3_full_cross.tar.zst
# gcc12_ucrt3_full_REV.tar.zst     copy of gcc12_ucrt3_full.tar.zst
#
# llvm16_ucrt3_base_aarch64_REV.tar.zst   copy of llvm16_ucrt3_base_aarch64.tar.zst
# llvm16_ucrt3_cross_aarch64_REV.tar.zst  copy of llvm16_ucrt3_full_cross_aarch64.tar.zst
# llvm16_ucrt3_full_aarch64_REV.tar.zst   copy of llvm16_ucrt3_full_aarch64.tar.zst
#
# where REV is the revision of these scripts and sources to build the
# toolchain.  After testing, the build appears in the current Rtools, at the
# time of this writing in Rtools43 at
#
# https://cran.r-project.org/bin/windows/Rtools/rtools43/files/
#
# rtools43-toolchain-libs-base-REV.tar.zst
# rtools43-toolchain-libs-cross-REV.tar.zst
# rtools43-toolchain-libs-full-REV.tar.zst
#
# (llvm16 builds are experimental and do not appear there)
#
 
IMAGE=ubuntu:20.04
DISTRIBUTION=debian

DOCKER=`which docker`
if [ "X$DOCKER" == X ]; then
  echo "Docker not on PATH."
  exit 1
fi

RTARGET="$1"
if [ "X$RTARGET" == X ] ; then
  RTARGET="x86_64"
fi

CLEVEL="$2"
if [ "XCLEVEL" == X ] ; then
  CLEVEL="22"
fi

if [ ${RTARGET} != "aarch64" ] && [ ${RTARGET} != "x86_64" ] && \
   [ ${RTARGET} != "all" ]; then
   
  echo "Unsupported target."
  exit 1
fi

CID=buildtl

X=`docker container ls -a | sed -e 's/.* //g' | grep -v NAMES | grep '^'$CID'$'`

if [ "X$DISTRIBUTION" != "Xdebian" ] && [ "X$DISTRIBUTION" != "Xfedora" ] ; then
  echo "Unsupported DISTRIBUTION" >&2
  exit 1
fi

mkdir -p build

if [ "X$X" != X$CID ] ; then
  echo "Creating container $CID"
  docker create --name $CID -it \
    -v `pwd`:'/toolchain_libs_ro':ro \
    $IMAGE
  docker start $CID
  
  if [ "X$DISTRIBUTION" == "Xdebian" ] ; then
    cat <<EOF | docker exec --interactive $CID bash -x
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
      python3 \
      python3-mako \
      python3-setuptools \
      python2 \
      python-is-python3 \
      ruby \
      sed \
      unzip \
      wget \
      xz-utils

    # texinfo for binutils
    # sqlite3 for proj
    apt-get install -y texinfo sqlite3 zstd
    
    # for gnutls
    apt-get install -y gtk-doc-tools
    
    # for qt6-qtbase
    apt-get install -y libopengl-dev libglu1-mesa-dev
EOF

  elif [ "X$DISTRIBUTION" == "Xfedora" ] ; then
    #dnf -y upgrade

    cat <<EOF | docker exec --interactive $CID bash -x
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
        python3 \
        python3-mako \
        python3-setuptools \
        python-is-python3 \
        ruby \
        sed \
        unzip \
        wget \
        xz

      # texinfo for binutils
      # sqlite for proj
      # python2 for libv8
      dnf -y install texinfo sqlite zstd python2
    
      # for gnutls
      dnf -y install gtk-doc
    
      # needed by MXE
      dnf -y install which openssl
      
      # for qt6-qtbase
      dnf -y install mesa-libGLU-devel
EOF
  else
    echo "Unsupported DISTRIBUTION" >&2
    exit 1
  fi

  cat <<EOF | docker exec --interactive $CID bash -x
    mkdir -p /usr/lib/mxe/usr
    cd /root
    cp -Rpdf /toolchain_libs_ro/mxe .
EOF
  
else
  echo "Reusing container $CID"

  docker stop $CID
  docker start $CID

  cat <<'EOF' | docker exec --interactive $CID bash -x
    mkdir -p /usr/lib/mxe/usr
    cd /root
    rm -rf mxe_old
    if [ -d mxe ] ; then
      mv mxe mxe_old
    fi
    cp -Rpdf /toolchain_libs_ro/mxe .
    for F in mxe_old/.ccache_* mxe_old/log mxe_old/pkg mxe_old/usr_base_* mxe_old/usr_full_* ; do
      if [ -r "$F" ] ; then
        rm -rf mxe/`basename $F`
        mv $F mxe
        echo "Re-using previous `basename $F`"
      fi
    done
EOF
fi
     
docker stop $CID
docker cp build.sh $CID:/root
docker start $CID

cat <<EOF | docker exec --interactive $CID bash -x
  cd /root
  if [ "${RTARGET}" == "all" ] || [ "${RTARGET}" == "x86_64" ] ; then
    bash -x ./build.sh /usr/lib/mxe/usr x86_64 $CLEVEL 2>&1 | tee build.out
  fi
  if [ "${RTARGET}" == "all" ] || [ "${RTARGET}" == "aarch64" ] ; then
    bash -x ./build.sh /usr/lib/mxe/usr_aarch64 aarch64 $CLEVEL 2>&1 | tee build_aarch64.out
  fi
EOF

docker stop $CID

docker cp $CID:/root/build .

if [ "${RTARGET}" == "all" ] || [ "${RTARGET}" == "aarch64" ] ; then
  docker cp $CID:/root/build_aarch64.out build
fi

if [ "${RTARGET}" == "all" ] || [ "${RTARGET}" == "x86_64" ] ; then
  docker cp $CID:/root/build.out build
fi
