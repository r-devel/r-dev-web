#! /bin/bash

# Checks R packages using R installed to "rinst" with installation-time
# patches install to "patches"/"patches_idx.rds", using toolchain installed
# to "x86_64-w64-mingw32.static.posix", using repository of binary packages
# in "build". This script also installs the packages, first.
#
# "pkgcheck" will be produced and the results will be under "pkgcheck/results".
#
# MiKTeX must be in /c/Program Files/MiKTeX/miktex/bin/x64 or in
# $LOCALAPPDATA/Programs/MiKTeX/miktex/bin/x64 or on PATH.
#
# JDK must be in /c/Program\ Files/Eclipse\ Adoptium/jdk-17.0.5.8-hotspot or
# on PATH
#
# JAGS must be in /c/Program\ Files/JAGS/JAGS-4.3.1 or under JAGS_ROOT
#
# QPDF must be in /c/Program\ Files/qpdf/bin/qpdf or R_QPDF
#
# Pandoc must be in /c/Program\ Files/Pandoc or on PATH
#
# Ghostscript must be in /c/Program\ Files/gs/gs/bin or on PATH
# and 32-bit in /c/Program\ Files\ \(x86\)/gs/gs/bin or on PATH
#
# Git must be in /c/Program\ Files/Git/bin or on PATH
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
# Python must be in /c/Program\ Files/Python311 or on PATH
#
# Ruby must be in /c/Ruby/bin or on PATH
#
# Rust must be in /c/Program\ Files/Rust\ stable\ GNU\ 1.76/bin or on PATH


# FIXME: currently a lot of duplication with build_packages.sh

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

JDIR=/c/Program\ Files/Eclipse\ Adoptium/jdk-17.0.5.8-hotspot
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

export PATH="${GDIR}:${PATH}"
export GS_CMD=="`which gswin64c.exe`"

GDIR=/c/Program\ Files\ \(x86\)/gs/gs/bin
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

export PATH="${GDIR}:${PATH}"

# R_GSCMD is used by at least grImport
#
#  grImport can work without it when gswin64c.exe is on PATH, though

WG64C=`which gswin64c 2>/dev/null` 2>/dev/null
WG32C=`which gswin32c 2>/dev/null` 2>/dev/null
if [ "X${WG64C}" != X ] ; then
  export R_GSCMD="${WG64C}"
elif [ "X${WG32C}" != X ] ; then
  export R_GSCMD="${WG32C}"
else
  echo "gswin??c.exe is not available." >&2
  exit 1
fi


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

PDIR=/c/Program\ Files/Python311
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

# Rust

RUSTDIR=/c/Program\ Files/Rust\ stable\ GNU\ 1.76/bin
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


# ----------- 

export PATH="`pwd`/rinst/bin/:`pwd`/rinst/Tcl/bin/:${PATH}"
export _R_INSTALL_TIME_PATCHES_=`pwd`
export R_CUSTOM_TOOLS_SOFT=`pwd`/x86_64-w64-mingw32.static.posix
  # intentionally non-existent directory as using Msys2 which is on PATH
export R_CUSTOM_TOOLS_PATH=custom_rtools
export PATH="${R_CUSTOM_TOOLS_SOFT}/bin:${PATH}"

export TAR=/usr/bin/tar
export TAR_OPTIONS=--force-local

export R_TIMEOUT=/usr/bin/timeout

if [ "X`which make 2>/dev/null`" == X ] ; then
  echo "make not found" >&2
  exit 1
fi

if [ "X`which gcc 2>/dev/null`" == X ] ; then
  echo "gcc not found" >&2
  exit 1
fi

# work-around against pkgbuild package which does not support installations
# of Rtools from a tarball
mkdir -p c:/rtools43/usr/bin

# -----------

echo "=== Environment used for checking: " >&2
set >&2

echo "=== GCC Version: " >&2
gcc -v >&2

echo "=== Makeconf: " >&2
cat rinst/etc/x64/Makeconf >&2

echo " === R svn version: " >&2
Rscript -e "R.version\$svn" >&2

# install packages (re-uses some binary packages)

echo "`date`: Installing packages for checking" >&2
R --vanilla < install_packages_for_checking.r 2>&1 | \
  tee install_packages_for_checking.out
echo "`date`: Done installing packages for checking" >&2

# check packages (in parallel) and generate reports

bash -x ./check_packages.sh 2>&1 | tee check_packages.out
