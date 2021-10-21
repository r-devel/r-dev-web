#! /bin/bash

# Checks a package (possibly including reverse dependencies) in a docker
# container.  Requires a local installation of R (in "rinst", created as a
# per-user installation using the R installer), a local copy of R package
# patches (in "patches") and an index ("patches_idx.rds"), a local mirror of
# CRAN+BIOC source packages in "mirror", library of installed R packages in
# "lib".
#
# tlist.exe (from Windows Debugging Tools, Windows SDK) must be specified by
# TLIST_TOOL environment variable or be in "/c/Program Files (x86)/Windows
# Kits/10/Debuggers/x64/tlist.exe" on the host machine (unfortunately this
# tool cannot be downloaded and installed automatically with reasonable
# effort, so it is copied into the container).
# 
# It produces "pkgcheck" and the results are in "pkgcheck/results".
#
# docker must be on PATH and the current user must be allowed to use it
#
# To inspect the container, do
#    winpty docker exec -it checkqueue PowerShell
#
# FIXME: the container setup is the same as for building packages

DOCKER=`which docker`
if [ "X$DOCKER" == X ]; then
  echo "Docker not on PATH."
  exit 1
fi

if [ ! -d "pkgcheck/lib" ] ; then
  echo "Package library not available."
  exit 1
fi

if [ "X${TLIST_TOOL}" == X ] ; then
  TLIST_TOOL="/c/Program Files (x86)/Windows Kits/10/Debuggers/x64/tlist.exe"
fi
if [ ! -r "${TLIST_TOOL}" ] ; then
  echo "TLIST_TOOL (tlist.exe) not available."
  exit 1
fi

CID=checkqueue
X=`docker container ls -a | sed -e 's/.* //g' | grep -v NAMES | grep '^'$CID'$'`

# Windows 10 with Hyper-V requires stopped containers
# for file-system operations

mkdir -p qresults

if [ "X$X" != X$CID ] ; then
  echo "Creating container $CID"
  docker create --name $CID -it \
    -v `cygpath -w $(pwd)`:'c:\r_packages_ro':ro \
    mcr.microsoft.com/windows/server:ltsc2022
  
  if [ -d installers ] ; then
    docker cp installers $CID:\\
  fi

  docker cp ../r/setup_miktex_standalone.ps1 $CID:\\
  docker cp ../r/setup.ps1 $CID:\\
  docker cp setup_checks.ps1 $CID:\\  

  docker start $CID

  # install MiKTeX using the standalone installer
  docker exec $CID PowerShell -File setup_miktex_standalone.ps1 checkqueue_setup1.out 2>&1

  docker exec $CID PowerShell -File setup.ps1 >>checkqueue_setup1.out 2>&1
  docker exec $CID PowerShell -File setup_checks.ps1 >checkqueue_setup2.out 2>&1
  
  # set/enable short path names for "Program Files" (needed e.g. by rJava) to
  # get a name without spaces, needed at least in "server:ltsc2022"
  
  docker exec $CID cmd //c fsutil file setshortname "Program Files" PROGRA~1
  docker exec $CID cmd //c fsutil file setshortname "Program Files (x86)" PROGRA~2
  
  # install tlist
  
  docker exec $CID PowerShell -c '
    New-Item -Path "C:\Program Files (x86)\Windows Kits\10\Debuggers\x64\" -ItemType Directory -ErrorAction SilentlyContinue
  '
  docker stop $CID
  docker cp "${TLIST_TOOL}" "$CID:\\Program Files (x86)\\Windows Kits\\10\\Debuggers\\x64\\"
  docker start $CID
  
else
  echo "Reusing container $CID"
  # reuse existing container

  docker stop $CID  
  docker start $CID
  # Remove-Item cannot delete symlinks 
  # docker exec $CID PowerShell -c Remove-Item -Path r_packages -Recurse -Force
  docker exec $CID cmd //c rmdir //s //q r_packages
fi    

if [ "X$1" == XINIT ] ; then
  # update both per-user and per-system MiKTeX installation
  docker exec --user ContainerUser $CID PowerShell -c '
     Start-Process -Wait -FilePath "C:\Program Files\MiKTeX\miktex\bin\x64\mpm.exe" -ArgumentList "--verbose --update-db"
     Start-Process -Wait -FilePath "C:\Program Files\MiKTeX\miktex\bin\x64\mpm.exe" -ArgumentList "--verbose --update"
  '

  docker exec $CID PowerShell -c '
     Start-Process -Wait -FilePath "C:\Program Files\MiKTeX\miktex\bin\x64\mpm.exe" -ArgumentList "--admin --verbose --update-db"
     Start-Process -Wait -FilePath "C:\Program Files\MiKTeX\miktex\bin\x64\mpm.exe" -ArgumentList "--admin --verbose --update"
  '

  docker exec --user ContainerUser $CID PowerShell -c '
     Start-Process -Wait -FilePath "C:\Program Files\MiKTeX\miktex\bin\x64\mpm.exe" -ArgumentList "--verbose --update"
  '
  # only init
  exit 0
fi

docker exec --user ContainerUser $CID PowerShell -c mkdir r_packages

# copy package to the container
docker exec --user ContainerUser $CID PowerShell -c mkdir r_packages/src

CMD="$1"
PKG="$2"

docker stop $CID
docker cp $PKG "$CID:\\r_packages\\src"
docker start $CID

# admin required for these
docker exec $CID PowerShell -c '
  cd r_packages
  New-Item -Path "mirror" -ItemType SymbolicLink -Value "C:\r_packages_ro\mirror"
  New-Item -Path "x86_64-w64-mingw32.static.posix" -ItemType SymbolicLink -Value "C:\r_packages_ro\x86_64-w64-mingw32.static.posix"
  New-Item -Path "build" -ItemType SymbolicLink -Value "C:\r_packages_ro\build"
  New-Item -Path "rinst" -ItemType SymbolicLink -Value "C:\r_packages_ro\rinst"
  New-Item -Path "patches" -ItemType SymbolicLink -Value "C:\r_packages_ro\patches"
  New-Item -Path "patches_idx.rds" -ItemType SymbolicLink -Value "C:\r_packages_ro\patches_idx.rds"
  New-Item -Path "check_single_package.sh" -ItemType SymbolicLink -Value "C:\r_packages_ro\check_single_package.sh"
  New-Item -Path "check_packages.sh" -ItemType SymbolicLink -Value "C:\r_packages_ro\check_packages.sh"
  mkdir pkgcheck
  cd pkgcheck
  New-Item -Path "lib" -ItemType SymbolicLink -Value "C:\r_packages_ro\pkgcheck\lib"
'

# timezone is used for job id (local file date/time)
docker exec --user ContainerUser $CID PowerShell -c \
  'cd r_packages ; $env:CHERE_INVOKING="yes" ; $env:MSYSTEM="MSYS" ; $env:TZ="'$TZ'" ; C:\msys64\usr\bin\bash -lc ./check_single_package.sh'\' $CMD /c/r_packages/src/`basename $PKG`\' 2>&1 | tee checkqueue_check.out
  
docker stop $CID

docker cp "$CID:\\r_packages\\pkgcheck\\qresults" pkgcheck

# not deleting the container so that it can be re-used
# docker rm -f $CID
