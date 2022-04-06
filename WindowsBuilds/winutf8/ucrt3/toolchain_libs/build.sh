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
    # !!!  temporary measure before cyclic dependencies between harfbuzz
    #      and freetype get fixed to avoid unbounded growing of package
    #      config files, eventually breaking the build
    #      (.ccache is still used)
    # !!!  mv usr_${TYPE} $USRDIR
    rm -rf usr_${TYPE}
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

  # Symlinks are dereferenced as some are full-path symlinks to
  # "x86_64-w64-mingw32.static.posix" which is in the previouls tarball.  It
  # might make sense fixing those to be relative.
  #
  # The four compilers below are excluded because these are symlinks to
  # .ccache (ccache), which is out of the tree.
  #
  # The "gcc" and "g++" (native compilers) end up executing the compilers
  # installed on the Linux system.  The "x86_64-w64-mingw32.static.posix-"
  # prefixed are meant to execute cross-compilers located in "usr/bin" in
  # the tarball via ccache.  These can be restored using "make ccache", if
  # the tarball is used to restore an MXE build tree, see also
  # https://svn.r-project.org/R-dev-web/trunk/WindowsBuilds/R-devel/howto.md
  # See also that document for how to simply restore them as symlinks without
  # using ccache.
  #
  find `ls -1 | grep -v x86_64-w64-mingw32.static.posix` -printf "%k %p\n" | \
    sort -n | sed -e 's/^[0-9]\+ //g' | \
    tar --exclude="x86_64-pc-linux-gnu/bin/gcc" \
      --exclude="x86_64-pc-linux-gnu/bin/g++" \
      --exclude="x86_64-pc-linux-gnu/bin/x86_64-w64-mingw32.static.posix-gcc" \
      --exclude="x86_64-pc-linux-gnu/bin/x86_64-w64-mingw32.static.posix-g++" \
       --create --dereference --no-recursion --files-from - --file - | \
    zstd -T0 -22 --ultra > $MXEDIR/../build/gcc10_ucrt3_${TYPE}_cross.tar.zst
  cd $MXEDIR
  ls -l ../build/gcc10_ucrt3_${TYPE}.tar.zst
  ls -l ../build/gcc10_ucrt3_${TYPE}_cross.tar.zst
  mv $USRDIR usr_${TYPE}
done

cd ..
