#! /bin/bash

# Builds binary versions of R packages using R installed to "rinst" with
# installation-time patches install to "patches"/"patches_idx.rds", using
# toolchain installed to "x86_64-w64-mingw32.static.posix"
#
# the results will be under "build" and "pkgbuild" will be produced
#
# MiKTeX must be in /c/Program Files/MiKTeX/miktex/bin/x64 or in
# $LOCALAPPDATA/Programs/MiKTeX/miktex/bin/x64 or on PATH.
#
# JDK must be in /c/Program\ Files/Eclipse\ Adoptium/jdk-21.0.6.7-hotspot or
# on PATH
#
# JAGS must be in /c/Program\ Files/JAGS/JAGS-4.3.1 or under JAGS_ROOT
#
# QPDF must be in /c/Program\ Files/qpdf/bin/qpdf or R_QPDF
#
# Pandoc must be in /c/Program\ Files/Pandoc or on PATH
#
# Git must be in /c/Program\ Files/Git/bin or on PATH
#
# Python must be in /c/Program\ Files/Python312-arm64 or
#   in /c/Program\ Files/Python312 or on PATH
#
# Ruby must be in /c/Ruby/bin or on PATH
#
# Rust must be in /c/Program\ Files/Rust\ stable\ GNU\ 1.84/bin or on PATH


RTARGET=$1

if [ "X$RTARGET" == X ] ; then
  RTARGET=x86_64
fi

if [ $RTARGET == aarch64 ] ; then
  TDIR=aarch64-w64-mingw32.static.posix
else
  TDIR=x86_64-w64-mingw32.static.posix
fi

# MiKTeX 

MIKDIR="/c/Program Files/MiKTeX/miktex/bin/x64"
if [ ! -x "${MIKDIR}/pdflatex" ] ; then
  MIKDIR=`cygpath "$LOCALAPPDATA/Programs/MiKTeX/miktex/bin/x64"`
  if [ ! -x "${MIKDIR}/pdflatex" ] ; then
    WPDFLATEX=`which pdflatex 2>/dev/null`
    if [ "X${WPDFLATEX}" != X ] ; then
      MIKDIR=`dirname "${WPDFLATEX}"`
    fi
  fi
fi

if [ ! -x "${MIKDIR}/pdflatex" ] ; then
  echo "MikTeX is not available." >&2
  exit 1
fi

export PATH="${MIKDIR}:${PATH}"

# update miktex (otherwise pdflatex may complain and building
# manuals/vignettes may fail)

mpm --update-db --verbose

# Java

JDIR=/c/Program\ Files/Eclipse\ Adoptium/jdk-21.0.6.7-hotspot
if [ ! -x "${JDIR}/java" ] ; then
  WJAVA=`which java 2>/dev/null`
  if [ "X${WJAVA}" != X ] ; then
    JDIR=`dirname "${WJAVA}"`
    JDIR=`( cd "${JDIR}"/.. ; pwd )`
  fi
fi

if [ ! -x "${JDIR}/bin/java" ] ; then
  echo "Java is not available." >&2
  exit 1
fi

if [ "X${JAVA_HOME}" == X ] ; then
  export JAVA_HOME="${JDIR}"
fi

export PATH="${JDIR}/bin:${PATH}"

# JAGS

JROOT=/c/Program\ Files/JAGS/JAGS-4.3.1
if [ ! -x "${JROOT}/x64/bin/jags-terminal.exe" ] ; then
  JROOT="${JAGS_ROOT}"
fi

if [ ! -x "${JROOT}/x64/bin/jags-terminal.exe" ] ; then
  echo "JAGS is not available." >&2
  exit 1
fi

export JAGS_ROOT="${JROOT}"

# QPDF

QPDF=/c/Program\ Files/qpdf/bin/qpdf
if [ ! -x "${QPDF}" ] ; then
  QPDF="${R_QPDF}"
fi

if [ ! -x "${QPDF}" ] ; then
  echo "QPDF is not available." >&2
  exit 1
fi

export R_QPDF="${QPDF}"

# Pandoc

PDIR=/c/Program\ Files/Pandoc
if [ ! -x "${PDIR}/pandoc" ] ; then
  WPANDOC=`which pandoc 2>/dev/null`
  if [ "X${WPANDOC}" != X ] ; then
    PDIR=`dirname "${WPANDOC}"`
  fi
fi

if [ ! -x "${PDIR}/pandoc" ] ; then
  echo "Pandoc is not available." >&2
  exit 1
fi

export PATH="${PDIR}:${PATH}"

# Git

GDIR=/c/Program\ Files/Git/bin
if [ ! -x "${GDIR}/git" ] ; then
  WGIT=`which git 2>/dev/null`
  if [ "X${WGIT}" != X ] ; then
    GDIR=`dirname "${WGIT}"`
  fi
fi

if [ ! -x "${GDIR}/git" ] ; then
  echo "Git is not available." >&2
  exit 1
fi

# must be after Msys2 directories, because it includes sh.exe which
# indirectly uses (incompatible) Msys2 runtime
export PATH="${PATH}:${GDIR}"

# Python

PDIR=/c/Program\ Files/Python312-arm64
if [ ! -x "${PDIR}/python" ] ; then
  PDIR=/c/Program\ Files/Python312
  if [ ! -x "${PDIR}/python" ] ; then
    WPYTHON=`which python 2>/dev/null`
    if [ "X${WPYTHON}" != X ] ; then
      PDIR=`dirname "${WPYTHON}"`
    fi
  fi
fi

if [ ! -x "${PDIR}/python" ] ; then
  echo "Python is not available." >&2
  exit 1
fi

export PATH="${PDIR}:${PATH}"

# Ruby

RDIR=/c/Ruby/bin
if [ ! -x "${RDIR}/ruby" ] ; then
  WRUBY=`which ruby 2>/dev/null`
  if [ "X${WRUBY}" != X ] ; then
    RDIR=`dirname "${WRUBY}"`
  fi
fi

if [ ! -x "${RDIR}/ruby" ] ; then
  echo "Ruby is not available." >&2
  exit 1
fi

export PATH="${RDIR}:${PATH}"

# Rust

RUSTDIR=/c/Program\ Files/Rust\ stable\ GNU\ 1.84/bin
if [ ! -x "${RUSTDIR}/rustc" ] ; then
  WRUST=`which rust 2>/dev/null`
  if [ "X${WRUST}" != X ] ; then
    RUSTDIR=`dirname "${WRUST}"`
  fi
fi

if [ ! -x "${RUSTDIR}/rustc" ] ; then
  echo "Rust is not available." >&2
  exit 1
fi

export PATH="${RUSTDIR}:${PATH}"

# work-around against pkgbuild package which does not support installations
# of Rtools from a tarball
mkdir -p c:/rtools44/usr/bin

# ----------- 

export PATH="`pwd`/rinst/bin/:`pwd`/rinst/Tcl/bin/:${PATH}"
export _R_INSTALL_TIME_PATCHES_=`pwd`
export R_CUSTOM_TOOLS_SOFT=`pwd`/$TDIR
  # intentionally non-existent directory as using Msys2 which is on PATH
export R_CUSTOM_TOOLS_PATH=custom_rtools
export PATH="${R_CUSTOM_TOOLS_SOFT}/bin:${PATH}"

export TAR=/usr/bin/tar
export TAR_OPTIONS=--force-local

export R_TIMEOUT=/usr/bin/timeout

R --vanilla < build_packages.r 2>&1 | tee build_packages.out
