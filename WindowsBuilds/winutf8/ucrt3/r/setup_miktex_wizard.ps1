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
# This uses MiKTeX basic installer (setup wizard).  MiKTeX is installed only
# for the current user, which avoids problems with per-user and system-wide
# installations going out of sync.  This way one may install a concrete
# version of MiKTeX, which is not the latest one (one may update the
# database below, but not the packages).  This is was used to get
# installation of 21.6 when 21.8 was crashing.
#
# This installer does not work in a docker container servercore image, because
# it uses DLLs/features not present there, but it works in the full server
# image.

# https://miktex.org/download/ctan/systems/win32/miktex/setup/windows-x64/basic-miktex-23.10-x64.exe

if (-not(Test-Path("$env:LOCALAPPDATA\Programs\MiKTeX\miktex\bin\x64\")) -and -not(Test-Path("C:\Program Files\MiKTeX\miktex\bin\x64"))) {
  cd temp
  $url = "https://miktex.org/download/ctan/systems/win32/miktex/setup/windows-x64/basic-miktex-23.10-x64.exe"
  $inst =  "..\installers\" + ($url -replace(".*/", ""))
  
  if (Test-Path("$inst")) {
    cp "$inst" basic-miktex.exe
  } elseif (-not(Test-Path("basic-miktex.exe"))) {
    Invoke-WebRequest -Uri "$url" -OutFile basic-miktex.exe -UseBasicParsing
  }

  Start-Process -Wait -FilePath ".\basic-miktex.exe" -ArgumentList "--unattended --private --user-config=""$env:APPDATA\MiKTeX"" --user-data=""$env:LOCALAPPDATA\MiKTeX"" --user-install=""$env:LOCALAPPDATA\Programs\MiKTeX"""
  
  Start-Process -Wait -FilePath "$env:LOCALAPPDATA\Programs\MiKTeX\miktex\bin\x64\initexmf.exe" -ArgumentList "--enable-installer"
  Start-Process -Wait -FilePath "$env:LOCALAPPDATA\Programs\MiKTeX\miktex\bin\x64\initexmf.exe" -ArgumentList "--set-config-value=[MPM]AutoInstall=t"
  Start-Process -Wait -FilePath "$env:LOCALAPPDATA\Programs\MiKTeX\miktex\bin\x64\mpm.exe" -ArgumentList "--verbose --update-db"
  Start-Process -Wait -FilePath "$env:LOCALAPPDATA\Programs\MiKTeX\miktex\bin\x64\mpm.exe" -ArgumentList "--install=inconsolata"
  # tabu is used via texify and for some reason doesn't get installed automatically
  Start-Process -Wait -FilePath "$env:LOCALAPPDATA\Programs\MiKTeX\miktex\bin\x64\mpm.exe" -ArgumentList "--install=tabu"
  cd ..
}
