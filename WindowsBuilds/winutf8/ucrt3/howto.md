---
title: "How to experiment with UTF-8 as native encoding in R on Windows"
author: Tomas Kalibera
output: html_document
---

# How to experiment with UTF-8 as native encoding in R on Window

For UTF-8 as native encoding on Windows, we need a new compiler toolchain
using UCRT as C runtime and we have to rebuild all native code with it: R,
packages with native code and libraries used by those.  Some of that code
needs patching (for UCRT, for newer toolchain, etc).

We also need to adapt our code to work with multi-byte encodings where it
may previously have expected single-byte or double-byte.  Sooner we find
about these problems and fix them, sooner we can enjoy UTF-8 in R on
Windows.

This document describes how to get things started to help testing.

## Binary installer of R, binary packages

One needs recent Windows 10. The binary installer is available
[here](https://www.r-project.org/nosvn/winutf8/ucrt3/),  files named such as
`R-devel-win-79604-4354-4361.exe`. Make sure that this version of R gets its
own library, it is not possible to share the library with a usual build of
R-devel. Only 64-bit version is available.

To check UTF-8 is used as native encoding, run

```
> l10n_info()
$MBCS
[1] TRUE

$`UTF-8`
[1] TRUE

$`Latin-1`
[1] FALSE

$codepage
[1] 65001

$system.codepage
[1] 65001
```

Both "codepage" and "system.codepage" must be 65001. When running RTerm (so
also R.exe) from the command line, make sure to set up this code page and
select a font with a wide set of glyps. In cmd.exe, use `chcp 65001` and
select e.g. `NSimFun` before running R.

R is patched to install binary packages built with UCRT. Most of CRAN and
several BIOC are available at this point and some of them are patched. For
example, try on `PKI`, which is patched.

## Installation of external software

To build R from source, one needs Msys2 (with packages `unzip diffutils make
winpty rsync texinfo tar texinfo-tex zip subversion bison moreutils xz
patch`), MikTeX (with basic packages and `inconsolata`), and Inno Setup. For
building packages, Msys2 may be enough, but there is no harm installing all.

For automated installation (ideal for fresh Windows installs e.g. in virtual
machine or container):

```
cd \
Invoke-WebRequest -Uri https://svn.r-project.org/R-dev-web/trunk/WindowsBuilds/winutf8/ucrt3/r/setup.
PowerShell -ExecutionPolicy Bypass -File setup.ps1
```

Use with care on machines used also for anything else, possibly use the
script as a guide to run installers manually.  You may also want to clean up
after the script (`setup.ps1`, `temp` can be deleted).

## Binary installer of R, building packages from source

Install R from the binary installer and the external software as shown
above.

Download and unpack the gcc10 toolchain and pre-built libraries, set
environment variables, and then run R.  The toolchain and libraries are
available in a single tarball
[here](https://www.r-project.org/nosvn/winutf8/ucrt3/), a file named such as
`gcc10_ucrt3_4354.txz`.

Run an msys2 shell `C:\msys64\msys2.exe` and these commands:

```
mkdir ucrt3
cd ucrt3
wget https://www.r-project.org/nosvn/winutf8/ucrt3/gcc10_ucrt3_4354.txz
tar xf gcc10_ucrt3_4354.txz

export PATH=`pwd`/x86_64-w64-mingw32.static.posix/bin:$PATH
export PATH=`pwd`/x86_64-w64-mingw32.static.posix/libexec/gcc/x86_64-w64-mingw32.static.posix/10.2.0:$PATH
export PATH=/c/Program\ Files/MiKTeX/miktex/bin/x64:$PATH
export TAR="/usr/bin/tar --force-local"
```

Better check the paths are set properly by running

```
$ which cc1 gcc pdflatex
/home/tomas/ucrt3/x86_64-w64-mingw32.static.posix/libexec/gcc/x86_64-w64-mingw32.static.posix/10.2.0/cc1
/home/tomas/ucrt3/x86_64-w64-mingw32.static.posix/bin/gcc
/c/Program Files/MiKTeX/miktex/bin/x64/pdflatex
```

Now run R from this terminal by `/c/Program\ Files/R/R-devel/bin/R`. Try
installing "PKI": `install.packages("PKI", type="source")`

This will build from source `PKI` and its dependency `base64enc`. A patch
for `PKI` to build with UCRT will be downloaded and applied automatically.

## Building R from source

Do all the steps as above (yet there is no need to install binary version of
R).

Download and unpack Tcl/tk bundle from
[here](https://www.r-project.org/nosvn/winutf8/ucrt3/), a file currently
named `Tcl.zip`.  Download R sources.  Download and apply patches for UCRT. 
Do this in the msys2 shell with the settings from above

```
wget https://www.r-project.org/nosvn/winutf8/ucrt3/Tcl.zip

svn checkout https://svn.r-project.org/R/trunk
svn checkout https://svn.r-project.org/R-dev-web/trunk/WindowsBuilds/winutf8/ucrt3/r

cd trunk
for F in ../r/r_*.diff ; do
  patch -p0 < $F
done

unzip ../Tcl.zip
```

Prepare `MkRules.local`, download recommended packages, and build R:

```
cd src/gnuwin32

cat <<EOF >MkRules.local
LOCAL_SOFT = `pwd`/../../../x86_64-w64-mingw32.static.posix
WIN = 64
BINPREF64 =
BINPREF =
USE_ICU = YES
ICU_LIBS = -lsicuin -lsicuuc \$(LOCAL_SOFT)/lib/sicudt.a -lstdc++
USE_LIBCURL = YES
CURL_LIBS = -lcurl -lrtmp -lssl -lssh2 -lgcrypt -lcrypto -lgdi32 -lz -lws2_32 -lgdi32 -lcrypt32 -lidn2 -lunistring -liconv -lgpg-error -lwldap32 -lwinmm
USE_CAIRO = YES
CAIRO_LIBS = "-lcairo -lfontconfig -lfreetype -lpng -lpixman-1 -lexpat -lharfbuzz -lbz2 -lintl -lz -liconv -lgdi32 -lmsimg32"
CAIRO_CPPFLAGS = "-I\$(LOCAL_SOFT)/include/cairo"
TEXI2ANY = texi2any
MAKEINFO = texi2any
ISDIR = C:/Program Files (x86)/InnoSetup
EOF

make rsync-recommended
make all recommended
```

Now you can run R via `../../bin/R`.

To build the installer, run `make distribution`, it will appear in
`installer/R-devel-win.exe`.  To build R with debug symbols, set `export
DEBUG=T` in the terminal before the build (and possibly add `EOPTS = -O0" to
MkRules.local.
