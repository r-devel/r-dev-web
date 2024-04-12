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

$aarch64 = (systeminfo | select-string "System Type:").tostring().contains("ARM64")

# Install MikTeX
#
# This uses the MiKTeX setup utility and allows to have the downloaded set
# of packages prepared for the virtual machine, to save traffic e.g.  with
# repeated use.  However, it always installs the latest version and there is
# no version to do otherwise short of maintianing an extra CTAN mirror.  At
# the time when 21.8 was the latest texify crashing (texify --version). 
#
# Also it is rather difficult to keep the system-wide and per-user package
# sets in sync, and MiKTeX complains when they are out of sync.  On the
# other hand, this installer works in a docker container in the servercore
# image, unlike the setup wizard which needs more libraries.
#
# https://miktex.org/download/ctan/systems/win32/miktex/setup/windows-x64/miktexsetup-4.2-x64.zip
# https://packages.oth-regensburg.de/ctan/systems/win32/miktex/setup/windows-x64/miktexsetup-5.2.0%2Bb8f430f-x64.zip
#
if (-not(Test-Path("$env:LOCALAPPDATA\Programs\MiKTeX\miktex\bin\x64\")) -and -not(Test-Path("C:\Program Files\MiKTeX\miktex\bin\x64"))) {
  cd temp
  $url = "https://mirrors.nic.cz/tex-archive/systems/win32/miktex/setup/windows-x64/miktexsetup-5.5.0%2B1763023-x64.zip"
  $inst =  "..\installers\" + ($url -replace(".*/", ""))
  
  if (Test-Path("$inst")) {
    cp "$inst" miktexsetup.zip
  } elseif (-not(Test-Path("miktexsetup.zip"))) {
    Invoke-WebRequest -Uri "$url" -OutFile miktexsetup.zip -UseBasicParsing
  }
  Expand-Archive -DestinationPath . -Path miktexsetup.zip -Force

  if (Test-Path("..\installers\miktex_repo")) {
    $MREPO=Convert-Path "..\installers\miktex_repo"
  } else {
    if (-not(Test-Path("tmprepo"))) {
      mkdir tmprepo
    }
    $MREPO=Convert-Path tmprepo
    Start-Process -Wait -NoNewWindow -FilePath ".\miktexsetup_standalone.exe" -ArgumentList "--verbose --package-set=basic --shared=yes --local-package-repository=$MREPO download"
  }

  Start-Process -Wait -NoNewWindow -FilePath ".\miktexsetup_standalone.exe" -ArgumentList "--verbose --package-set=basic --shared=yes --local-package-repository=$MREPO install"

  Start-Process -Wait -NoNewWindow -FilePath "C:\Program Files\MiKTeX\miktex\bin\x64\initexmf.exe" -ArgumentList "--admin --enable-installer"
  Start-Process -Wait -NoNewWindow -FilePath "C:\Program Files\MiKTeX\miktex\bin\x64\initexmf.exe" -ArgumentList "--admin --set-config-value=[MPM]AutoInstall=t"
  Start-Process -Wait -NoNewWindow -FilePath "C:\Program Files\MiKTeX\miktex\bin\x64\mpm.exe" -ArgumentList "--admin --verbose --update-db"
  Start-Process -Wait -NoNewWindow -FilePath "C:\Program Files\MiKTeX\miktex\bin\x64\mpm.exe" -ArgumentList "--admin --verbose --update"
  Start-Process -Wait -NoNewWindow -FilePath "C:\Program Files\MiKTeX\miktex\bin\x64\mpm.exe" -ArgumentList "--admin --install=inconsolata"
  # tabu is used via texify and for some reason doesn't get installed automatically
  Start-Process -Wait -NoNewWindow -FilePath "C:\Program Files\MiKTeX\miktex\bin\x64\mpm.exe" -ArgumentList "--admin --install=tabu"

  cd ..
}
