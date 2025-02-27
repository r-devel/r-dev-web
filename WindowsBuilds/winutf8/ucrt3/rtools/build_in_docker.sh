#! /bin/bash

# Build rtools in a docker container. 
#
# These files must be present in the current directory:
#
#   for target x86_64:
#     gcc14_ucrt3_full*tar.zst (single file, see ../toolchain_libs)
#
#   for target aarch64:
#     llvm17_ucrt3_full_aarch64*tar.zst
#
# The script takes 4 arguments:
#   <third-number-of-version> <fourth-number-of-version> <original-file-name> <target>
#
#   The arguments are filled in to the installer meta-data (and give a hint on naming
#     the toolchain+libraries and the final artifact.
#
# docker must be on PATH and the current user must be allowed to use it
#
# To inspect the container, do
#    winpty docker exec -it buildrtools PowerShell
#

VIVER3=$1
VIVER4=$2
VIOFN=$3
RTARGET=$4

if [ X${RTARGET} != Xaarch64 ] ; then
  RTARGET=x86_64
fi

DOCKER=`which docker`
if [ "X$DOCKER" == X ]; then
  echo "Docker not on PATH."
  exit 1
fi

CID=buildrtools
X=`docker container ls -a | sed -e 's/.* //g' | grep -v NAMES | grep '^'$CID'$'`

# Windows 10 with Hyper-V requires stopped containers
# for file-system operations

if [ "X$X" != X$CID ] ; then
  echo "Creating container $CID"
  docker create --name $CID -it mcr.microsoft.com/windows/server:ltsc2022
  
  if [ -d installers ] ; then
    docker cp installers $CID:\\
  fi

  docker cp ../r/setup.ps1 $CID:\\

  docker start $CID

  # prevent installation  of MiKTeX which is not needed
  # NOTE: QPDF is needed, it is copied into Rtools
  #   (QPDF installation is unzip-only)
  docker exec $CID PowerShell -c '
  New-Item -Path "C:\Program Files\MiKTeX\miktex\bin\x64" -ItemType Directory
  '

  docker exec $CID PowerShell -File setup.ps1 >>buildrtools_setup.out 2>&1

  docker exec $CID PowerShell -c '
  Start-Process -Wait -FilePath "C:\msys64\usr\bin\bash" -ArgumentList "-lc 'pacman --noconfirm -Sy mingw-w64-x86_64-innoextract'"
  '
else
  echo "Reusing container $CID"
  # reuse existing container

  docker stop $CID  
  docker start $CID
  docker exec $CID cmd //c c:/rtools/inst/unins000.exe //VERYSILENT //SUPPRESSMSGBOXES
  docker exec $CID cmd //c rmdir //s //q rtools
fi    

# update Msys2
docker exec $CID PowerShell -c '
  Start-Process -Wait -FilePath "C:\msys64\usr\bin\bash" -ArgumentList "-lc 'pacman --noconfirm -Syuu'"  # Core update (in case any core packages are outdated)
  Start-Process -Wait -FilePath "C:\msys64\usr\bin\bash" -ArgumentList "-lc 'pacman --noconfirm -Syuu'"  # Normal update
'

docker exec $CID PowerShell -c mkdir rtools

docker stop $CID
for F in favicon.ico gitbin.sh icon-small.bmp aliases.sh make_rtools_chroot.sh rtools64.iss build.sh ; do
  docker cp $F $CID:\\rtools
done

if [ ${RTARGET} == aarch64 ] ; then
  TCFILE=`ls -1 llvm17_ucrt3_full_aarch64*tar.zst | head -1`
else
  TCFILE=`ls -1 gcc14_ucrt3_full*tar.zst | head -1`
fi

if [ ! -r ${TCFILE} ] ; then
  echo "Missing toolchain file." >&2
  exit 1
fi
docker cp $TCFILE $CID:\\rtools

docker start $CID

docker exec $CID PowerShell -c \
  'cd rtools ; $env:CHERE_INVOKING="yes" ; $env:MSYSTEM="MSYS" ; C:\msys64\usr\bin\bash -lc ./build.sh'\' $*\' 2>&1 | tee buildrtools_build.out
  
docker stop $CID

docker cp $CID:\\rtools\\make_rtools_chroot.out .
docker cp $CID:\\rtools\\test_install.log .
mkdir Output
docker cp $CID:\\rtools\\Output/rtools45-${RTARGET}.exe Output
docker cp $CID:\\rtools\\iscc.out .

# not deleting the container so that it can be re-used
# docker rm -f $CID
