#! /bin/bash

# Build installer for R-devel/-patched from subversion.
#
# These files must be present in the current directory:
#
#   for target x86_64:   
#     gcc13_ucrt3_full*tar.zst (single file, see ../toolchain_libs)
#     Tcl*.zip (single file, see ../tcl_bundle)
#
#   for target aarch64:
#     llvm17_ucrt3_full_aarch64*tar.zst
#     Tcl-aarch64*zip
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
RTARGET="x86_64"

while [ $# -gt 0 ] ; do
  if [ "X$1" == "X--debug" ] ; then
    RB_DEBUG="yes"
  elif [ "X$1" == "X--check" ] ; then
    RB_CHECK="yes"
  elif [ "X$1" == "X--patched" ] ; then
    RB_PATCHED="yes"
  elif [ "X$1" == "Xx86_64" ] ; then
    RTARGET="x86_64"
  elif [ "X$1" == "Xaarch64" ] ; then
    RTARGET="aarch64"
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

if [ ${RTARGET} == aarch64 ] ; then
  TRIPLET=aarch64-w64-mingw32.static.posix
  TCFILE=`ls -1 llvm17_ucrt3_full_aarch64*tar.zst | head -1`
  TCLFILE=`ls -1 Tcl-aarch64*zip | head -1`
  TCTS=llvm17_ucrt3.ts 
else
  TRIPLET=x86_64-w64-mingw32.static.posix
  TCFILE=`ls -1 gcc13_ucrt3_full*tar.zst | head -1`
  TCLFILE=`ls -1 Tcl*zip | grep -v aarch64 | head -1`
  TCTS=gcc13_ucrt3.ts
fi
  

if [ -r $TCTS ] && [ $TCTS -nt $TCFILE ] ; then
  echo "Re-using extracted toolchain + libs"
else
  rm -rf $TRIPLET
  tar xf $TCFILE
  touch $TCTS
fi

if [ ! -x $TRIPLET/bin/gcc.exe ] ; then
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

if [ $RTARGET == "aarch64" ] ; then
  # architecture-specific patches
  #   they override non-specific patches
  for F in ../r_*.diff_aarch64 ; do
    if [ ! -r $F ] ; then
      continue
    fi
    NF=`echo $F | sed -e 's/\.diff_aarch64$/.diff/g'`
    if [ -r $NF ] ; then
      patch --binary -R -p0 < $NF
    fi
    patch --binary -p0 < $F
  done
fi

# for reference
svn diff > ../build/ucrt3.diff
svn info --show-item revision > ../build/svn_revision
unzip ../$TCLFILE

# Not needed as we use Schannel - https://curl.se/docs/sslcerts.html
cd etc
wget https://curl.haxx.se/ca/cacert.pem
mv cacert.pem curl-ca-bundle.crt
cd ..

cd src/gnuwin32

if [ $RTARGET == "aarch64" ] ; then
  cat <<EOF >MkRules.local
USE_LLVM = 1
WIN =
EOF
fi

cat <<EOF >>MkRules.local
ISDIR = ${MISDIR}
EOF

if [ "X${QPDFDIR}" != X ] ; then
  export R_QPDF="${QPDFDIR}/bin/qpdf"
  cat <<EOF >> MkRules.local
QPDF = ${QPDFDIR}
EOF
fi

# COMSPEC= for texi2dvi was a work-around for a bug in texi2dvi in Msys2,
# which uses COMSPEC to detect path separator and does that incorrectly
# when running from the Msys2 terminal (no longer needed with recent texi2dvi)

if [ $RB_DEBUG == yes ] ; then
  if [ $RTARGET == aarch64 ] ; then
    echo "G_FLAG = -g3 -O0" >> MkRules.local
  else
    echo "G_FLAG = -gdwarf-2 -O0" >> MkRules.local
  fi
  export DEBUG=T
  export R_KEEP_PKG_SOURCES=yes
fi

GDIR=/c/Program\ Files/gs/gs/bin
if [ ! -x "${GDIR}/gswin64" ] ; then
  WGS=`which gswin64 2>/dev/null`
  if [ "X${WGS}" != X ] ; then
    GDIR=`dirname "${WGS}"`
  fi
fi

export PATH="${THOME}/${TRIPLET}/bin:${THOME}/${DIRNAME}/Tcl/bin:${MIKDIR}:${GDIR}:${PATH}"
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
