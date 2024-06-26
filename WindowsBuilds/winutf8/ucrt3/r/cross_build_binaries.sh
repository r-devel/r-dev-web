#! /bin/bash

set -e

# cross_build_binaries.sh
#
# This cross-compiles the native code in R, based and recommended packages
# and produces a tarball, which can be used on a Windows host to build and R
# installer.
#
# The anticipated use is: run this on Linux/x86_64 machine to build binaries
# for Windows/aarch64, then finish building the installer on Windows/x86_64
# machine.  The installer is a Windows/x86_64 application but installs code
# built for Windows/aarch64.
#
# The MXE-based 64-bit UCRT cross-toolchain must be in /usr/lib/mxe/usr_aarch64.
#
# The Tcl/Tk bundle must be present in the current directory (See ../tcl_bundle).
#
# This will produce a tarball in the current directory. It will include also the Tcl/Tk
# bundle.

TRIPLET=aarch64-w64-mingw32.static.posix
TCLFILE=`ls -1 Tcl-aarch64*zip | head -1`
TLDIR=/usr/lib/mxe/usr_aarch64

CLEVEL=22 # though overkill
EXTLIBS=$TLDIR/$TRIPLET

if [ X"$TCLFILE" == X ] || [ ! -r $TCLFILE ] ; then
  echo "Tcl/tk bundle file not found." >&2
  exit 1
fi

if [ ! -d $EXTLIBS/lib ] || [ ! -x $TLDIR/bin/$TRIPLET-clang ] ; then
  echo "Cross-toolchain not found." >&2
  exit 1
fi

rm -rf cross
mkdir cross
cd cross

# ---  build Linux (build) version

svn checkout https://svn.r-project.org/R/trunk
cd trunk
./tools/rsync-recommended

# apply patches
for F in ../../r_*.diff ; do
  echo "Applying patch $F"
  patch --binary -p0 < $F
done

# architecture-specific patches
#   they override non-specific patches
for F in ../../r_*.diff_aarch64 ; do
  if [ ! -r $F ] ; then
    continue
  fi
  NF=`echo $F | sed -e 's/\.diff_aarch64$/.diff/g'`
  if [ -r $NF ] ; then
    echo "Applying patch $NF"
    patch --binary -R -p0 < $NF
  fi
  echo "Applying patch $F"
  patch --binary -p0 < $F
done
cd ..

mkdir build
cd build
../trunk/configure  2>&1 | tee configure.out
make -j
cd ..

# --- build Windows binaries (R, base packages)

cd trunk
unzip ../../$TCLFILE

cd src/gnuwin32
cat > MkRules.local <<EOF
USE_LLVM = 1
WIN =
BINPREF64 = aarch64-w64-mingw32.static.posix-
EXT_LIBS = $EXTLIBS
EOF

env PATH=$TLDIR/bin:$PATH make MkRules
env PATH=$TLDIR/bin:$PATH make -j rbuild
env PATH=$TLDIR/bin:$PATH make -j rpackages-cross
env PATH=$TLDIR/bin:$PATH make -j cairodevices
cd ../..
cd ../

# --- build Windows binaries for recommended packages

# mkdir -p build/etc/
echo "R_XTRA_CPPFLAGS = -I`pwd`/trunk/include -DNDEBUG" > build/etc/Makeconf
cat trunk/etc/Makeconf >> build/etc/Makeconf

# mkdir -p build/bin
cp -p trunk/bin/*.dll build/bin

PKGS1="lattice Matrix nlme MASS survival"
PKGS2="boot class cluster codetools foreign KernSmooth mgcv nnet rpart spatial"

for P in $PKGS1 $PKGS2 ; do
  env PATH=$TLDIR/bin:$PATH R_CROSS_BUILD=singlearch R_LIBS=`pwd`/trunk/library \
      ./build/bin/R CMD INSTALL --libs-only ./trunk/src/library/Recommended/${P}.tgz
done

# --- pack the results

tar cf - trunk/bin trunk/modules trunk/library trunk/Tcl trunk/etc/Makeconf | \
  zstd -T0 -$CLEVEL --ultra > r_binaries.tar.zst

