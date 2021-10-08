#! /bin/bash

# Build R packages to binary packages in an interactive Windows container. 
# Requires a local installation of R (in "rinst", created as a per-user
# installation using the R installer), a local copy of R package patches (in
# "patches") and an index ("patches_idx.rds"), a local mirror of CRAN+BIOC
# source packages in "mirror".  The outputs are in "build/CRAN" and
# "build/BIOC".
#
# docker must be on PATH and the current user must be allowed to use it
#
# To inspect the container, do
#    winpty docker exec -it buildrpkgs PowerShell
#

DOCKER=`which docker`
if [ "X$DOCKER" == X ]; then
  echo "Docker not on PATH."
  exit 1
fi

CID=buildrpkgs
X=`docker container ls -a | sed -e 's/.* //g' | grep -v NAMES | grep $CID`

# Windows 10 with Hyper-V requires stopped containers
# for file-system operations

mkdir -p build

if [ "X$X" != X$CID ] ; then
  echo "Creating container $CID"
  docker create --name $CID -it \
    -v `cygpath -w $(pwd)`:'c:\r_packages_ro':ro \
    --storage-opt size=60G \
    mcr.microsoft.com/windows/server:ltsc2022
  
  if [ -d installers ] ; then
    docker cp installers $CID:\\
  fi

  docker cp ../r/setup.ps1 $CID:\\
  docker cp setup_checks.ps1 $CID:\\  

# install MiKTeX using the standalone installer
#  docker cp setup_miktex_standalone.ps1 $CID:\\

  docker start $CID
  docker exec $CID PowerShell -File setup.ps1 >buildrpkgs_setup1.out 2>&1

# install MiKTeX using the standalone installer
#  docker exec $CID PowerShell -File setup_miktex_standalone.ps1 >build/buildrpkgs_setup_miktex_standalone.out 2>&1

  docker exec $CID PowerShell -File setup_checks.ps1 >buildrpkgs_setup2.out 2>&1

  docker exec $CID PowerShell -c mkdir r_packages
  
  # set/enable short path names for "Program Files" (needed e.g. by rJava) to
  # get a name without spaces, needed at least in "server:ltsc2022"
  
  docker exec $CID cmd //c fsutil file setshortname "Program Files" PROGRA~1
  docker exec $CID cmd //c fsutil file setshortname "Program Files (x86)" PROGRA~2
  
else
  echo "Reusing container $CID"
  # reuse existing container
  
  docker start $CID
  # Remove-Item cannot delete symlinks 
  # docker exec $CID PowerShell -c Remove-Item -Path r_packages -Recurse -Force
  docker exec $CID cmd //c rmdir //s //q r_packages
  docker exec $CID PowerShell -c mkdir r_packages
fi    

docker exec $CID PowerShell -c '
  cd r_packages
  New-Item -Path "mirror" -ItemType SymbolicLink -Value "C:\r_packages_ro\mirror"
  New-Item -Path "x86_64-w64-mingw32.static.posix" -ItemType SymbolicLink -Value "C:\r_packages_ro\x86_64-w64-mingw32.static.posix"
  New-Item -Path "rinst" -ItemType SymbolicLink -Value "C:\r_packages_ro\rinst"
  New-Item -Path "patches" -ItemType SymbolicLink -Value "C:\r_packages_ro\patches"
  New-Item -Path "patches_idx.rds" -ItemType SymbolicLink -Value "C:\r_packages_ro\patches_idx.rds"
  New-Item -Path "build_packages.r" -ItemType SymbolicLink -Value "C:\r_packages_ro\build_packages.r"
  New-Item -Path "build_packages.sh" -ItemType SymbolicLink -Value "C:\r_packages_ro\build_packages.sh"
'

docker exec $CID PowerShell -c \
  'cd r_packages ; $env:CHERE_INVOKING="yes" ; $env:MSYSTEM="MSYS" ; C:\msys64\usr\bin\bash -lc ./build_packages.sh'\' $*\' 2>&1 | tee buildrpkgs_build.out
  
docker stop $CID

docker cp $CID:\\r_packages\\build .
# not needed normally
#   docker cp $CID:\\r_packages\\pkgbuild .
docker cp $CID:\\r_packages\\build_packages.out .

# not deleting the container so that it can be re-used
# docker rm -f $CID
