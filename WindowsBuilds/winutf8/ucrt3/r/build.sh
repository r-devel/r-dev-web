#! /bin/bash

# Build installer for R-devel/-patched from subversion.
#
# These files must be present in the current directory:
#   gcc12_ucrt3_full*tar.zst (single file, see ../toolchain_libs)
#   Tcl*.zip (single file, see ../tcl_bundle)
#
# Supported arguments are:
#   --debug .. create a debug build instead of the standard one
#   --check .. run checks
#   --patched  build the R-patched branched instead of R-devel
#
# Outputs are left in the current directory at the usual places,
# as shown below. There is no error diagnostics, the outputs have to
# be checked as well as the resulting installer, if present.
#
# The builds are named R-devel-win.exe or R-patched-win.exe regardless of
# the R VERSION (so also around release time).
#
# Inno Setup should be installed in C:/Program Files (x86)/InnoSetup
# or be on PATH.
#
# MiKTeX should be installed in C:/Program Files/MiKTeX or
# in $LOCALAPPDATA/Programs/MiKTeX or be on PATH.
#
# QPDF is optional, to be used, it should be installed in C:/Program Files/qpdf
# or be on PATH or in R_QPDF (but always under "bin" and named "qpdf") 
#

set -x

RB_DEBUG=no
RB_CHECK=no
RB_PATCHED=no

while [ $# -gt 0 ] ; do
  if [ "X$1" == "X--debug" ] ; then
    RB_DEBUG="yes"
  elif [ "X$1" == "X--check" ] ; then
    RB_CHECK="yes"
  elif [ "X$1" == "X--patched" ] ; then
    RB_PATCHED="yes"
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
#
# (not needed as long as running on systems supporting UTF-8)
#
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
  MIKDIR=`cygpath "$LOCALAPPDATA/Programs/MiKTeX/miktex/bin/x64"`
  if [ ! -x "${MIKDIR}/pdflatex" ] ; then
    WPDFLATEX=`which pdflatex`
    if [ "X${WPDFLATEX}" != X ] ; then
      MIKDIR=`dirname "${WPDFLATEX}"`
    fi
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

QPDFDIR="/c/Program Files/qpdf"
if [ ! -x "${QPDFDIR}/bin/qpdf" ] ; then
  QPDFDIR=`which qpdf | sed -e 's!/bin/qpdf!!g'`
  if [ ! -x "${QPDFDIR}/bin/qpdf" ] ; then
    QPDFDIR=`echo ${R_QPDF} | sed -e 's!/bin/qpdf!!g'`
    if [ ! -x "${QPDFDIR}/bin/qpdf" ] ; then
      QPDFDIR=
    fi
  fi
fi

# update miktex (otherwise pdflatex mail complain and building
# manuals/vignettes may fail)

"${MIKDIR}/mpm" --update-db --verbose

## now disabled to avoid upgrading to faulty 21.8
## mpm --update

# expect failures when not running as administrator
#   FIXME: unfortunately when the updates run as admin and non-admin get out of sync,
#          MikTeX complains; when the updates are too old, it complains, too
## "${MIKDIR}/mpm" --admin --update
## "${MIKDIR}/mpm" --update

# unpack the toolchain + libs

TCFILE=`ls -1 gcc12_ucrt3_full*tar.zst | head -1`
TCTS=gcc12_ucrt3.ts

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

if [ $RB_PATCHED == no ] ; then
  rm -rf trunk
  svn checkout https://svn.r-project.org/R/trunk
  DIRNAME=trunk
else
  rm -rf patched
  BNAME=`svn ls https://svn.r-project.org/R/branches | grep R-.-.-branch | tail -1 | tr -d /`
  svn checkout https://svn.r-project.org/R/branches/${BNAME} patched
  DIRNAME=patched
fi

# apply patches to R

mkdir build
cd $DIRNAME
for F in ../r_*.diff ; do
  patch --binary -p0 < $F
done

  # for reference
svn diff > ../build/ucrt3.diff
svn info --show-item revision > ../build/svn_revision
unzip ../Tcl*.zip

# Not needed as we use Schannel - https://curl.se/docs/sslcerts.html
cd etc
wget https://curl.haxx.se/ca/cacert.pem
mv cacert.pem curl-ca-bundle.crt
cd ..

cd src/gnuwin32

cat <<EOF >MkRules.local
ISDIR = ${MISDIR}
EOF

if [ "X${QPDFDIR}" != X ] ; then
  export R_QPDF="${QPDFDIR}/bin/qpdf"
  cat <<EOF >> MkRules.local
QPDF = ${QPDFDIR}
EOF

fi

# COMSPEC= for texi2dvi is a work-around for a bug in texi2dvi in Msys2,
# which uses COMSPEC to detect path separator and does that incorrectly
# when running from the Msys2 terminal

if [ $RB_DEBUG == yes ] ; then
  echo "G_FLAG = -gdwarf-2 -O0" >> MkRules.local
  export DEBUG=T
  export R_KEEP_PKG_SOURCES=yes
fi

export PATH="${THOME}/x86_64-w64-mingw32.static.posix/bin:${THOME}/${DIRNAME}/Tcl/bin:${MIKDIR}:${PATH}"
export TAR_OPTIONS="--force-local"

make rsync-recommended
make -j all 2>&1 | tee make_all.out
make -j recommended 2>&1 | tee make_recommended.out
make distribution 2>&1 | tee make_distribution.out

cp make_all.out make_recommended.out make_distribution.out ../../../build

if [ $RB_PATCHED == no ] ; then
  cp installer/R*.exe ../../../build/R-devel-win.exe
else
  cp installer/R*.exe ../../../build/R-patched-win.exe
fi

if [ $RB_CHECK == yes ] ; then
  make check-devel 2>&1 | tee checkdevel.out
  make check-all 2>&1 | tee checkall.out
  cp checkdevel.out checkall.out ../../../build
fi
