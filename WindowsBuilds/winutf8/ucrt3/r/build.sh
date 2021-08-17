#! /bin/bash

# Build installer for R-devel from subversion.
#
# These files must be present in the current directory:
#   gcc10_ucrt3*txz (single file, see ../toolchain_libs)
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

# to prevent a warning about not being able to set UTF-8 encoding
# otherwise that warning gets serialized into the base package
# and then when R starts, last.warning is locked
export LC_CTYPE=

# fall-back to PATH if Inno Setup is not installed where expected
MISDIR="C:/Program Files (x86)/InnoSetup"
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

# update miktex (otherwise pdflatex mail complain and building
# manuals/vignettes may fail)

mpm --update
# expect failures when not running as administrator
#   FIXME: unfortunately when the updates run as admin and non-admin get out of sync,
#          MikTeX complains; when the updates are too old, it complains, too
mpm --admin --update
mpm --update

# unpack the toolchain + libs

TCFILE=`ls -1 gcc10_ucrt3*txz | head -1`
TCTS=gcc10_ucrt3.ts

if [ -r $TCTS ] && [ $TCTS -nt $TCFILE ] ; then
  echo "Re-using extracted toolchain + libs"
else
  rm -rf x86_64-w64-mingw32.static.posix
  tar xf $TCFILE
  touch $TCTS
fi

if [ ! -x x86_64-w64-mingw32.static.posix/bin/gcc.exe ] ; then
  echo "Failed to unpack toolchain + libs." >&2
  exit 2
fi

rm -rf trunk
svn checkout https://svn.r-project.org/R/trunk

# apply patches to R

mkdir build
cd trunk
for F in ../r_*.diff ; do
  patch -p0 < $F
done

  # for reference
svn diff > ../build/ucrt3.diff
svn info --show-item revision > ../build/svn_revision
unzip ../Tcl.zip

# Not needed as we use Schannel - https://curl.se/docs/sslcerts.html
cd etc
wget https://curl.haxx.se/ca/cacert.pem
mv cacert.pem curl-ca-bundle.crt
cd ..

cd src/gnuwin32

cat <<EOF >MkRules.local
LOCAL_SOFT = $THOME/x86_64-w64-mingw32.static.posix
WIN = 64
BINPREF64 =
BINPREF =
USE_ICU = YES
ICU_LIBS = -lsicuin -lsicuuc \$(LOCAL_SOFT)/lib/sicudt.a -lstdc++
USE_LIBCURL = YES
CURL_LIBS = -lcurl -lzstd -lrtmp -lssl -lssh2 -lgcrypt -lcrypto -lgdi32 -lz -lws2_32 -lgdi32 -lcrypt32 -lidn2 -lunistring -liconv -lgpg-error -lwldap32 -lwinmm
USE_CAIRO = YES
CAIRO_LIBS = "-lcairo -lfontconfig -lfreetype -lpng -lpixman-1 -lexpat -lharfbuzz -lbz2 -lintl -lz -liconv -lgdi32 -lmsimg32"
CAIRO_CPPFLAGS = "-I\$(LOCAL_SOFT)/include/cairo"
TEXI2ANY = texi2any
TEXI2DVI = env COMSPEC= texi2dvi
MAKEINFO = texi2any
ISDIR = ${MISDIR}
EOF

# COMSPEC= for texi2dvi is a work-around for a bug in texi2dvi in Msys2,
# which uses COMSPEC to detect path separator and does that incorrectly
# when running from the Msys2 terminal

if [ $RB_DEBUG == yes ] ; then
  echo "EOPTS = -O0" >> MkRules.local
  export DEBUG=T
  export R_KEEP_PKG_SOURCES=yes
fi

export PATH=$THOME/x86_64-w64-mingw32.static.posix/bin:$THOME/trunk/Tcl/bin:$MIKDIR:$PATH
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

