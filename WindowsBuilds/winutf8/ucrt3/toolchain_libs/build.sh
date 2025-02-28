#! /bin/bash

# Build toolchain and libraries using MXE
#
# build.sh [usrdir] [target] [compression_level]
#
# The 1st (optional) argument is the target installation location during the
# build.  By default, it is "usr" under the mxe build directory, but the
# full path ends up hard-coded in some files (e.g.  libtool), which matters
# e.g.  when compiling JAGS from source (as JAGS uses libtool).
#
# Docker builds use /usr/lib/mxe/usr for x86_64 and /usr/lib/mxe/usr_aarch64
# for aarch64.  The former is the same directory as used by official binary
# MXE builds, but the aarch64 builds needs to live in a separate tree, because
# the non-target MXE subdirectories are not target-agnostic.
#
# The 2nd (optional) argument is the target, which can be x86_64 (the
# default) or aarch64.
#
# The 3rd (optional) argument is compression level for zstd compression of
# the tarballs.  The default is maximum compression (22), which however
# takes long to compress, so this can be reduced when debugging scripts,
# etc.
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

# pkg-config .pc files fixup below depends on no trailing slashes
USRDIR=`echo $USRDIR | sed -e 's!/*$!!g'`

echo "Using prefix $USRDIR."

RTARGET="$2"
if [ "X$RTARGET" == X ] ; then
  RTARGET="x86_64"
fi
echo "Building for target $RTARGET."

CLEVEL="$3"
if [ "XCLEVEL" == X ] ; then
  CLEVEL="22"
fi

if [ ${RTARGET} == "aarch64" ] ; then
  RCOMPILER="llvm19"
  MXETARGET="aarch64-w64-mingw32.static.posix"
  RSUFFIX="_aarch64"
else
  RCOMPILER="gcc14"
  MXETARGET="x86_64-w64-mingw32.static.posix"
  RSUFFIX=""
fi

mkdir -p build
cd mxe
rm -rf "tmp-*"

# build base and full toolchain
#   for simplicity these are separate builds, but the ccache is shared
#   the builds are left in usr_base and usr_full, and move to usr
#     for the actual builds
for TYPE in base full ; do
  rm -rf ${USRDIR}
  if [ -d usr_${TYPE}_${RTARGET} ] ; then
    # !!!  temporary measure before cyclic dependencies between harfbuzz
    #      and freetype get fixed to avoid unbounded growing of package
    #      config files, eventually breaking the build
    #      (.ccache is still used)
    #      FIXME: check time to time whether it is still needed
    #
    # Note: building from ccached also makes the builds more reproducible,
    # because otherwise some packages may build differently when they
    # already find some software installed (e.g.  software they failed to
    # specify as dependencies, or intended to be soft dependencies, etc).
    #      
    #     
    # !!!  mv usr_${TYPE}_${RTARGET} $USRDIR
    # 
    # if [ $RTARGET == x86_64 ] ; then
    #  rm -rf usr_${TYPE}_${RTARGET}
    # else
    #   # avoid this work-around as aarch64 is experimental, anyway
    #   # and takes forever
    #   mv usr_${TYPE}_${RTARGET} $USRDIR
    # fi
    
    rm -rf usr_${TYPE}_${RTARGET}
  fi
  
  # isolate ccaches for different targets
  if [ -d .ccache_${RTARGET} ] ; then  
    mv .ccache_${RTARGET} .ccache
  fi
  
  make -j ${CPUS} -k R_TOOLCHAIN_TYPE=${TYPE} MXE_PREFIX=${USRDIR} R_TARGET=${RTARGET} >&1 | \
    tee make_${TYPE}_${RTARGET}.out
  cp make_${TYPE}_${RTARGET}.out ../build
  
  # Fix .pc config files for easier use after relocation. Too many of the produced files
  # are specified incorrectly to make this possible.
  #
  # This requires adding prefix definition to some files as below, the awk script
  # looks for use of ${prefix} when it is not defined, the last sed script adds 
  # the prefix shen needed.
  #
  # FIXME: pkgconf should be able to do this on the fly
  # FIXME: this could be smarter to read the actual prefix from the file
  find ${USRDIR}/${MXETARGET}/lib/pkgconfig/ -name "*.pc" -type f \
    -exec sed -i '/^prefix=/! s,'${USRDIR}/${MXETARGET}',${prefix},g' {} \; \
    -exec awk 'BEGIN { def = 0; needsdef = 0 } \
            /^[^#]*prefix *=.*[a-zA-Z0-9].*/ { def=1 } \
            /.*\$\{prefix\}.*/ { if (!def) { needsdef = 1 } } \
            // { } \
            END { exit !needsdef }' {} \; \
    -exec sed -i '1i prefix='${USRDIR}/${MXETARGET}'' {} \;
  
  # produce list of packages available in MXE, each line of form "<package> <version>"
  FAVAIL=/tmp/available_pkgs.list.$$
  make R_TARGET=${RTARGET} docs/packages.json
  cat docs/packages.json | grep -v '^{$' | grep -v '^}$' | grep -v '"": null' | \
    sed -e 's/ *"\([^"]\+\)": {"version": "\([^"]*\)".*/\1 \2/g' | sort > ${FAVAIL}
  # restrict it only to packages installed
  ls -1 ${USRDIR}/${MXETARGET}/installed | \
    while read P ; do
      grep "^$P " ${FAVAIL}
    done > ${USRDIR}/${MXETARGET}/installed.list
  rm -rf ${FAVAIL}

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
    cp -p .version ${USRDIR}/${MXETARGET}
  fi
  cd $USRDIR
  find ${MXETARGET} -printf "%k %p\n" | sort -n | sed -e 's/^[0-9]\+ //g' | \
    tar --exclude="*-tests" --exclude="test*.exe" --exclude="*gdal*.exe" \
      --exclude="*rtmp*.exe" --exclude="*gnutls*.exe" --exclude="hb-*.exe" \
      --exclude="ogr*.exe" --exclude="certtool.exe" --exclude="gnmmanage.exe" \
      --exclude="nearblack.exe" \
      --exclude="projsync.exe" --exclude="projinfo.exe" --exclude="gie.exe" \
      --exclude="cs2cs.exe" --exclude="cct.exe" --exclude="invproj.exe" \
      --exclude="proj.exe" --exclude="geod.exe" --exclude="invgeod.exe" \
      --exclude="gnmanalyse.exe" --exclude="curl.exe" \
      --exclude="h5*.exe" \
      --exclude="ffmpeg.exe" --exclude="ffprobe.exe" --exclude="ffplay.exe" \
      --exclude="rdfproc.exe" \
      --exclude="play.exe" --exclude="rec.exe" --exclude="sox.exe" --exclude="soxi.exe" \
      --exclude="openssl.exe" --exclude="brotli.exe" --exclude="mirror_server.exe" \
      --exclude="mirror_server_stop.exe" --exclude="sozip.exe" \
      --create --dereference --no-recursion --files-from - --file - | \
    zstd -T0 -$CLEVEL --ultra > $MXEDIR/../build/${RCOMPILER}_ucrt3_${TYPE}${RSUFFIX}.tar.zst

  # Symlinks are dereferenced as some are full-path symlinks to
  # "x86_64-w64-mingw32.static.posix" which is in the previous tarball (full
  # or base).  It might make sense fixing those to be relative, instead, to 
  # save space.
  #
  # The four compilers below on x86_64 are excluded because these are
  # symlinks to .ccache (ccache), which is out of the tree.
  #
  # The "gcc" and "g++" (native compilers) commands end up executing the
  # compilers installed on the Linux (build) system.  The
  # "x86_64-w64-mingw32.static.posix-" prefixes are meant to execute
  # cross-compilers located in "usr/bin" in the tarball via ccache.  These
  # can be restored using "make ccache", if the tarball is used to restore
  # an MXE build tree, see also
  # https://svn.r-project.org/R-dev-web/trunk/WindowsBuilds/R-devel/howto.md
  # See also that document for how to simply restore them as symlinks
  # without using ccache.
  #
  # On aarch64 builds, this is slightly different.  "clang" is a link to
  # "clang-17", which runs on Linux (build) and could cross-compile to Windows, but
  # would have to be given a target triple argument for that.  "clang" is
  # being executed via clang-target-wrapper.sh, which itself executes ccache
  # (and which specifies the triplet and other important arguments).  So,
  # links are not used to execute clang via ccache.  The "gcc" and "g++"
  # commands still use ccache via a link and execute the native compiler on
  # the Linux (build) host, as in the case of x86_64 builds.
  #
  EXTRAEXC=""
  if [ $RTARGET == x86_64 ] ; then
    EXTRAEXC="--exclude=x86_64-pc-linux-gnu/bin/${MXETARGET}-gcc \
              --exclude=x86_64-pc-linux-gnu/bin/${MXETARGET}-g++"
  else
    # these are in the build for aarch64 by error
    EXTRAEXC="--exclude=x86_64-pc-linux-gnu/bin/x86_64-w64-mingw32.static.posix-gcc \
              --exclude=x86_64-pc-linux-gnu/bin/x86_64-w64-mingw32.static.posix-g++ \
              --exclude=bin/x86_64-w64-mingw32.static.posix-cmake \
              --exclude=bin/x86_64-w64-mingw32.static.posix-cpack \
              --exclude=bin/x86_64-w64-mingw32.static.posix-pkg-config"
  fi
  find `ls -1 | grep -v ${MXETARGET}` -printf "%k %p\n" | \
    sort -n | sed -e 's/^[0-9]\+ //g' | \
    tar --exclude="x86_64-pc-linux-gnu/bin/gcc" \
        --exclude="x86_64-pc-linux-gnu/bin/g++" \
        $EXTRAEXC \
        --create --dereference --no-recursion --files-from - --file - | \
    zstd -T0 -$CLEVEL --ultra > $MXEDIR/../build/${RCOMPILER}_ucrt3_${TYPE}_cross${RSUFFIX}.tar.zst
  cd $MXEDIR
  ls -l ../build/${RCOMPILER}_ucrt3_${TYPE}${RSUFFIX}.tar.zst
  ls -l ../build/${RCOMPILER}_ucrt3_${TYPE}_cross${RSUFFIX}.tar.zst
  mv $USRDIR usr_${TYPE}_${RTARGET}
  mv .ccache .ccache_${RTARGET}
done

cd ..
