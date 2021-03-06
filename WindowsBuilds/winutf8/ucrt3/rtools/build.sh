#! /bin/bash

# Build rtools.
#
# These files must be present in the current directory:
#   gcc10_ucrt3_full*tar.zst (single file, see ../toolchain_libs)
#
# Outputs are left under the current directory.
#
# Inno Setup should be installed in C:/Program Files (x86)/InnoSetup
# or be on PATH.
#
# QPDF must be installed under "C:\Program Files\qpdf" and will be copied
# into the installation.
#
# Msys2 this script is running in must be updated before every execution to
# minimize the risk of incompatible cygwin runtime between the host and the
# guest Msys2 installation.

MISDIR="C:/Program Files (x86)/InnoSetup"
if [ ! -x "${MISDIR}/iscc" ] ; then
  WISCC=`which iscc`
  if [ "X${WISCC}" != X ] ; then
    MISDIR=`dirname "${WISCC}"`
  fi
fi

if [ ! -x "${MISDIR}/iscc" ] ; then
  echo "Inno Setup is not available." >&2
  exit 1
fi

QPDFDIR="/c/Program Files/qpdf"
if [ ! -x "${QPDFDIR}/bin/qpdf" ] ; then
  echo "QPDF is not available." >&2
  exit 1
fi

# get the toolchain

TCFILE=`ls -1 gcc10_ucrt3_full*tar.zst | head -1`
if [ ! -r ${TCFILE} ] ; then
  echo "Toolchain archive not found." >&2
  exit 1
fi

# create build tools

bash -x make_rtools_chroot.sh 2>&1 | tee make_rtools_chroot.out

if [ ! -x build/rtools42/usr/bin/make.exe ] ; then
  echo "Failed to create build tools." >&2
  exit 2
fi

if grep -q "incompatible versions of the cygwin" make_rtools_chroot.out ; then
  echo "Failed to create Rtools - incompatible cygwin runtime - need to update Msys2" >&2
  exit 2
fi

# extract toolchain

tar xf ${TCFILE} -C build/rtools42

if [ ! -x build/rtools42/x86_64-w64-mingw32.static.posix/bin/gcc.exe ] ; then
  echo "Failed to unpack toolchain + libs." >&2
  exit 2
fi

# install QPDF

# Msys2 doesn't have a Msys- version of QPDF.  There is a mingw64 version,
# but that comes with extra dependencies and installs into a different tree. 
# As QPDF installation is relocateable, simply copy it over. Windows does
# not support file symlinks without administrator privileges.

cp -R "${QPDFDIR}"/* build/rtools42/usr
mv build/rtools42/usr/README.txt build/rtools42/usr/doc/README-qpdf.txt

# build the rtools installer

"${MISDIR}"/iscc rtools64.iss 2>&1 | tee iscc.out

if [ ! -x Output/rtools42-x86_64.exe ] ; then
  echo "Failed to build rtools installer." >&2
  exit 2
fi
