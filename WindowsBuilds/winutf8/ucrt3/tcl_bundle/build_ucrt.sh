#! /bin/bash

set -e

# This builds the 64-bit-only bundle using the MXE-based UCRT toolchain (see ../toolchain_libs),
# which must be on PATH (x86_64-w64-mingw32.static.posix-gcc, x86_64-w64-mingw32.static.posix-as,
# etc)
#
# In version 8.6.10, with ASLR (binutils 2.36.1 and newer), R crashes on
# exit with Tk loaded, because of a bug in the assembly code in Tk replacing
# C exceptions (using esp instead of rsp on 64-bit Windows).  8.6.12 already
# has a fixed version. That bug is woken up by ASLR.
#
#
# clean via: rm -rf build *zip *gz Tcl 64bit
#
# See build_in_docker.sh for the currently needed dependencies on Ubuntu.

BHOME=`pwd`
BINST=$BHOME/Tcl
# see zlib1.dll below

# MXE/ucrt toolchain
TRIPLET=x86_64-w64-mingw32.static.posix
## Ubuntu system toolchain
#TRIPLET=x86_64-w64-mingw32

mkdir build

if [ ! -r tcl8.6.12-src.tar.gz ] ; then
  wget https://prdownloads.sourceforge.net/tcl/tcl8.6.12-src.tar.gz
fi
if [ ! -r tk8.6.12-src.tar.gz ] ; then
  wget https://prdownloads.sourceforge.net/tcl/tk8.6.12-src.tar.gz
fi
if [ ! -r BWidget-1.9.15.zip ] ; then
  wget https://sourceforge.net/projects/tcllib/files/BWidget/1.9.15/BWidget-1.9.15.zip
fi
if [ ! -r tktable.zip ] ; then
  wget http://teapot.activestate.com/package/name/Tktable/ver/0.0.0.2010.08.18.09.02.05/arch/source/file.zip
  mv file.zip tktable.zip
fi

mkdir -p 64bit

# build 64-bit Tcl

cd $BHOME/64bit
tar xfz $BHOME/tcl8.6.12-src.tar.gz
cd tcl8.6.12
patch -p1 < $BHOME/tcl.diff
cd win
aclocal -I . --force && autoconf --force
./configure --enable-64bit --prefix=$BINST --enable-threads --bindir=$BINST/bin --libdir=$BINST/lib --target=$TRIPLET --host=$TRIPLET 2>&1 | tee configure64.out
make -j 2>&1 | tee make64.out
make install 2>&1 | tee install64.out
  ## when using the Ubuntu system toolchain and libz-mingw-w64-dev
  ## cp /usr/x86_64-w64-mingw32/lib/zlib1.dll $BINST/bin
cp ../compat/zlib/win64/zlib1.dll $BINST/bin
cp make64.out $BHOME/build/tcl_make.out
cp install64.out $BHOME/build/tcl_install.out

# add BWidget

cd $BINST/lib
unzip $BHOME/BWidget-1.9.15.zip
mv bwidget-1.9.15 BWidget

# build 64-bit Tk

cd $BHOME/64bit
tar xfz $BHOME/tk8.6.12-src.tar.gz
cd tk8.6.12
patch -p1 < $BHOME/tk.diff
cd win

  ## -Wl,--image-base -Wl,0x18000000 used for MXE/UCRT toolchain, binutils 2.36.1 (and later)
  ##   to avoid relocation truncated to fit: R_X86_64_32S against `.text'
env "LDFLAGS=-Wl,--image-base -Wl,0x18000000" \
./configure --enable-64bit --with-tcl=$BINST/lib --prefix=$BINST --enable-threads --bindir=$BINST/bin --libdir=$BINST/lib 2>&1 --target=$TRIPLET --host=$TRIPLET | tee configure64.out
make -j 2>&1 | tee make64.out
make install 2>&1 | tee install64.out
cp make64.out $BHOME/build/tk_make.out
cp install64.out $BHOME/build/tk_install.out

# build Tktable

cd $BHOME/64bit
mkdir tktable
cd tktable
unzip $BHOME/tktable.zip
# update tcl.m4/configure to support cross-compilation
cp $BHOME/64bit/tcl8.6.12/pkgs/sqlite3.36.0/tclconfig/tcl.m4 tclconfig/tcl.m4
echo >> tclconfig/tcl.m4
aclocal -I tclconfig --force && autoconf --force
./configure --prefix=$BINST/lib --with-tcl=$BINST/lib --with-tclinclude=$BHOME/64bit/tcl8.6.12/generic --with-tk=$BINST/lib --enable-64bit --enable-threads --libdir=$BINST/lib --target=$TRIPLET --host=$TRIPLET 2>&1 | tee configure64.out
make -j 2>&1 | tee make64.out
make install 2>&1 | tee install64.out
cp make64.out $BHOME/build/tktable_make.out
cp install64.out $BHOME/build/tktable_install.out

# cleanup after 64-bit builds
#   (static libraries of tcl are needed to build tk, so could not delete them sooner)
rm `find $BINST -name "*.a"`
# delete documentation
rm -rf $BINST/share

# The bundle is in Tcl

cd $BHOME
zip -r Tcl Tcl
cp Tcl.zip build

# Sanity check

find Tcl | md5sum
du Tcl -ksk
