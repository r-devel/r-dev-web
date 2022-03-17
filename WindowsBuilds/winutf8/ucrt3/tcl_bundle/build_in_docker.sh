#! /bin/bash

# Build Tcl/Tk 8.6 bundle in an interactive Ubuntu docker container using
# gcc10_ucrt3 cross-compilation toolchain. Files gcc10_ucrt3_cross*tar.zst and 
# gcc10_ucrt3_base*tar.zst must be in the current directory. Tcl.zip will appear
# in the current directory.

DOCKER=`which docker`
if [ "X$DOCKER" == X ]; then
  echo "Docker not on PATH."
  exit 1
fi

CID=buildtcltk

TCCFILE=`ls -1 gcc10_ucrt3_cross*tar.zst | head -1`

if [ "X$TCCFILE" == X ] || [ ! -r $TCCFILE ] ; then
  echo "No cross-toolchain archive." >&2
  exit 1
fi

TLREV=`echo $TCCFILE | sed -e 's/.*_\([0-9]\+\).tar.zst/\1/g'`
TCLFILE=`ls -1 gcc10_ucrt3_base_$TLREV.tar.zst | head -1`

if [ ! -r $TCLFILE ] ; then
  echo "No (matching) toolchain libraries archive." >&2
  exit 1
fi

X=`docker container ls -a | sed -e 's/.* //g' | grep -v NAMES | grep '^'$CID'$'`
NEEDTL=yes

if [ "X$X" != X$CID ] ; then
  echo "Creating container $CID"
  docker create --name $CID -it ubuntu:20.04
  docker start $CID
    
  cat <<EOF | docker exec --interactive $CID bash -x
  apt-get update
  echo "Europe/Prague" > /etc/timezone
  env DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata
  apt-get install -y wget make findutils automake patch zip zstd tcl
  mkdir -p /usr/lib/mxe/usr
  cd /root
EOF

else
  echo "Reusing container $CID"
  
  docker stop $CID
  rm -f .version
  docker cp $CID:/usr/lib/mxe/usr/x86_64-w64-mingw32.static.posix/.version .
  if [ -r .version ] && [ X`cat .version` == X$TLREV ] ; then
    echo "Reusing toolchain in $CID"
    NEEDTL=no
  else
    echo "Removing old toolchain in $CID"
    cat <<EOF | docker exec --interactive $CID bash -x
    rm -rf /usr/lib/mxe/usr
    mkdir -p /usr/lib/mxe/usr
EOF
  fi
  rm -f .version
  docker start $CID
fi

if [ $NEEDTL == yes ] ; then

  echo "Installing toolchain into $CID"
  
  docker stop $CID
  docker cp $TCCFILE $CID:/usr/lib/mxe/usr
  docker cp $TCLFILE $CID:/usr/lib/mxe/usr
  docker start $CID
  
  cat <<EOF | docker exec --interactive $CID bash -x
  cd /usr/lib/mxe/usr
  tar xf $TCCFILE
  tar xf $TCLFILE
  rm -f $TCCFILE $TCLFILE
EOF
fi

docker stop $CID
docker cp build_ucrt.sh $CID:/root
docker cp tcl.diff $CID:/root
docker cp tk.diff $CID:/root
docker start $CID

cat <<'EOF' | docker exec --interactive $CID bash -x
  cd /root
  rm -rf build Tcl 64bit Tcl.zip *.out
  export PATH=/usr/lib/mxe/usr/bin:$PATH
  bash -x ./build_ucrt.sh 2>&1 | tee build_ucrt.out
EOF

docker stop $CID

docker cp $CID:/root/build_ucrt.out .
docker cp $CID:/root/Tcl.zip .
