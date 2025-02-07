# Install additional software needed to check R packages.  Assumes that the
# software needed to build R on Windows (Msys2, InnoSetup, MikTex),
# setup.ps1, has already been installed.  The installers are downloaded
# automatically unless they are made available in "C:\installers" already
# (but only specific versions are supported, see below).

Set-PSDebug -Trace 1
cd C:\

# Needed on Windows Server 2016 (and probably other older Windows systems)
# to download files via https.
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if (-not(Test-Path("temp"))) {
  mkdir temp
}

# Install Pandoc

# https://github.com/jgm/pandoc/releases
if (-not(Test-Path("C:\Program Files\Pandoc"))) {
  cd temp
  if (Test-Path("..\installers\pandoc-2.14.0.1-windows-x86_64.msi")) {
    cp "..\installers\pandoc-2.14.0.1-windows-x86_64.msi" pandoc.msi
  } elseif (-not(Test-path("pandoc.msi"))) {
    Invoke-WebRequest -Uri "https://github.com/jgm/pandoc/releases/download/2.14.0.1/pandoc-2.14.0.1-windows-x86_64.msi" -OutFile pandoc.msi -UseBasicParsing
  }
  Start-Process -Wait -FilePath ".\pandoc.msi" -ArgumentList "ALLUSERS=1 /quiet"
  cd ..
}

# Install Ghostscript

# https://miktex.org/download/ctan/systems/win32/miktex/setup/windows-x64/miktexsetup-4.1-x64.zip
if (-not(Test-Path("C:\Program Files\gs\gs\bin"))) {
  cd temp
  if (Test-Path("..\installers\gs9540w64.exe")) {
    cp "..\installers\gs9540w64.exe" gsw64.exe
  } elseif (-not(Test-path("gsw64.exe"))) {
    Invoke-WebRequest -Uri "https://github.com/ArtifexSoftware/ghostpdl-downloads/releases/download/gs9540/gs9540w64.exe" -OutFile gsw64.exe -UseBasicParsing
  }
  Start-Process -Wait -FilePath ".\gsw64.exe" -ArgumentList "/S /D=C:\Program Files\gs\gs"
  cd ..
}

# Install JDK

# https://adoptopenjdk.net/releases.html
if (-not(Test-Path("C:\Program Files\AdoptOpenJDK"))) {
  cd temp
  if (Test-Path("..\installers\OpenJDK11U-jdk_x64_windows_hotspot_11.0.11_9.msi")) {
    cp "..\installers\OpenJDK11U-jdk_x64_windows_hotspot_11.0.11_9.msi" jdk.msi
  } elseif (-not(Test-path("jdk.msi"))) {
    Invoke-WebRequest -Uri "https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.11%2B9/OpenJDK11U-jdk_x64_windows_hotspot_11.0.11_9.msi" -OutFile jdk.msi -UseBasicParsing
  }
  # for some reason does not work
  #  .\jdk.msi ADDLOCAL="FeatureMain,FeatureEnvironment,FeatureJarFileRunWith,FeatureJavaHome" INSTALLDIR="c:\Program Files\AdoptOpenJDK\" /quiet
  Start-Process -Wait -FilePath ".\jdk.msi" -ArgumentList "/quiet"
  cd ..
}

# Install JAGS

# https://www.r-project.org/nosvn/winutf8/ucrt3/extra/jags/JAGS-4.3.0.exe
if (-not(Test-Path("C:\Program Files\JAGS\JAGS-4.3.0"))) {
  cd temp
  if (Test-Path("..\installers\JAGS-4.3.0.exe")) {
    cp "..\installers\JAGS-4.3.0.exe" jags.exe
  } elseif (-not(Test-path("jags.exe"))) {
    Invoke-WebRequest -Uri "https://www.r-project.org/nosvn/winutf8/ucrt3/extra/jags/JAGS-4.3.0.exe" -OutFile jags.exe -UseBasicParsing
  }
  Start-Process -Wait -FilePath ".\jags.exe" -ArgumentList "/S"
  cd ..
}

# Install handle from Sysinternals

# https://docs.microsoft.com/en-us/sysinternals/downloads/handle
if (-not(Test-Path("C:\Program Files\sysinternals"))) {
  cd temp
  if (Test-Path("..\installers\Handle.zip")) {
    cp "..\installers\Handle.zip" handle.zip
  } elseif (-not(Test-path("handle.zip"))) {
    Invoke-WebRequest -Uri https://download.sysinternals.com/files/Handle.zip -OutFile handle.zip -UseBasicParsing
  }
  mkdir handle
  Expand-Archive -DestinationPath handle -Path handle.zip -Force
  cd handle
  Start-Process -Wait -FilePath ".\handle64" -ArgumentList "-accepteula > $null 2>&1"
  mkdir "C:\Program Files\sysinternals"
  cp *.* "C:\Program Files\sysinternals"
  cd ..\..
}

# Install MSMPI 

# https://github.com/microsoft/Microsoft-MPI/releases/download/v10.1.1/msmpisetup.exe
if (-not(Test-Path("C:\Windows\System32\msmpi.dll"))) {
  cd temp
  if (Test-Path("..\installers\msmpisetup.exe")) {
    cp "..\installers\msmpisetup.exe" msmpisetup.exe
  } elseif (-not(Test-path("msmpisetup.exe"))) {
    Invoke-WebRequest -Uri "https://github.com/microsoft/Microsoft-MPI/releases/download/v10.1.1/msmpisetup.exe" -OutFile msmpisetup.exe -UseBasicParsing
  }
  Start-Process -Wait -FilePath ".\msmpisetup.exe" -ArgumentList "-unattend"
  cd ..
}
