#! /bin/bash

# Build toolchain and libraries using MXE
#
# See build_in_docker.sh for dependencies on Ubuntu 20.04
#

# Adapt number of CPUs for the build below
CPUS=`cat /proc/cpuinfo | grep ^physical.*0 | wc -l`

mkdir build
cd mxe
rm -rf "tmp-*"

# build base and full toolchain
#   for simplicity these are separate builds, but the ccache is shared
#   the builds are left in usr_base and usr_full, and move to usr
#     for the actual builds
for TYPE in base full ; do
  rm -rf usr
  if [ -d usr_${TYPE} ] ; then
    mv usr_${TYPE} usr
  fi
  make -j ${CPUS} R_TOOLCHAIN_TYPE=${TYPE} 2>&1 | tee make_${TYPE}.out
  cp make_${TYPE}.out ../build
  
  # zstd has a slightly better compression ratio than xz on these files and
  # the decompression is about 5x faster, so switching to it.
  #
  # with both zstd and xz it significantly helps to archive files in the order
  # of file size, so that duplicated executables and executables linked to the
  # same libraries are more likely close in the archive
  #
  # excluding executables, particularly tests, which are not needed by most users,
  # but they take a lot of space because of static linking

  cd usr
  find x86_64-w64-mingw32.static.posix -printf "%k %p\n" | sort -n | cut -d' ' -f2 | \
    tar --exclude="*-tests" --exclude="test*.exe" --exclude="*gdal*.exe" \
      --exclude="*rtmp*.exe" --exclude="*gnutls*.exe" --exclude="hb-*.exe" \
      --exclude="ogr*.exe" --exclude="certtool.exe" --exclude="gnmmanage.exe" \
      --exclude="nearblack.exe" \
      --create --dereference --no-recursion --files-from - --file - | \
    zstd -T0 -22 --ultra > ../../build/gcc10_ucrt3_${TYPE}.tar.zst

  tar cfh - `ls -1 | grep -v x86_64-w64-mingw32.static.posix` | \
    zstd -T0 -22 --ultra > ../../build/gcc10_ucrt3_${TYPE}_cross.tar.zst
  cd ..
  mv usr usr_${TYPE}
done

cd ..
