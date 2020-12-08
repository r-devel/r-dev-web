#! /bin/bash

# Build installer for R-devel from subversion.
#
# These files must be present in the current directory:
#   gcc10_ucrt3.txz (see ../toolchain_libs)
#   Tcl.zip (see ../tcl_bundle)
#
# Supported arguments are:
#   --debug .. create a debug build instead of the standard one
#   --check .. run checks
#
# Outputs are left in the current directory at the usual places,
# as shown below. There is no error diagnostics, the outputs have to
# be checked as well as the resulting installer, if present.
#
# Inno Setup should be installed in C:/Program Files (x86)/InnoSetup
# or be on PATH.
#
# MikTex should be installed in C:/Program Files/MiKTeX or be on PATH.
#

set -x

RB_DEBUG=no
RB_CHECK=no

while [ $# -gt 0 ] ; do
  if [ "X$1" == "X--debug" ] ; then
    RB_DEBUG="yes"
  elif [ "X$1" == "X--check" ] ; then
    RB_CHECK="yes"
  else
    echo "Invalid argument \"$1\" ignored."
  fi
  shift
done 

export THOME=`pwd`
  # /c/...

if [ ! -d x86_64-w64-mingw32.static.posix ] || \
   [ gcc10_ucrt3.txz -nt x86_64-w64-mingw32.static.posix ] ; then

  rm -rf x86_64-w64-mingw32.static.posix
  tar xf gcc10_ucrt3.txz
  # x86_64-w64-mingw32.static.posix
fi

svn checkout https://svn.r-project.org/R/trunk

mkdir build
cd trunk
for F in ../r_*.diff ; do
  patch -p0 < $F
done
unzip ../Tcl.zip

cd src/gnuwin32

# fall-back to PATH if Inno Setup is not installed where expected
MISDIR="C:/Program Files/InnoSetup"
if [ ! -x "${MISDIR}/iscc" ] ; then
  WISCC=`which iscc`
  if [ "X${WISCC}" != X ] ; then
    MISDIR=`dirname "${WISCC}"`
  fi
fi

MIKDIR="/c/Program Files/MiKTeX/miktex/bin/x64"
if [ ! -x "${MIKDIR}/pdflatex" ] ; then
  WPDFLATEX=`which pdflatex`
  if [ "X${WPDFLATEX}" != X ] ; then
    MIKDIR=`dirname "${WPDFLATEX}"`
  fi
fi

if [ ! -x "${MISDIR}/iscc" ] ; then
  echo "Inno Setup is not available." >&2
  exit 1
fi

if [ ! -x "${MIKDIR}/pdflatex" ] ; then
  echo "MikTeX is not available." >&2
  exit 1
fi

cat <<EOF >MkRules.local
LOCAL_SOFT = $THOME/x86_64-w64-mingw32.static.posix
WIN = 64
BINPREF64 =
BINPREF =
USE_ICU = YES
ICU_LIBS = -lsicuin -lsicuuc \$(LOCAL_SOFT)/lib/sicudt.a -lstdc++
USE_LIBCURL = YES
CURL_LIBS = -lcurl -lrtmp -lssl -lssh2 -lgcrypt -lcrypto -lgdi32 -lz -lws2_32 -lgdi32 -lcrypt32 -lidn2 -lunistring -liconv -lgpg-error -lwldap32 -lwinmm
USE_CAIRO = YES
CAIRO_LIBS = "-lcairo -lfontconfig -lfreetype -lpng -lpixman-1 -lexpat -lharfbuzz -lbz2 -lintl -lz -liconv -lgdi32 -lmsimg32"
CAIRO_CPPFLAGS = "-I\$(LOCAL_SOFT)/include/cairo"
TEXI2ANY = texi2any
MAKEINFO = texi2any
ISDIR = ${MISDIR}
EOF

if [ $RB_DEBUG == yes ] ; then
  echo "EOPTS = -O0" >> MkRules.local
  export DEBUG=T
  export R_KEEP_PKG_SOURCES=yes
fi

export PATH=$THOME/x86_64-w64-mingw32.static.posix/bin:$THOME/x86_64-w64-mingw32.static.posix/libexec/gcc/x86_64-w64-mingw32.static.posix/10.2.0:$THOME/trunk/Tcl/bin:$MIKDIR:$PATH
export TAR="/usr/bin/tar --force-local"

make rsync-recommended
make all 2>&1 | tee make_all.out
make recommended 2>&1 | tee make_recommended.out
make distribution 2>&1 | tee make_distribution.out

cp make_all.out make_recommended.out make_distribution.out installer/R-devel-win.exe ../../../build

if [ $RB_CHECK == yes ] ; then
  make check-devel 2>&1 | tee checkdevel.out
  make check-all 2>&1 | tee checkall.out
  cp checkdevel.out checkall.out ../../../build
fi
