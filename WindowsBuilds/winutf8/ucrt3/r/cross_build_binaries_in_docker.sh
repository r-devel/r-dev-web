#! /bin/bash

# Cross-compile binaries of the latest R-devel and recommended packages into
# a bundle, which can be used on a Windows host to cross-build an R
# installer.
#
# Currently this supports building Windows/aarch64 binaries on Linux/x86_64
# host.
#
# cross_build_binaries_in_docker.sh
#
# The needed files are
#
#     llvm19_ucrt3_base_aarch64_REV.tar.zst
#     llvm19_ucrt3_cross_aarch64_REV.tar.zst
#     Tcl-aarch64-REV-REV1.zip 
#
# in the current directory: the base toolchain libraries, the
# cross-toolchain (../toolchain_libs, and the Tcl bundle for the target
# (../tcl_bundle).
#
# The results appear in current directory under "cross", including a tarball
# of the result binaries and the build tree.  The build uses the latest
# version from subversion, the revision number can be found in file
# SVN-REVISION in the build tree.

DOCKER=`which docker`
if [ "X$DOCKER" == X ]; then
  echo "Docker not on PATH."
  exit 1
fi

CID=buildrbinaries

USRDIR="/usr/lib/mxe/usr_aarch64"
TCCFILE=`ls -1 llvm19_ucrt3_cross_aarch64_[0-9]*.tar.zst | head -1`
MXETARGET="aarch64-w64-mingw32.static.posix"

if [ "X$TCCFILE" == X ] || [ ! -r $TCCFILE ] ; then
  echo "No cross-toolchain archive." >&2
  exit 1
fi

TLREV=`echo $TCCFILE | sed -e 's/.*_\([0-9]\+\).tar.zst/\1/g'`
TCLFILE=`ls -1 llvm19_ucrt3_base_aarch64_$TLREV.tar.zst | head -1`

if [ ! -r $TCLFILE ] ; then
  echo "No (matching) toolchain libraries archive." >&2
  exit 1
fi

TCBFILE=`ls -1 Tcl-aarch64*zip | head -1`

if [ "X$TCBFILE" == X ] || [ ! -r $TCBFILE ] ; then
  echo "No Tcl/Tk bundle." >&2
  exit 1
fi

X=`docker container ls -a | sed -e 's/.* //g' | grep -v NAMES | grep '^'$CID'$'`
NEEDTL=yes

if [ "X$X" != X$CID ] ; then
  echo "Creating container $CID"
  docker create --name $CID -it ubuntu:24.04
  docker start $CID
    
  cat <<EOF | docker exec --interactive $CID bash -x
  sed -i 's/^# deb-src/deb-src/g' /etc/apt/sources.list
  apt-get update
  echo "Europe/Prague" > /etc/timezone
  env DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata
  apt-get -y build-dep r-base
  apt-get -y install rsync subversion libpcre2-dev zstd unzip
  mkdir -p $USRDIR
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
    rm -rf $USRDIR
    mkdir -p $USRDIR
EOF
    docker stop $CID
  fi
  rm -f .version
  docker start $CID

  cat <<EOF | docker exec --interactive $CID bash -x
  cd /root
  rm -rf *.diff
EOF

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
  rm -f $TCCFILE $TCLFILE
EOF
fi

docker stop $CID
docker cp cross_build_binaries.sh $CID:/root
docker cp $TCBFILE $CID:/root
for F in r_*.diff ; do
  docker cp $F $CID:/root
done

docker start $CID

cat <<EOF | docker exec --interactive $CID bash -x
  cd /root
  rm -rf cross *.out
  bash -x ./cross_build_binaries.sh $TGT 2>&1 | tee cross_build.out
EOF

docker stop $CID

rm -rf cross cross_build.out

docker cp $CID:/root/cross_build.out cross_build.out
docker cp $CID:/root/cross .
