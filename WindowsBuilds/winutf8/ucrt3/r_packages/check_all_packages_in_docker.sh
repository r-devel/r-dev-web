#! /bin/bash

# Install CRAN packages and check them in a docker container.  Requires a
# local installation of R (in "rinst", created as a per-user installation
# using the R installer), a local copy of R package patches (in "patches")
# and an index ("patches_idx.rds"), a local mirror of CRAN+BIOC source
# packages in "mirror", repository of binary packages produced by
# build_packages.sh in "build", toolchain installed
# to "x86_64-w64-mingw32.static.posix".
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
#    winpty docker exec -it checkrpkgs PowerShell
#
# FIXME: the container setup is the same as for building packages

DOCKER=`which docker`
if [ "X$DOCKER" == X ]; then
  echo "Docker not on PATH."
  exit 1
fi

if [ -d "pkgcheck" ] ; then
  echo "Directory pkgcheck already exists."
  exit 1
fi

if [ "X${TLIST_TOOL}" == X ] ; then
  TLIST_TOOL="/c/Program Files (x86)/Windows Kits/10/Debuggers/x64/tlist.exe"
fi
if [ ! -r "${TLIST_TOOL}" ] ; then
  echo "TLIST_TOOL (tlist.exe) not available."
  exit 1
fi

CID=checkrpkgs
X=`docker container ls -a | sed -e 's/.* //g' | grep -v NAMES | grep '^'$CID'$'`

# Windows 10 with Hyper-V requires stopped containers
# for file-system operations

if [ "X$X" != X$CID ] ; then
  echo "Creating container $CID"
  docker create --name $CID -it \
    -v `cygpath -w $(pwd)`:'c:\r_packages_ro':ro \
    --storage-opt size=300G \
    mcr.microsoft.com/windows/server:ltsc2022
  
  if [ -d installers ] ; then
    docker cp installers $CID:\\
  fi

  docker cp ../r/setup_miktex_standalone.ps1 $CID:\\
  docker cp ../r/setup.ps1 $CID:\\
  docker cp setup_checks.ps1 $CID:\\  

  docker start $CID

  # install MiKTeX using the standalone installer
  docker exec $CID PowerShell -File setup_miktex_standalone.ps1 >checkrpkgs_setup1.out 2>&1

  docker exec $CID PowerShell -File setup.ps1 >>checkrpkgs_setup1.out 2>&1
  docker exec $CID PowerShell -File setup_checks.ps1 >checkrpkgs_setup2.out 2>&1
  
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

docker exec --user ContainerUser $CID PowerShell -c mkdir r_packages

# admin required for these
docker exec $CID PowerShell -c '
  cd r_packages
  New-Item -Path "mirror" -ItemType SymbolicLink -Value "C:\r_packages_ro\mirror"
  New-Item -Path "x86_64-w64-mingw32.static.posix" -ItemType SymbolicLink -Value "C:\r_packages_ro\x86_64-w64-mingw32.static.posix"
  New-Item -Path "build" -ItemType SymbolicLink -Value "C:\r_packages_ro\build"
  New-Item -Path "rinst" -ItemType SymbolicLink -Value "C:\r_packages_ro\rinst"
  New-Item -Path "patches" -ItemType SymbolicLink -Value "C:\r_packages_ro\patches"
  New-Item -Path "patches_idx.rds" -ItemType SymbolicLink -Value "C:\r_packages_ro\patches_idx.rds"
  New-Item -Path "check_all_packages.sh" -ItemType SymbolicLink -Value "C:\r_packages_ro\check_all_packages.sh"
  New-Item -Path "install_packages_for_checking.r" -ItemType SymbolicLink -Value "C:\r_packages_ro\install_packages_for_checking.r"
  New-Item -Path "check_packages.sh" -ItemType SymbolicLink -Value "C:\r_packages_ro\check_packages.sh"
  New-Item -Path "README_checks" -ItemType SymbolicLink -Value "C:\r_packages_ro\README_checks"
  New-Item -Path "check_stoplist" -ItemType SymbolicLink -Value "C:\r_packages_ro\check_stoplist"
'

docker exec --user ContainerUser $CID PowerShell -c \
  'cd r_packages ; $env:CHERE_INVOKING="yes" ; $env:MSYSTEM="MSYS" ; C:\msys64\usr\bin\bash -lc ./check_all_packages.sh'\' $*\' 2>&1 | tee checkrpkgs_check.out
  
docker stop $CID

mkdir pkgcheck

docker cp $CID:\\r_packages\\pkgcheck\\install_out pkgcheck
docker cp $CID:\\r_packages\\pkgcheck\\results pkgcheck
 # needed for queue checks
docker cp $CID:\\r_packages\\pkgcheck\\lib pkgcheck

# not needed normally
#   docker cp $CID:\\r_packages\\pkgcheck\\CRAN .

docker cp $CID:\\r_packages\\install_packages_for_checking.out .
docker cp $CID:\\r_packages\\check_packages.out .

# not deleting the container so that it can be re-used
# docker rm -f $CID
