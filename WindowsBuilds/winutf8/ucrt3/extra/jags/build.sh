#! /bin/bash

#
# This script builds JAGS 4.3.0 for UCRT, only a 64-bit version, natively on
# Windows.  Tested with source tarball JAGS-4.3.0.tar.gz (md5sum
# d88dff326603deee39ce7fa4234c5a43), it must be available in the current
# directory.
#
# See JAGS installation manual for more details.  This requires the ucrt3
# toolchain, NSIS to build the installer (makensis must be on PATH),
# AccessControl plugin for NSIS (following the installation is manual,
# copying into the NSIS installation tree, and reorganizing slightly).
#
# When I did it on 2021-02-24, with the latest NSIS and AccessControl
# plugin, I had to copy Unicode\Plugins to Plugins\x86-unicode and Plugins
# go to Plugins\x86-ansi.  When I did it on 2022-03-22, again with the
# latest NSIS and AccessControl plugin, I copied the content of i386-ansi
# into x86-ansi and i386-unicode into x86-unicode.
#
# This includes a patch for the installer so that a 64-bit-only version can
# be built, plus additional fixes in the installer.  It uses reference BLAS
# and LAPACK from the toolchain. See toolchain Howto for more (../../howto.md).
#

TLIB=`which gcc | sed -e 's!bin/gcc$!!g'`"lib"
if [ ! -r "$TLIB/libblas.a" ] || [ ! -r "$TLIB/liblapack.a" ] ; then
  echo "This needs to be run with UCRT toolchain on PATH. The toolchain must include BLAS and LAPACK" >&2
  exit 1
fi

JAGSVER=JAGS-4.3.0
if [ ! -r $JAGSVER.tar.gz ] ; then
  echo "$JAGSVER.tar.gz must be available in the current directory." >&2
  exit 1
fi

if ! which makensis 2>/dev/null ; then
  echo "makensis (NSIS) must be on PATH." >&2
  exit 1
fi

# build shared version of BLAS and LAPACK

mkdir sharedlb
cd sharedlb
dlltool -z libblas.def --export-all-symbols $TLIB/libblas.a
gfortran -shared -o libblas.dll -Wl,--out-implib=libblas.dll.a libblas.def $TLIB/libblas.a
dlltool -z liblapack.def --export-all-symbols $TLIB/liblapack.a
gfortran -shared -o liblapack.dll -Wl,--out-implib=liblapack.dll.a liblapack.def $TLIB/liblapack.a  -L. -lblas
SHAREDLB=`pwd`
cd ..

# build JAGS

tar xfz $JAGSVER.tar.gz
cd $JAGSVER
patch -p2 --binary < ../jags_64bit_only.diff # update installer
./configure --host=x86_64-w64-mingw32.static.posix --with-blas="-L$SHAREDLB -lblas" --with-lapack="-L$SHAREDLB -llapack"
make win64-install
cp $SHAREDLB/libblas.dll $SHAREDLB/liblapack.dll win/inst64/bin
make installer
cd ..
