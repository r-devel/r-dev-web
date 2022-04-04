#! /bin/bash

# Checks a single R package (possibly including dependencies) using R
# installed to "rinst" with installation-time patches install to
# "patches"/"patches_idx.rds", using toolchain installed to
# "x86_64-w64-mingw32.static.posix", using package library in "lib".
#
# Results appear in "pkgcheck/qresults".
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
# Ghostscript must be in /c/Program\ Files/gs/gs/bin or on PATH
# and 32-bit in /c/Program\ Files\ (x86)/gs/gs/bin or on PATH
#
# HANDLE_TOOL may be set, e.g. to
#   "/c/Program Files/sysinternals/handle64.exe"
#   it is not set automatically
#
# TLIST_TOOL must be set or tlist.exe be
#   "/c/Program Files (x86)/Windows Kits/10/Debuggers/x64/tlist.exe"
#
# PhantomJS must be in /c/Program\ Files/phantomjs/bin or on PATH
#
# Python must be in /c/Program\ Files/Python310 or on PATH
#
# FIXME: currently a lot of duplication with check_all_packages.sh


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

# Ghostscript

GDIR=/c/Program\ Files/gs/gs/bin
if [ ! -x "${GDIR}/gswin64" ] ; then
  WGS=`which gswin64 2>/dev/null`
  if [ "X${WGS}" != X ] ; then
    GDIR=`dirname "${WGS}"`
  fi
fi

if [ ! -x "${GDIR}/gswin64" ] ; then
  echo "Ghostscript is not available." >&2
  exit 1
fi

GDIR=/c/Program\ Files\ (x86)/gs/gs/bin
if [ ! -x "${GDIR}/gswin32" ] ; then
  WGS=`which gswin32 2>/dev/null`
  if [ "X${WGS}" != X ] ; then
    GDIR=`dirname "${WGS}"`
  fi
fi

if [ ! -x "${GDIR}/gswin32" ] ; then
  echo "Ghostscript (x86) is not available." >&2
  exit 1
fi


# Handle
#   (not used by default as it often gets stuck when running in docker)
#
#
# if [ "X${HANDLE_TOOL}" == X ] ; then
#   export HANDLE_TOOL="/c/Program Files/sysinternals/handle64.exe"
# fi
#
# if [ ! -x "${HANDLE_TOOL}" ] ; then
#   echo "HANDLE_TOOL (handle.exe) is not available." >&2
#   exit 1
# fi

# Tlist

if [ "X${TLIST_TOOL}" == X ] ; then
  export TLIST_TOOL="/c/Program Files (x86)/Windows Kits/10/Debuggers/x64/tlist.exe"
fi

if [ ! -x "${TLIST_TOOL}" ] ; then
  echo "TLIST_TOOL (tlist.exe) is not available." >&2
  exit 1
fi

# PhantomJS

PDIR=/c/Program\ Files/phantomjs/bin
if [ ! -x "${PDIR}/phantomjs" ] ; then
  WPHANTOMJS=`which phantomjs 2>/dev/null`
  if [ "X${WPHANTOMJS}" != X ] ; then
    PDIR=`dirname "${WPHANTOMJS}"`
  fi
fi

if [ ! -x "${PDIR}/phantomjs" ] ; then
  echo "PhantomJS is not available." >&2
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

# ----------- 

export PATH="`pwd`/rinst/bin/:`pwd`/rinst/Tcl/bin/:${PATH}"
export _R_INSTALL_TIME_PATCHES_=`pwd`
export R_CUSTOM_TOOLS_SOFT=`pwd`/x86_64-w64-mingw32.static.posix
  # intentionally non-existent directory as using Msys2 which is on PATH
export R_CUSTOM_TOOLS_PATH=custom_rtools
export PATH="${R_CUSTOM_TOOLS_SOFT}/bin:${PATH}"

export TAR=/usr/bin/tar
export TAR_OPTIONS=--force-local

if [ "X`which make 2>/dev/null`" == X ] ; then
  echo "make not found" >&2
  exit 1
fi

if [ "X`which gcc 2>/dev/null`" == X ] ; then
  echo "gcc not found" >&2
  exit 1
fi

# -----------

bash -x ./check_packages.sh $*
