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

$aarch64 = (systeminfo | select-string "System Type:").tostring().contains("ARM64")

# Install Inno Setup

# https://jrsoftware.org/download.php/is.exe?site=2
if (-not(Test-Path("C:\Program Files (x86)\InnoSetup"))) {
  cd temp
  $url = "https://jrsoftware.org/download.php/is.exe?site=2"
  $inst = "..\installers\innosetup-6.4.1.exe"
  
  if (Test-Path("$inst")) {
    cp "$inst" innosetup.exe
  } elseif (-not(Test-Path("innosetup.exe"))) {
    Invoke-WebRequest -Uri "$url" -OutFile innosetup.exe -UseBasicParsing
  }
  Start-Process -Wait -NoNewWindow -FilePath ".\innosetup.exe" -ArgumentList "/VERYSILENT /ALLUSERS /NOICONS /DIR=`"C:\Program Files (x86)\InnoSetup`""
  cd ..
}

# Install MikTeX
#
# This uses MiKTeX basic installet (setup wizard).  MiKTeX is installed only
# for the current users, which avoids problems with per-user and system-wide
# installations going out of sync.  This way one may install a concrete
# version of MiKTeX, which is not the latest one (one may update the
# database below, but not the packages).  This is was used to get
# installation of 21.6 when 21.8 was crashing.
#
# This installer does not work in a docker container servercore image, because
# it uses DLLs/features not present there, but it works in the full server
# image.

# https://miktex.org/download/ctan/systems/win32/miktex/setup/windows-x64/basic-miktex-24.1-x64.exe

if (-not(Test-Path("$env:LOCALAPPDATA\Programs\MiKTeX\miktex\bin\x64\")) -and -not(Test-Path("C:\Program Files\MiKTeX\miktex\bin\x64"))) {
  cd temp
  $url = "https://miktex.org/download/ctan/systems/win32/miktex/setup/windows-x64/basic-miktex-24.1-x64.exe"
  $inst =  "..\installers\" + ($url -replace(".*/", ""))
  
  if (Test-Path("$inst")) {
    cp "$inst" basic-miktex.exe
  } elseif (-not(Test-Path("basic-miktex.exe"))) {
    Invoke-WebRequest -Uri "$url" -OutFile basic-miktex.exe -UseBasicParsing
  }

  Start-Process -Wait -NoNewWindow -FilePath ".\basic-miktex.exe"  -ArgumentList "--unattended --private --user-config=`"$env:APPDATA\MiKTeX`" --user-data=`"$env:LOCALAPPDATA\MiKTeX`" --user-install=`"$env:LOCALAPPDATA\Programs\MiKTeX`""
  
  Start-Process -Wait -NoNewWindow -FilePath "$env:LOCALAPPDATA\Programs\MiKTeX\miktex\bin\x64\initexmf.exe" -ArgumentList "--enable-installer"
  Start-Process -Wait -NoNewWindow -FilePath "$env:LOCALAPPDATA\Programs\MiKTeX\miktex\bin\x64\initexmf.exe" -ArgumentList "--set-config-value=[MPM]AutoInstall=t"
  Start-Process -Wait -NoNewWindow -FilePath "$env:LOCALAPPDATA\Programs\MiKTeX\miktex\bin\x64\mpm.exe" -ArgumentList "--verbose --update-db"
  Start-Process -Wait -NoNewWindow -FilePath "$env:LOCALAPPDATA\Programs\MiKTeX\miktex\bin\x64\mpm.exe" -ArgumentList "--install=inconsolata"
  # tabu is used via texify and for some reason doesn't get installed automatically
  Start-Process -Wait -NoNewWindow -FilePath "$env:LOCALAPPDATA\Programs\MiKTeX\miktex\bin\x64\mpm.exe" -ArgumentList "--install=tabu"
  cd ..
}

# Install QPDF

# https://github.com/qpdf/qpdf/releases/download/v11.9.1/qpdf-11.9.1-msvc64.zip

if (-not(Test-Path("C:\Program Files\qpdf"))) {
  cd temp
  $url = "https://github.com/qpdf/qpdf/releases/download/v11.9.1/qpdf-11.9.1-msvc64.zip"
  $inst =  "..\installers\" + ($url -replace(".*/", ""))
  
  if (Test-Path("$inst")) {
    cp "$inst" qpdf.zip
  } elseif (-not(Test-path("qpdf.zip"))) {
    Invoke-WebRequest -Uri "$url" -OutFile qpdf.zip -UseBasicParsing
  }
  mkdir "C:\Program Files\qpdf"  
  mkdir qpdf
  Expand-Archive -DestinationPath qpdf -Path qpdf.zip -Force
  cd "qpdf\qpdf*"
  Get-ChildItem | Copy-Item -Destination "C:\Program Files\qpdf" -Recurse
  cd ..\..\..
}

# Install Ghostscript

# https://github.com/ArtifexSoftware/ghostpdl-downloads

if (-not(Test-Path("C:\Program Files\gs\gs\bin"))) {
  cd temp
  $url = "https://github.com/ArtifexSoftware/ghostpdl-downloads/releases/download/gs1000/gs1000w64.exe"
  $inst =  "..\installers\" + ($url -replace(".*/", ""))
  
  if (Test-Path("$inst")) {
    cp "$inst" gsw64.exe
  } elseif (-not(Test-path("gsw64.exe"))) {
    Invoke-WebRequest -Uri "$url" -OutFile gsw64.exe -UseBasicParsing
  }
  Start-Process -Wait -NoNewWindow -FilePath ".\gsw64.exe" -ArgumentList "/S /D=C:\Program Files\gs\gs"
  cd ..
}

# Install Msys2

# https://github.com/msys2/msys2-installer/releases/download/2024-12-08/msys2-base-x86_64-20241208.sfx.exe

if (-not(Test-Path("C:\msys64"))) {
  cd temp
  $url = "https://github.com/msys2/msys2-installer/releases/download/2024-12-08/msys2-base-x86_64-20241208.sfx.exe"
  $inst =  "..\installers\" + ($url -replace(".*/", ""))
  
  if (Test-Path("$inst")) {
    cp "$inst" msys2-base.exe
  } elseif (-not(Test-Path("msys2-base.exe"))) {
    Invoke-WebRequest -Uri "$url" -OutFile msys2-base.exe -UseBasicParsing
  }
  cd ..

  Start-Process -Wait -NoNewWindow -FilePath ".\temp\msys2-base.exe"

  # from https://www.msys2.org/docs/ci/
    # Run for the first time
  Start-Process -Wait -NoNewWindow -FilePath "C:\msys64\usr\bin\bash" -ArgumentList "-lc ' '"

    # Update MSYS2
    ## (at some point had to be disabled as it got stuck in docker)  
   Start-Process -Wait -NoNewWindow -FilePath "C:\msys64\usr\bin\bash" -ArgumentList "-lc 'pacman --noconfirm -Syuu'"  # Core update (in case any core packages are outdated)
   Start-Process -Wait -NoNewWindow -FilePath "C:\msys64\usr\bin\bash" -ArgumentList "-lc 'pacman --noconfirm -Syuu'"  # Normal update

    # Install Msys2 packages needed for building R
  Start-Process -Wait -NoNewWindow -FilePath "C:\msys64\usr\bin\bash" -ArgumentList "-lc 'pacman --noconfirm -y -S unzip diffutils make winpty rsync texinfo tar texinfo-tex zip subversion bison moreutils xz patch'"
}
