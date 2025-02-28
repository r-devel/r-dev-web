#! /bin/bash

# Build rtools.
#
# These files must be present in the current directory:
#
#   for target x86_64:
#     gcc14_ucrt3_full*tar.zst (single file, see ../toolchain_libs)
#
#   for target aarch64:
#     llvm19_ucrt3_full_aarch64*tar.zst
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
#
# The script also tests the installer, which can be disabled at the end. 
# Innoextract must be installed for extraction test (installer for aarch64
# created on x86_64).
#
# The script takes 4 arguments:
#   <third-number-of-version> <fourth-number-of-version> <original-file-name> <target>
#
# These are filled in to the installer meta-data
# 
#

VIVER3=$1
VIVER4=$2
VIOFN=$3
RTARGET=$4

if [ "X$VIVER3" == X ] ; then
  VIVER3="0"
fi

if [ "X$VIVER4" == X ] ; then
  VIVER4="1"
fi

if [ "X$VIOFN" == X ] ; then
  VIOFN="rtools45-x86_64.exe"
fi 

if [ "X$RTARGET" == X ] ; then
  RTARGET="x86_64"
fi 

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

if [ ${RTARGET} == aarch64 ] ; then
  TRIPLET=aarch64-w64-mingw32.static.posix
  TCFILE=`ls -1 llvm19_ucrt3_full_aarch64*tar.zst | head -1`
  TCTS=llvm19_ucrt3.ts
  ARCHALLOWED="arm64"
  TSUFFIX="-aarch64"
  RTOOLS45_HOME_VARNAME="RTOOLS45_AARCH64_HOME"
  WRONGARCH="This Rtools installer is for 64-bit ARM machines. Rtools installer for 64-bit Intel machines is available from CRAN."
else
  TRIPLET=x86_64-w64-mingw32.static.posix
  TCFILE=`ls -1 gcc14_ucrt3_full*tar.zst | head -1`
  TCTS=gcc14_ucrt3.ts
  ARCHALLOWED="x64 arm64"
  TSUFFIX=""
  RTOOLS45_HOME_VARNAME="RTOOLS45_HOME"
  WRONGARCH="R no longer supports 32-bit Windows. Please use R 4.1 with the 32-bit Rtools installer from CRAN."
fi

# get the toolchain

if [ ! -r ${TCFILE} ] ; then
  echo "Toolchain archive not found." >&2
  exit 1
fi

# create build tools

bash -x make_rtools_chroot.sh $TSUFFIX 2>&1 | tee make_rtools_chroot.out

if [ ! -x build/rtools45$TSUFFIX/usr/bin/make.exe ] ; then
  echo "Failed to create build tools." >&2
  exit 2
fi

if grep -q "FAILED:" make_rtools_chroot.out ; then
  echo "Failed to create Rtools." >&2
  exit 2
fi

if grep -q "incompatible versions of the cygwin" make_rtools_chroot.out ; then
  echo "Failed to create Rtools - incompatible cygwin runtime - need to update Msys2" >&2
  exit 2
fi

# extract toolchain

tar xf ${TCFILE} -C build/rtools45$TSUFFIX

if [ ! -x build/rtools45$TSUFFIX/$TRIPLET/bin/gcc.exe ] ; then
  echo "Failed to unpack toolchain + libs." >&2
  exit 2
fi

# install QPDF

# Msys2 doesn't have a Msys- version of QPDF.  There is a mingw64 version,
# but that comes with extra dependencies and installs into a different tree. 
# As QPDF installation is relocateable, simply copy it over. Windows does
# not support file symlinks without administrator privileges.

cp -R "${QPDFDIR}"/* build/rtools45$TSUFFIX/usr

# build the rtools installer

cat rtools64.iss | \
  sed -e 's/VIVER3/'"$VIVER3"'/g' | \
  sed -e 's/VIVER4/'"$VIVER4"'/g' | \
  sed -e 's/VIOFN/'"$VIOFN"'/g' | \
  sed -e 's/RTARGET/'"$RTARGET"'/g' | \
  sed -e 's/TSUFFIX/'"$TSUFFIX"'/g' | \
  sed -e 's/ARCHALLOWED/'"$ARCHALLOWED"'/g' | \
  sed -e 's/RTOOLS45_HOME_VARNAME/'"${RTOOLS45_HOME_VARNAME}"'/g' | \
  sed -e 's/WRONGARCH/'"$WRONGARCH"'/g' | \
  sed -e 's/TRIPLET/'"$TRIPLET"'/g' \
  > rtools64_ver.iss

"${MISDIR}"/iscc rtools64_ver.iss 2>&1 | tee iscc.out

if [ ! -x Output/rtools45-$RTARGET.exe ] ; then
  echo "Failed to build rtools installer." >&2
  exit 2
fi

# Uncomment to exit here to disable testing, which takes quite long.  Also,
# when the tests fail, they may leave rtools45 partially installed for the
# current user in a test directory.

# exit 0

if [ ${RTARGET} == aarch64 ] ; then
  EMULATED=no
  if systeminfo | grep "System Type:" | grep -q ARM64 ; then
    EMULATED=yes
  fi

  if [ ${EMULATED} == no ] ; then
    echo "Trying extraction instead of install test, cannot install on this platform" >&2
    
    if [ ! -r /mingw64/bin/innoextract.exe ] ; then
      pacman --noconfirm -Sy mingw-w64-x86_64-innoextract
    fi
    rm -rf app
    /mingw64/bin/innoextract.exe -s ./Output/rtools45-$RTARGET.exe

    if diff -r --brief app \
                   build/rtools45$TSUFFIX >diff_test_extract_all.out 2>&1 ; then
      echo "Files in the installer seem currupted." >&2
      mv Output/rtools45-$RTARGET.exe Output/bad_rtools45-$RTARGET.exe
      exit 5
    fi
    
    # skip the installation test below
    exit 0
  fi
  # Fall back to installation test - when running natively on aarch64
fi

# Test the installer runs, installs the intended files and uninstalls them.
# FIXME: the test will fail with aarch64 Rtools on x86_64 machine, because the
# Rtools would refuse to install.

./Output/rtools45-$RTARGET.exe //CURRENTUSER //VERYSILENT //SUPPRESSMSGBOXES //DIR=`cygpath -wa inst` //LOG=test_install.log

if ! grep -q "Installation process succeeded" test_install.log ; then
  echo "The installer does not seem to be working." >&2
  mv Output/rtools45-$RTARGET.exe Output/bad_rtools45-$RTARGET.exe
  exit 3
fi

if diff -r --brief inst \
                   build/rtools45$TSUFFIX >diff_test_install_all.out 2>&1 ; then

  echo "Files in the installer seem currupted." >&2
  mv Output/rtools45-$RTARGET.exe Output/bad_rtools45-$RTARGET.exe
  exit 5
fi

if ! ./inst/unins000.exe //VERYSILENT //SUPPRESSMSGBOXES ; then
  mv Output/rtools45-$RTARGET.exe Output/bad_rtools45-$RTARGET.exe
  echo "Uninstaller failed. " >&2
  exit 6
fi

# The uninstaller is not completely sequential, possibly because it needs to
# also delete itself and the directory it is stored in.
for N in `seq 1 30` ; do
  sleep 1s
  if [ ! -d inst ] ; then
    break
  fi
done

if [ -d inst ] ; then
  echo "Uninstallation left some files behind." >&2
  mv Output/rtools45-$RTARGET.exe Output/bad_rtools45-$RTARGET.exe
  exit 7
fi
