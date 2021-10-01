#! /bin/bash

# Build lastest R-devel from subversion into an installer, using gcc10_ucrt3
# toolchain in an interactive Windows container (update the tag below to
# match your Windows system).  The container will be left running unless
# customized at the bottom of the script.
#
# These files must be present in the current directory:
#   gcc10_ucrt3_full*.tar.zst (single file, see ../toolchain_libs)
#   Tcl.zip (see ../toolchain_tcl)
#
# These files may be present in the current directory:
#   "installers" - directory with pre-downloaded installers of the needed
#     software - note that exact file names with versions are hard-coded in
#     the script setup.ps1
#
# Supported arguments are (passed directly to build.sh):
#   --debug .. create a debug build instead of the standard one
#   --check .. run checks
#
# docker must be on PATH and the current user must be allowed to use it
# outputs will appear in directory "build"
#
# To inspect the container, do
#    winpty docker exec -it buildr PowerShell
#


# run docker container

# docker info shows Windows version
#
# Windows 10:
#   mcr.microsoft.com/windows/servercore:2004
# Windows Server 2016:
#   mcr.microsoft.com/windows/servercore:ltsc2016
# Windows Server 2022:
#   mcr.microsoft.com/windows/servercore:ltsc2022
#   mcr.microsoft.com/windows/server:ltsc2022
#
# See/customize below the installation of MiKTeX. The setup wizard
# needs the full Windows (server) image. The standalone installer 
# works in the servercore image as well.

DOCKER=`which docker`
if [ "X$DOCKER" == X ]; then
  echo "Docker not on path."
  exit 1
fi

CID=buildr
X=`docker container ls -a | sed -e 's/.* //g' | grep -v NAMES | grep $CID`

# Windows 10 with Hyper-V requires stopped containers
# for file-system operations

mkdir -p build

if [ "X$X" != X$CID ] ; then
  echo "Creating container buildr"
  docker create --name buildr -it mcr.microsoft.com/windows/server:ltsc2022
  
  if [ -d installers ] ; then
    docker cp installers $CID:\\
  fi

  docker cp setup.ps1 $CID:\\

# install MiKTeX using the standalone installer
#  docker cp setup_miktex_standalone.ps1 $CID:\\

  docker start $CID
  docker exec $CID PowerShell -File setup.ps1 >build/buildr_setup.out 2>&1

# install MiKTeX using the standalone installer
#  docker exec $CID PowerShell -File setup_miktex_standalone.ps1 >build/buildr_setup_miktex_standalone.out 2>&1

  docker exec $CID PowerShell -c mkdir r
  docker stop $CID
else
  echo "Reusing container buildr"
  # reuse existing container
  
  docker start $CID
  docker exec $CID PowerShell -c Remove-Item -Path r -Recurse -Force
  docker exec $CID PowerShell -c mkdir r
  docker stop $CID
fi    


docker cp build.sh $CID:\\r

TCFILE=`ls -1 gcc10_ucrt3_full*tar.zst | head -1`
docker cp $TCFILE $CID:\\r
docker cp Tcl.zip $CID:\\r
for F in r_*.diff ; do
  docker cp $F $CID:\\r
done
docker start $CID

# build R

docker exec $CID PowerShell -c \
  'cd r ; $env:CHERE_INVOKING="yes" ; $env:MSYSTEM="MSYS" ; C:\msys64\usr\bin\bash -lc ./build.sh'\' $*\' 2>&1 | tee build/buildr_build.out

docker stop $CID
docker cp $CID:\\r\\build .

# not deleting the container so that it can be re-used
# docker rm -f $CID

