# Install software needed to build R on Windows (Msys2, InnoSetup, MikTex). 
# The installers are downloaded automatically unless they are made available
# in "C:\installers" already (but only specific versions are supported, see
# below).

Set-PSDebug -Trace 1
cd C:\

# Needed on Windows Server 2016 (and probably other older Windows systems)
# to download files via https.
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if (-not(Test-Path("temp"))) {
  mkdir temp
}

# Install Inno Setup

# https://jrsoftware.org/download.php/is.exe?site=2
if (-not(Test-Path("C:\Program Files (x86)\InnoSetup"))) {
  cd temp
  if (Test-Path("..\installers\innosetup-6.1.2.exe")) {
    cp "..\installers\innosetup-6.1.2.exe" innosetup.exe
  } else {
    Invoke-WebRequest -Uri https://jrsoftware.org/download.php/is.exe?site=2 -OutFile innosetup.exe -UseBasicParsing
  }
  .\innosetup.exe /VERYSILENT /ALLUSERS /NOICONS /DIR="C:\Program Files (x86)\InnoSetup"
  cd ..
}

# Install MikTeX

# https://miktex.org/download/ctan/systems/win32/miktex/setup/windows-x64/miktexsetup-4.1-x64.zip

if (-not(Test-Path("C:\Program Files\MiKTeX\miktex\bin\x64"))) {
  cd temp
  if (Test-Path("..\installers\miktexsetup-4.1-x64.zip")) {
    cp "..\installers\miktexsetup-4.1-x64.zip" miktexsetup.zip
  } else {
    Invoke-WebRequest -Uri https://miktex.org/download/ctan/systems/win32/miktex/setup/windows-x64/miktexsetup-4.1-x64.zip -OutFile miktexsetup.zip -UseBasicParsing
  }
  Expand-Archive -DestinationPath . -Path miktexsetup.zip -Force

  if (Test-Path("..\installers\miktex_repo")) {
    $MREPO=Convert-Path "..\installers\miktex_repo"
  } else {
    if (-not(Test-Path("tmprepo"))) {
      mkdir tmprepo
    }
    $MREPO=Convert-Path tmprepo
    .\miktexsetup_standalone.exe --verbose --package-set=basic --shared --local-package-repository=$MREPO download
  }

  .\miktexsetup_standalone.exe --verbose --package-set=basic --shared --local-package-repository=$MREPO install

  & "C:\Program Files\MiKTeX\miktex\bin\x64\initexmf.exe" --admin --enable-installer
  & "C:\Program Files\MiKTeX\miktex\bin\x64\initexmf.exe" --admin --set-config-value=[MPM]AutoInstall=t
  & "C:\Program Files\MiKTeX\miktex\bin\x64\mpm.exe" --admin --verbose --update-db
  & "C:\Program Files\MiKTeX\miktex\bin\x64\mpm.exe" --admin --verbose --update
  & "C:\Program Files\MiKTeX\miktex\bin\x64\mpm.exe" --admin --install=inconsolata
  cd ..
}

# Install Msys2

# https://github.com/msys2/msys2-installer/releases/download/2020-11-09/msys2-base-x86_64-20201109.sfx.exe

if (-not(Test-Path("C:\msys64"))) {
  cd temp
  if (Test-Path("..\installers\msys2-base-x86_64-20201109.sfx.exe")) {
    cp "..\installers\msys2-base-x86_64-20201109.sfx.exe" msys2-base.exe
  } else {
    Invoke-WebRequest -Uri https://github.com/msys2/msys2-installer/releases/download/2020-11-09/msys2-base-x86_64-20201109.sfx.exe -OutFile msys2-base.exe -UseBasicParsing
  }
  cd ..

  .\temp\msys2-base.exe

  # from https://www.msys2.org/docs/ci/
    # Run for the first time
  C:\msys64\usr\bin\bash -lc ' '

    # Update MSYS2
  C:\msys64\usr\bin\bash -lc 'pacman --noconfirm -Syuu'  # Core update (in case any core packages are outdated)
  C:\msys64\usr\bin\bash -lc 'pacman --noconfirm -Syuu'  # Normal update

    # Install Msys2 packages needed for building R
  C:\msys64\usr\bin\bash -lc 'pacman --noconfirm -y -S unzip diffutils make winpty rsync texinfo tar texinfo-tex zip subversion bison moreutils xz patch'
}
