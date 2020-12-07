#! /bin/bash

# Build toolchain and libraries using MXE
#
# See build_in_docker.sh for dependencies on Ubuntu 20.04
#

# Adapt number of CPUs for the build below
CPUS=`cat /proc/cpuinfo | grep ^physical.*0 | wc -l`

mkdir build
cd mxe
make -j ${CPUS} 2>&1 | tee make.out
cp make.out ../build

cd usr
tar cfh - x86_64-w64-mingw32.static.posix | xz -T${CPUS} -9ve > ../../build/gcc10_ucrt3.txz
tar cfh - `ls -1 | grep -v x86_64-w64-mingw32.static.posix` | xz -T${CPUS} -9ve > ../../build/gcc10_ucrt3_cross.txz
cd ../..
