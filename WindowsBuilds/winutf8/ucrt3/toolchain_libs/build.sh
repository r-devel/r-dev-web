#! /bin/bash

# Build toolchain and libraries using MXE
#
# Takes one optional argument, which is the target installation location
# during the build.  By default, it is "usr" under the mxe build directory,
# but the full path ends up hard-coded in some files (e.g. libtool), which 
# matters e.g. when compiling JAGS from source (as JAGS uses libtool). 
#
# Docker builds use /usr/lib/mxe/usr, which is the same directory as used by
# official binary MXE builds.
#
# See build_in_docker.sh for dependencies on Ubuntu 20.04 and other
# supported distributions.
#

# Adapt number of CPUs for the build below
CPUS=`cat /proc/cpuinfo | grep ^physical.*0 | wc -l`

USRDIR="$1"
if [ "X$USRDIR" == X ] ; then
  USRDIR=`pwd`/mxe/usr
fi
echo "Using prefix $USRDIR."

mkdir -p build
cd mxe
rm -rf "tmp-*"

# build base and full toolchain
#   for simplicity these are separate builds, but the ccache is shared
#   the builds are left in usr_base and usr_full, and move to usr
#     for the actual builds
for TYPE in base full ; do
  rm -rf $USRDIR
  if [ -d usr_${TYPE} ] ; then
    mv usr_${TYPE} $USRDIR
  fi
  make -j ${CPUS} R_TOOLCHAIN_TYPE=${TYPE} MXE_PREFIX=$USRDIR 2>&1 | \
    tee make_${TYPE}.out
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

  MXEDIR=`pwd`
  
    # optional file with version information provided by outer scripts
  if [ -r .version ] ; then
    cp -p .version $USRDIR/x86_64-w64-mingw32.static.posix
  fi
  cd $USRDIR
  find x86_64-w64-mingw32.static.posix -printf "%k %p\n" | sort -n | sed -e 's/^[0-9]\+ //g' | \
    tar --exclude="*-tests" --exclude="test*.exe" --exclude="*gdal*.exe" \
      --exclude="*rtmp*.exe" --exclude="*gnutls*.exe" --exclude="hb-*.exe" \
      --exclude="ogr*.exe" --exclude="certtool.exe" --exclude="gnmmanage.exe" \
      --exclude="nearblack.exe" \
      --exclude="projsync.exe" --exclude="projinfo.exe" --exclude="gie.exe" \
      --exclude="cs2cs.exe" --exclude="cct.exe" --exclude="invproj.exe" \
      --exclude="proj.exe" --exclude="geod.exe" --exclude="invgeod.exe" \
      --exclude="gnmanalyse.exe" --exclude="curl.exe" \
      --exclude="h5*.exe" --exclude="protoc.exe" \
      --exclude="ffmpeg.exe" --exclude="ffprobe.exe" --exclude="ffplay.exe" \
      --exclude="rdfproc.exe" \
      --exclude="play.exe" --exclude="rec.exe" --exclude="sox.exe" --exclude="soxi.exe" \
      --exclude="openssl.exe" \
      --create --dereference --no-recursion --files-from - --file - | \
    zstd -T0 -22 --ultra > $MXEDIR/../build/gcc10_ucrt3_${TYPE}.tar.zst

  tar cf - `ls -1 | grep -v x86_64-w64-mingw32.static.posix` | \
    zstd -T0 -22 --ultra > $MXEDIR/../build/gcc10_ucrt3_${TYPE}_cross.tar.zst
  cd $MXEDIR
  ls -l ../build/gcc10_ucrt3_${TYPE}.tar.zst
  ls -l ../build/gcc10_ucrt3_${TYPE}_cross.tar.zst
  mv $USRDIR usr_${TYPE}
done

cd ..
