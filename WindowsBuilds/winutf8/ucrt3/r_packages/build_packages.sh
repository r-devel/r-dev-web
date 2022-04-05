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
# JDK must be in /c/Program\ Files/AdoptOpenJDK/jdk-11.0.11.9-hotspot or
# on PATH
#
# JAGS must be in /c/Program\ Files/JAGS/JAGS-4.3.0 or under JAGS_ROOT
#
# QPDF must be in /c/Program\ Files/qpdf/bin/qpdf or R_QPDF
#
# Pandoc must be in /c/Program\ Files/Pandoc or on PATH
#
# Python must be in /c/Program\ Files/Python310 or on PATH
#
# Ruby must be in /c/Ruby/bin or on PATH

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

JDIR=/c/Program\ Files/AdoptOpenJDK/jdk-11.0.11.9-hotspot
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

JROOT=/c/Program\ Files/JAGS/JAGS-4.3.0
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

# Python

PDIR=/c/Program\ Files/Python310
if [ ! -x "${PDIR}/python" ] ; then
  WPYTHON=`which python 2>/dev/null`
  if [ "X${WPYTHON}" != X ] ; then
    PDIR=`dirname "${WPYTHON}"`
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


# ----------- 

export PATH="`pwd`/rinst/bin/:`pwd`/rinst/Tcl/bin/:${PATH}"
export _R_INSTALL_TIME_PATCHES_=`pwd`
export R_CUSTOM_TOOLS_SOFT=`pwd`/x86_64-w64-mingw32.static.posix
  # intentionally non-existent directory as using Msys2 which is on PATH
export R_CUSTOM_TOOLS_PATH=custom_rtools
export PATH="${R_CUSTOM_TOOLS_SOFT}/bin:${PATH}"

export TAR=/usr/bin/tar
export TAR_OPTIONS=--force-local

R --vanilla < build_packages.r 2>&1 | tee build_packages.out
