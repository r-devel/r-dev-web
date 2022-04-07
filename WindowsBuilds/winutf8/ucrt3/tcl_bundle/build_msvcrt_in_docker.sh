#! /bin/bash

# Build Tcl/Tk 8.6 bundle in an interactive Ubuntu docker container. The container
# will be left running unless customized at the bottom of the script. This uses
# the system cross-compilers from Ubuntu, which currently happen to be using MSVCRT
# (more in build_msvcrt.sh).
#
# WARNING: this script is no longer maintained because R uses UCRT and UCRT
# Tcl/Tk since R 4.2.

CID=`docker run -dit ubuntu:20.04 /bin/bash`
echo "Using container $CID"

mkdir -p build

docker stop $CID
docker cp ./build_msvcrt.sh $CID:/root
docker cp ./tcl.diff $CID:/root
docker start $CID

cat <<EOF | docker exec --interactive $CID  bash
apt-get update
echo "Europe/Prague" > /etc/timezone
env DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata
apt-get install -y mingw-w64 wget make findutils automake tcl patch zip libz-mingw-w64-dev
cd /root
bash -x ./build_msvcrt.sh 2>&1 | tee build.out
EOF

docker stop $CID
docker cp $CID:/root/build .
docker cp $CID:/root/build.out build

# remove container if needed
# docker rm -f $CID
