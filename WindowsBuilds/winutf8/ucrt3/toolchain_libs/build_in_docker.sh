#! /bin/bash

# Build gcc12 (cross and native) toolchain to x86_84 Windows and a number of
# static libaries in an interactive docker container.  The container is by
# default re-used across builds, particularly the downloaded source packages
# and the ccache cache of compiled object files, to speed up the builds. 
# The builds execute under root in the container and the installation location is
# /usr/lib/mxe/usr.

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
# gcc12_ucrt3_full_cross.tar.zst   cross compiler and cross-tools from a full build
#
# gcc12_ucrt3_base.tar.zst         native compilers and a subset of Rtools libraries
# gcc12_ucrt3_base_cross.tar.zst   cross compiler and cross-tools from a base build
#                                  (normally not used, but e.g. would be enough to
#                                   cross-compile R)
#
# This script is used to create builds available at
# https://www.r-project.org/nosvn/winutf8/ucrt3/
# as 
#
# gcc12_ucrt3_base_REV.tar.zst     copy of gcc12_ucrt3_base.tar.zst
# gcc12_ucrt3_cross_REV.tar.zst    copy of gcc12_ucrt3_full_cross.tar.zst
# gcc12_ucrt3_full_REV.tar.zst     copy of gcc12_ucrt3_full.tar.zst
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
 
IMAGE=ubuntu:20.04
DISTRIBUTION=debian

DOCKER=`which docker`
if [ "X$DOCKER" == X ]; then
  echo "Docker not on PATH."
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
    for F in .ccache log pkg usr_base usr_full ; do
      if [ -r mxe_old/$F ] ; then
        rm -rf mxe/$F
        mv mxe_old/$F mxe
        echo "Re-using previous $F"
      fi
    done
EOF
fi
     
docker stop $CID
docker cp build.sh $CID:/root
docker start $CID

cat <<EOF | docker exec --interactive $CID bash -x
  cd /root
  bash -x ./build.sh /usr/lib/mxe/usr 2>&1 | tee build.out
EOF

docker stop $CID

docker cp $CID:/root/build .
docker cp $CID:/root/build.out build
