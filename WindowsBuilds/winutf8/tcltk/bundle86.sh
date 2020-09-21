#! /bin/bash

set -e

# Ubuntu 20.04  (unbuntu:20.04)
#
#   apt-get update
#   apt-get install -y mingw-w64 wget make findutils automake tcl patch zip tzdata libz-mingw-w64-dev
#   echo "Europe/Prague" > /etc/timezone
#   dpkg-reconfigure -f noninteractive tzdata

BHOME=`pwd`
BINST=$BHOME/Tcl

wget https://prdownloads.sourceforge.net/tcl/tcl8.6.10-src.tar.gz
wget https://prdownloads.sourceforge.net/tcl/tk8.6.10-src.tar.gz
wget https://sourceforge.net/projects/tcllib/files/BWidget/1.9.14/bwidget-1.9.14.tar.gz
wget http://teapot.activestate.com/package/name/Tktable/ver/0.0.0.2010.08.18.09.02.05/arch/source/file.zip
mv file.zip tktable.zip

mkdir -p 64bit

# build 64-bit Tcl

cd $BHOME/64bit
tar xfz $BHOME/tcl8.6.10-src.tar.gz
cd tcl8.6.10
patch -p1 < $BHOME/tcl.patch
cd win
aclocal -I . --force && autoconf --force
./configure --enable-64bit --prefix=$BINST --enable-threads --bindir=$BINST/bin64 --libdir=$BINST/lib64 --target=x86_64-w64-mingw32 --host=x86_64-w64-mingw32 2>&1 | tee configure64.out
make -j 2>&1 | tee make64.out
make install 2>&1 | tee install64.out
cp /usr/x86_64-w64-mingw32/lib/zlib1.dll $BINST/bin64

# do not add BWidget, it does not have any binary files, so will be available
# from the 32-bit part

# NOTE: some files are put also to "lib"

# build 64-bit Tk

cd $BHOME/64bit
tar xfz $BHOME/tk8.6.10-src.tar.gz
cd tk8.6.10/win
./configure --enable-64bit --with-tcl=$BINST/lib64 --prefix=$BINST --enable-threads --bindir=$BINST/bin64 --libdir=$BINST/lib64 2>&1 --target=x86_64-w64-mingw32 --host=x86_64-w64-mingw32 | tee configure64.out
make -j 2>&1 | tee make64.out
make install 2>&1 | tee install64.out

# build Tktable

cd $BHOME/64bit
mkdir tktable
cd tktable
unzip $BHOME/tktable.zip
# update tcl.m4/configure to support cross-compilation
cp $BHOME/64bit/tcl8.6.10/pkgs/sqlite3.30.1.2/tclconfig/tcl.m4 tclconfig/tcl.m4
aclocal -I tclconfig --force && autoconf --force
./configure --prefix=$BINST/lib64 --with-tcl=$BINST/lib64 --with-tk=$BINST/lib64 --enable-64bit --enable-threads --libdir=$BINST/lib64 --target=x86_64-w64-mingw32 --host=x86_64-w64-mingw32 2>&1 | tee configure64.out
make -j 2>&1 | tee make64.out
make install 2>&1 | tee install64.out

# cleanup after 64-bit 4builds
#   (static libraries of tcl are needed to build tk, so could not delete them sooner)
rm `find $BINST -name "*.a"`
# delete documentation
rm -rf $BINST/share

# ---------------------------------------------------------------------------------

# build 32-bit Tcl

cd $BHOME
mkdir -p 32bit

# build 32-bit Tcl

cd $BHOME/32bit
tar xfz $BHOME/tcl8.6.10-src.tar.gz
cd tcl8.6.10
patch -p1 < $BHOME/tcl.patch
cd win
aclocal -I . --force && autoconf --force
./configure --disable-64bit --prefix=$BINST --enable-threads --bindir=$BINST/bin --libdir=$BINST/lib --target=i686-w64-mingw32 --host=i686-w64-mingw32 2>&1 | tee configure32.out
make -j 2>&1 | tee make32.out
make install 2>&1 | tee install32.out
cp /usr/i686-w64-mingw32/lib/zlib1.dll $BINST/bin

# add BWidget

cd $BINST/lib
tar xfz $BHOME/bwidget-1.9.14.tar.gz
mv bwidget-1.9.14 BWidget

# build 32-bit Tk

cd $BHOME/32bit
tar xfz $BHOME/tk8.6.10-src.tar.gz
cd tk8.6.10/win
./configure --disable-64bit --with-tcl=$BINST/lib --prefix=$BINST --enable-threads --bindir=$BINST/bin --libdir=$BINST/lib 2>&1 --target=i686-w64-mingw32 --host=i686-w64-mingw32 | tee configure32.out
make -j 2>&1 | tee make32.out
make install 2>&1 | tee install32.out

# build Tktable

cd $BHOME/32bit
mkdir tktable
cd tktable
unzip $BHOME/tktable.zip
# update tcl.m4/configure to support cross-compilation
cp $BHOME/32bit/tcl8.6.10/pkgs/sqlite3.30.1.2/tclconfig/tcl.m4 tclconfig/tcl.m4
aclocal -I tclconfig --force && autoconf --force
./configure --prefix=$BINST/lib --with-tcl=$BINST/lib --with-tk=$BINST/lib --disable-64bit --enable-threads --libdir=$BINST/lib --target=i686-w64-mingw32 --host=i686-w64-mingw32 2>&1 | tee configure32.out
make -j 2>&1 | tee make32.out
make install 2>&1 | tee install32.out

# cleanup after 32-bit 4builds
#   static libraries of tcl are needed to build tk
rm `find $BINST -name "*.a"`
rm -rf $BINST/share

# The bundle is in Tcl

cd $BHOME
zip -r Tcl Tcl

# Sanity check

find Tcl | md5sum
# 2f7e13623b90aef066f1d42f437eaf53
du Tcl -ksk
# 30448
