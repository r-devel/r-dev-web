#! /bin/bash

# Build Tcl/Tk 8.6 bundle in Ubuntu 20.04 docker container
# see ../winutf8.md for more

CID=`docker run -dit ubuntu:22.04 /bin/bash`
docker cp ./bundle86.sh $CID:/root
docker cp ./tcl.patch $CID:/root

cat <<EOF | docker exec --interactive $CID  bash
apt-get update
echo "Europe/Prague" > /etc/timezone
env DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata
apt-get install -y mingw-w64 wget make findutils automake tcl patch zip libz-mingw-w64-dev
cd /root
bash -x bundle86.sh 2>&1 | tee bundle86.out
EOF

docker cp $CID:/root/Tcl.zip .
docker cp $CID:/root/bundle86.out .

# remove container if needed