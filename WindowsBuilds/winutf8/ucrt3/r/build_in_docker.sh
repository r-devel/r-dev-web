#! /bin/bash

# Build lastest R-devel from subversion into an installer, using gcc10_ucrt3
# toolchain in an interactive Windows container (update the tag below to
# match your Windows system).  The container will be left running unless
# customized at the bottom of the script.
#
# These files must be present in the current directory:
#   gcc10_ucrt3*.txz (single file, see ../toolchain_libs)
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

# run docker container

# docker info shows Windows version
#
# Windows 10:
#   CID=`docker run -dit mcr.microsoft.com/windows/servercore:2004`
# Windows Server 2016:
#   CID=`docker run -dit mcr.microsoft.com/windows/servercore:ltsc2016`

CID=`docker run -dit mcr.microsoft.com/windows/servercore:ltsc2016`
echo "Using container $CID"

mkdir -p build

# install Inno Setup, MikTex, Msys2

docker stop $CID # Windows 10 with Hyper-V requires stopped containers
                 # for file-system operations
if [ -d installers ] ; then
  docker cp installers $CID:\\
fi

docker cp setup.ps1 $CID:\\
docker start $CID
docker exec $CID PowerShell -File setup.ps1 >build/setup.out 2>&1

# prepare files for build

docker exec $CID PowerShell -c mkdir r
docker stop $CID
docker cp build.sh $CID:\\r

TCFILE=`ls -1 gcc10_ucrt3*txz | head -1`
docker cp $TCFILE $CID:\\r
docker cp Tcl.zip $CID:\\r
for F in r_*.diff ; do
  docker cp $F $CID:\\r
done
docker start $CID

# build R

docker exec $CID PowerShell -c \
  'cd r ; $env:CHERE_INVOKING="yes" ; $env:MSYSTEM="MSYS" ; C:\msys64\usr\bin\bash -lc ./build.sh'\'$*\' >build/build.out 2>&1

docker stop $CID
docker cp $CID:\\r\\build .

# remove container if needed
# docker rm -f $CID

