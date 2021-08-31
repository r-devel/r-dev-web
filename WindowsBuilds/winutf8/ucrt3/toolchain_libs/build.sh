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

# This includes a lot of .exe files, including tests, which are large and
# probably not used by most users,
#
# tar cfh - x86_64-w64-mingw32.static.posix | xz -T${CPUS} -9ve > ../../build/gcc10_ucrt3.txz

find x86_64-w64-mingw32.static.posix -printf "%k %p\n" | sort -n | cut -d' ' -f2 | \
  tar --exclude="*-tests" --exclude="test*.exe"     --exclude="*gdal*.exe" \
    --exclude="*rtmp*.exe" --exclude="*gnutls*.exe" --exclude="hb-*.exe" \
    --exclude="ogr*.exe" --exclude="certtool.exe" --exclude="gnmmanage.exe" \
    --exclude="nearblack.exe" \
    --create --dereference --no-recursion --files-from - --file - | \
  zstd -T0 -22 --ultra > ../../build/gcc10_ucrt3.tar.zst

# zstd has a slightly better compression ratio on these files, but keep xz
# at least for now as not to break existing scripts

find x86_64-w64-mingw32.static.posix -printf "%k %p\n" | sort -n | cut -d' ' -f2 | \
  tar --exclude="*-tests" --exclude="test*.exe"     --exclude="*gdal*.exe" \
    --exclude="*rtmp*.exe" --exclude="*gnutls*.exe" --exclude="hb-*.exe" \
    --exclude="ogr*.exe" --exclude="certtool.exe" --exclude="gnmmanage.exe" \
    --exclude="nearblack.exe" \
    --create --dereference --no-recursion --files-from - --file - | \
  xz -T0 -9ve > ../../build/gcc10_ucrt3.txz

tar cfh - `ls -1 | grep -v x86_64-w64-mingw32.static.posix` | xz -T0 -9ve > ../../build/gcc10_ucrt3_cross.txz
cd ../..
