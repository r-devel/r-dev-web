#! /bin/bash

# Build Tcl/Tk 8.6 bundle in an interactive Ubuntu docker container using
# a cross-compilation toolchain.
#
# build_in_docker.sh [target] 
#
# This needs files
#
#   for target x86_64:
#     gcc14_ucrt3_base_REV.tar.zst
#     gcc14_ucrt3_cross_REV.tar.zst
#
#   for target aarch64:
#     llvm17_ucrt3_base_aarch64_REV.tar.zst
#     llvm17_ucrt3_cross_aarch64_REV.tar.zst
#     
# in the current directory, where REV is a revision number, e.g.  5168. 
# These files are produced by ../toolchain_libs and existing builds can
# be downloaded from https://www.r-project.org/nosvn/winutf8/ucrt3
#
# Target is the first (optional) argument, the default is x86_64.  It can be
# specified also as aarch64 or "all" (to build both targets).
#
# Tcl.zip (or Tcl_aarch64.zip) and textual outputs from the build will
# appear in the current directory.
#
# This script is used to create builds that appear as Tcl-REV-THISREV.zip and 
# Tcl-aarch64-REV-THISREV.zip at
# https://www.r-project.org/nosvn/winutf8/ucrt3, where REV is the revision
# number of the toolchain and THISREV is revision number of the script to
# build the Tcl/Tk bundle.
#
# After testing, the build appears in the current Rtools.  For Rtools XX (XX
# >= 42):
#
# https://cran.r-project.org/bin/windows/Rtools/rtoolsXX/files/
#
# as tcltk-REV-THISREV.zip and tcltk-aarch64-REV-THISREV.zip.  The aarch64
# builds are available there since Rtools44.

DOCKER=`which docker`
if [ "X$DOCKER" == X ]; then
  echo "Docker not on PATH."
  exit 1
fi

RTARGET="$1"
if [ "X$RTARGET" == X ] ; then
  RTARGET="x86_64"
fi

if [ "X${RTARGET}" != "Xaarch64" ] && [ "X${RTARGET}" != "Xx86_64" ] && \
   [ "X${RTARGET}" != "Xall" ]; then
   
  echo "Unsupported target."
  exit 1
fi

if [ ${RTARGET} == "all" ] ; then
  RTARGETS="x86_64 aarch64"
else
  RTARGETS=${RTARGET}
fi

CID=buildtcltk

for TGT in ${RTARGETS} ; do

  if [ $TGT == x86_64 ] ; then
    USRDIR="/usr/lib/mxe/usr"
    TCCFILE=`ls -1 gcc14_ucrt3_cross_[0-9]*.tar.zst | head -1`
    MXETARGET="x86_64-w64-mingw32.static.posix"
  else
    USRDIR="/usr/lib/mxe/usr_aarch64"
    TCCFILE=`ls -1 llvm17_ucrt3_cross_aarch64_[0-9]*.tar.zst | head -1`
    MXETARGET="aarch64-w64-mingw32.static.posix"
  fi

  if [ "X$TCCFILE" == X ] || [ ! -r $TCCFILE ] ; then
    echo "No cross-toolchain archive." >&2
    exit 1
  fi

  TLREV=`echo $TCCFILE | sed -e 's/.*_\([0-9]\+\).tar.zst/\1/g'`
  
  if [ $TGT == x86_64 ] ; then
    TCLFILE=`ls -1 gcc14_ucrt3_base_$TLREV.tar.zst | head -1`
  else
    TCLFILE=`ls -1 llvm17_ucrt3_base_aarch64_$TLREV.tar.zst | head -1`
  fi

  if [ ! -r $TCLFILE ] ; then
    echo "No (matching) toolchain libraries archive." >&2
    exit 1
  fi

  X=`docker container ls -a | sed -e 's/.* //g' | grep -v NAMES | grep '^'$CID'$'`
  NEEDTL=yes

  if [ "X$X" != X$CID ] ; then
    echo "Creating container $CID"
    docker create --name $CID -it ubuntu:24.04
    docker start $CID
    
    cat <<EOF | docker exec --interactive $CID bash -x
    apt-get update
    echo "Europe/Prague" > /etc/timezone
    env DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata
    apt-get install -y wget make findutils automake patch zip zstd tcl
    mkdir -p /usr/lib/mxe/usr
    mkdir -p /usr/lib/mxe/usr_aarch64
    cd /root
EOF

  else
    echo "Reusing container $CID"
  
    docker stop $CID
    rm -f .version
    docker cp $CID:$USRDIR/$MXETARGET/.version .
    if [ -r .version ] && [ X`cat .version` == X$TLREV ] ; then
      echo "Reusing toolchain in $CID"
      NEEDTL=no
    else
      echo "Removing old toolchain in $CID"
      docker start $CID
      cat <<EOF | docker exec --interactive $CID bash -x
      rm -rf /usr/lib/mxe/usr
      rm -rf /usr/lib/mxe/usr_aarch64      
      mkdir -p /usr/lib/mxe/usr
      mkdir -p /usr/lib/mxe/usr_aarch64
EOF
      docker stop $CID
    fi
    rm -f .version
    docker start $CID
  fi

  if [ $NEEDTL == yes ] ; then
    echo "Installing toolchain into $CID"
  
    docker stop $CID
    docker cp $TCCFILE $CID:$USRDIR
    docker cp $TCLFILE $CID:$USRDIR
    docker start $CID
  
    cat <<EOF | docker exec --interactive $CID bash -x
    cd $USRDIR
    tar xf $TCCFILE
    tar xf $TCLFILE
    # not really needed without cmake, but set for completeness
    ln -st x86_64-pc-linux-gnu/bin \
      ../../bin/${MXETARGET}-gcc \
      ../../bin/${MXETARGET}-g++
    rm -f $TCCFILE $TCLFILE
EOF
  fi

  docker stop $CID
  docker cp build_ucrt.sh $CID:/root
  docker cp tcl.diff $CID:/root
  docker cp tk.diff $CID:/root
  docker cp tktable.diff $CID:/root  
  docker start $CID

  cat <<EOF | docker exec --interactive $CID bash -x
    cd /root
    rm -rf build Tcl 64bit Tcl.zip *.out
    # note the escape to use PATH in the container
    export PATH=$USRDIR/bin:\$PATH
    bash -x ./build_ucrt.sh $TGT 2>&1 | tee build_ucrt.out
EOF

  docker stop $CID

  if [ $TGT == x86_64 ] ; then
    docker cp $CID:/root/build_ucrt.out .
    docker cp $CID:/root/Tcl.zip .
  else
    docker cp $CID:/root/build_ucrt.out build_ucrt_aarch64.out
    docker cp $CID:/root/Tcl.zip Tcl_aarch64.zip
  fi
done
