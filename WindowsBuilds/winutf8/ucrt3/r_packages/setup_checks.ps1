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

$aarch64 = (systeminfo | select-string "System Type:").tostring().contains("ARM64")

# Install Pandoc

# https://github.com/jgm/pandoc/releases
if (-not(Test-Path("C:\Program Files\Pandoc"))) {
  cd temp
  $url = "https://github.com/jgm/pandoc/releases/download/3.1.11.1/pandoc-3.1.11.1-windows-x86_64.msi"
  $inst =  "..\installers\" + ($url -replace(".*/", ""))
  
  if (Test-Path("$inst")) {
    cp "$inst" pandoc.msi
  } elseif (-not(Test-path("pandoc.msi"))) {
    Invoke-WebRequest -Uri "$url" -OutFile pandoc.msi -UseBasicParsing
  }
  Start-Process -Wait -NoNewWindow -FilePath "msiexec" -ArgumentList "/i pandoc.msi ALLUSERS=1 /qn"
  cd ..
}

# Install Ghostscript

# https://github.com/ArtifexSoftware/ghostpdl-downloads
if (-not(Test-Path("C:\Program Files (x86)\gs\gs\bin"))) {
  cd temp
  $url = "https://github.com/ArtifexSoftware/ghostpdl-downloads/releases/download/gs1000/gs1000w32.exe"
  $inst =  "..\installers\" + ($url -replace(".*/", ""))
  
  if (Test-Path("$inst")) {
    cp "$inst" gsw32.exe
  } elseif (-not(Test-path("gsw32.exe"))) {
    Invoke-WebRequest -Uri "$url" -OutFile gsw32.exe -UseBasicParsing
  }
  Start-Process -Wait -NoNewWindow -FilePath ".\gsw32.exe" -ArgumentList "/S /D=C:\Program Files (x86)\gs\gs"
  cd ..
}

# Install JDK

# https://adoptium.net/download/
if (-not(Test-Path("C:\Program Files\Eclipse Adoptium"))) {
  cd temp
  $url = "https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.2%2B13/OpenJDK21U-jdk_x64_windows_hotspot_21.0.2_13.msi"
  $inst =  "..\installers\" + ($url -replace(".*/", ""))
  
  if (Test-Path("$inst")) {
    cp "$inst" jdk.msi
  } elseif (-not(Test-path("jdk.msi"))) {
    Invoke-WebRequest -Uri "$url" -OutFile jdk.msi -UseBasicParsing
  }
  Start-Process -Wait -NoNewWindow -FilePath "msiexec" -ArgumentList "/i jdk.msi /qn"
  cd ..
}

# Install JAGS

# https://sourceforge.net/projects/mcmc-jags/files/JAGS/4.x/Windows/JAGS-4.3.1.exe
if (-not(Test-Path("C:\Program Files\JAGS\JAGS-4.3.1"))) {
  cd temp
  $url = "https://sourceforge.net/projects/mcmc-jags/files/JAGS/4.x/Windows/JAGS-4.3.1.exe/download"
  $inst = "..\installers\JAGS-4.3.1.exe"
  
  if (Test-Path("$inst")) {
    cp "$inst" jags.exe
  } elseif (-not(Test-path("jags.exe"))) {
    # -UserAgent "NativeHost" to work-around issues with redirects with the default
    Invoke-WebRequest -Uri "$url" -OutFile jags.exe -UseBasicParsing -UserAgent "NativeHost"
  }
  Start-Process -Wait -NoNewWindow -FilePath ".\jags.exe" -ArgumentList "/S"
  cd ..
}

# Install handle from Sysinternals

# https://docs.microsoft.com/en-us/sysinternals/downloads/handle
if (-not(Test-Path("C:\Program Files\sysinternals"))) {
  cd temp
  $url = "https://download.sysinternals.com/files/Handle.zip"
  $inst =  "..\installers\" + ($url -replace(".*/", ""))

  if (Test-Path("$inst")) {
    cp "$inst" handle.zip
  } elseif (-not(Test-path("handle.zip"))) {
    Invoke-WebRequest -Uri "$url" -OutFile handle.zip -UseBasicParsing
  }
  mkdir handle
  Expand-Archive -DestinationPath handle -Path handle.zip -Force
  cd handle
  Start-Process -Wait -NoNewWindow -FilePath ".\handle64" -ArgumentList "-accepteula > $null 2>&1"
  mkdir "C:\Program Files\sysinternals"
  cp *.* "C:\Program Files\sysinternals"
  cd ..\..
}

# Install MSMPI 

# https://github.com/microsoft/Microsoft-MPI/releases/download/v10.1.1/msmpisetup.exe
if (-not(Test-Path("C:\Windows\System32\msmpi.dll"))) {
  cd temp
  $url = "https://github.com/microsoft/Microsoft-MPI/releases/download/v10.1.1/msmpisetup.exe"
  $inst =  "..\installers\" + ($url -replace(".*/", ""))
  
  if (Test-Path("$inst")) {
    cp "$inst" msmpisetup.exe
  } elseif (-not(Test-path("msmpisetup.exe"))) {
    Invoke-WebRequest -Uri "https://github.com/microsoft/Microsoft-MPI/releases/download/v10.1.1/msmpisetup.exe" -OutFile msmpisetup.exe -UseBasicParsing
  }
  Start-Process -Wait -NoNewWindow -FilePath ".\msmpisetup.exe" -ArgumentList "-unattend"
  cd ..
}

# Install GDAL

# QGIS includes GDAL and the installer works unattended, but installed takes
# over 2G).  It should be possible to install GDAL using the osgeo4w-setup
# installer, but for some reason it currently does not seem to be working
# unattended.
#
# (should be no longer needed)

# # https://qgis.org/downloads/QGIS-OSGeo4W-3.22.0-4.msi
# if (-not(Test-Path("C:\Program Files\QGIS 3.22.0"))) {
#   cd temp
#   if (Test-Path("..\installers\QGIS-OSGeo4W-3.22.0-4.msi")) {
#     cp "..\installers\QGIS-OSGeo4W-3.22.0-4.msi" qgis.msi
#   } elseif (-not(Test-path("qgis.msi"))) {
#     Invoke-WebRequest -Uri "https://qgis.org/downloads/QGIS-OSGeo4W-3.22.0-4.msi" -OutFile qgis.msi -UseBasicParsing
#   }
#   Start-Process -Wait -NoNewWindow -FilePath ".\qgis.msi" -ArgumentList "/quiet"
#   cd ..
# }

# Install PhantomJS

# https://phantomjs.org/download.html
# https://github.com/ariya/phantomjs/tags
if (-not(Test-Path("C:\Program Files\phantomjs"))) {
  cd temp
  $url = "https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-windows.zip"
  $inst =  "..\installers\" + ($url -replace(".*/", ""))
  
  if (Test-Path("$inst")) {
    cp "$inst" phantomjs.zip
  } elseif (-not(Test-path("phantomjs.zip"))) {
    Invoke-WebRequest -Uri "https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-windows.zip" -OutFile phantomjs.zip -UseBasicParsing
  }
  mkdir phantomjs
  Expand-Archive -DestinationPath phantomjs -Path phantomjs.zip -Force
  cd phantomjs
  mv phantomjs* phantomjs
  mv phantomjs "C:\Program Files"
  cd ..\..
}

# Install Python

# https://www.python.org/ftp/python/3.11.7/python-3.11.7-amd64.exe
#
# python from Msys2 (msys2 subsystem) does not accept mixed full paths on the
# command line
#
if ($aarch64 -and -not(Test-Path("C:\Program Files\Python311-arm64"))) {
  cd temp
  $url = "https://www.python.org/ftp/python/3.11.7/python-3.11.7-arm64.exe"
  $inst =  "..\installers\" + ($url -replace(".*/", ""))
  
  if (Test-Path("$inst")) {
    cp "$inst" python.exe
  } elseif (-not(Test-path("python.exe"))) {
    Invoke-WebRequest -Uri "$url" -OutFile python.exe -UseBasicParsing
  }
  Start-Process -Wait -NoNewWindow -FilePath ".\python.exe" -ArgumentList "/quiet InstallAllUsers=1"
  # this hack is needed to make e.g. Reticulate work, to allow masking "python3.exe" from Rtools/Msys2
  cp "C:\Program Files\Python311-arm64\python.exe" "C:\Program Files\Python311-arm64\python3.exe"
  cd ..
}

if (-not($aarch64) -and -not(Test-Path("C:\Program Files\Python311"))) {
  cd temp
  $url = "https://www.python.org/ftp/python/3.11.7/python-3.11.7-amd64.exe"
  $inst =  "..\installers\" + ($url -replace(".*/", ""))
  
  if (Test-Path("$inst")) {
    cp "$inst" python.exe
  } elseif (-not(Test-path("python.exe"))) {
    Invoke-WebRequest -Uri "$url" -OutFile python.exe -UseBasicParsing
  }
  Start-Process -Wait -NoNewWindow -FilePath ".\python.exe" -ArgumentList "/quiet InstallAllUsers=1"
  # this hack is needed to make e.g. Reticulate work, to allow masking "python3.exe" from Rtools/Msys2
  cp "C:\Program Files\Python311\python.exe" "C:\Program Files\Python311\python3.exe"
  cd ..
}

# Install Git

# https://github.com/git-for-windows/git/releases
#
if (-not(Test-Path("C:\Program Files\Git"))) {
  cd temp
  $url = "https://github.com/git-for-windows/git/releases/download/v2.43.0.windows.1/Git-2.43.0-64-bit.exe"
  $inst =  "..\installers\" + ($url -replace(".*/", ""))
  
  if (Test-Path("$inst")) {
    cp "$inst" git.exe
  } elseif (-not(Test-path("git.exe"))) {
    Invoke-WebRequest -Uri "$url" -OutFile git.exe -UseBasicParsing
  }
  Start-Process -Wait -NoNewWindow -FilePath ".\git.exe" -ArgumentList "/SUPPRESSMSGBOXES /VERYSILENT"
  cd ..
}

# Install Ruby

# https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-3.1.3-1/rubyinstaller-devkit-3.1.3-1-x64.exe
# FIXME: it uses another instance of Msys2
#
if (-not(Test-Path("C:\Ruby"))) {
  cd temp
  $url = "https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-3.2.3-1/rubyinstaller-devkit-3.2.3-1-x64.exe"
  $inst =  "..\installers\" + ($url -replace(".*/", ""))
   
  if (Test-Path("$inst")) {
    cp "$inst" ruby.exe
  } elseif (-not(Test-path("ruby.exe"))) {
    Invoke-WebRequest -Uri "$url" -OutFile ruby.exe -UseBasicParsing
  }
  Start-Process -Wait -NoNewWindow -FilePath ".\ruby.exe" -ArgumentList "/SUPPRESSMSGBOXES /VERYSILENT /DIR=C:\Ruby"
  cd ..
}

# Install Rust

# https://forge.rust-lang.org/infra/other-installation-methods.html
#
if (-not(Test-Path("C:\Program Files\Rust stable GNU 1.76\bin"))) {
  cd temp
  $url = "https://static.rust-lang.org/dist/rust-1.76.0-x86_64-pc-windows-gnu.msi"
  $inst = "..\installers\" + ($url -replace(".*/", ""))
  
  if (Test-Path("$inst")) {
    cp "$inst" rust.msi
  } elseif (-not(Test-path("rust.msi"))) {
    Invoke-WebRequest -Uri "https://static.rust-lang.org/dist/rust-1.76.0-x86_64-pc-windows-gnu.msi" -OutFile rust.msi -UseBasicParsing
  }
  Start-Process -Wait -NoNewWindow -FilePath "msiexec" -ArgumentList "/i rust.msi ALLUSERS=1 /qn"
  cd ..
}
