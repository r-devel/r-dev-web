---
title: "Building R and Packages on Windows"
author: Tomas Kalibera
output: html_document
---

This text is not finished and is currently not maintained.  It was meant to
become documentation for Rtools4.  For technical information on Windows
builds, see e.g.  ../winutf8.

## Introduction

One needs a *compiler toolchain*, some command-line *build tools* and a
number of external open-source *libraries* to build R and to build R package
that use native code.  Most of these things are provided by RTools.  This
document gives some initial background and then concrete steps on how to
build R from source and how to build R packages from source on Windows.

### Compiler toolchain

The compiler toolchain for R needs to include C, Fortran and C++ compilers.
These compilers have to be built with MinGW, which provides an
implementation of some Posix functionality on Windows and headers for
Windows C runtime (C library in Unix terms) and other libraries. We use GCC
on Windows for all of these languages (gcc, gfortran, g++). C++ is not used
by R itself, only by R packages and libraries.

In addition to the compiler executables, a compiler toolchain includes also
binutils (linker, C preprocessor, assembler, low-level utilities to work with
the binaries). A compiler toolchain is normally built from source on Linux
(cross-compiled).

Two sets of compiler toolchains are used, one to produce 32-bit bit code and
one to produce 64-bit code.  Both can run on 64-bit computers with 64-bit
operating systems (the majority of installations today).  In Rtools 4/Msys2
distribution, the compiler toolchain package names start with
"mingw-w64-i686" for the 32-bit and with "mingw-w64-x86_64" for the
64-bit toolchain (they reside in sub-distributions named "mingw32" and
"mingw64").

### Build tools

R and R packages are being built from source on Windows natively, this is
done via Windows-specific make files (so GNU Make is needed) and using some
other tools not normally available on Windows, such as sed, cat, grep, cp,
rm, cmp, cut, mkdir, echo, uniq, unzip, comm, sort, ls, mv, gzip, basename
and date.

Not all of these tools can be built using a MinGW compiler toolchain, the
one we use for R and R packages, because they require Posix functionality
emulation that goes beyond MinGW.  Hence, build tools have to be built using
yet a different compiler toolchain that uses Cygwin runtime to emulate
Posix. Such a compiler toolchain is not otherwise needed for R/R packages,
and thus is not included in RTools. However, the build tools are included
and in Rtools 4/Msys2 they are package names NOT starting with "mingw" (they
reside in "msys" sub-distribution).

### Libraries

External libraries for use with R and R packages are used in static form,
which is the main difference of RTools 4 from Msys2 (Msys2 builds dynamic
libraries and would hence use dynamic linking, instead). Libraries in binary
forms are available in RTools to build R and most CRAN/BIOC packages. With
RTools 3.x, some of these libraries were available in external bundles. With
RTools 4, they are available via a package manager, so they can be
downloaded/installed individually.

### Other tools

Unfortunately there are still some tools needed to build R and R packages
that are not part of RTools. pdflatex is needed to build the documentation.
We use MikTeX, but that has to be installed manually. Also, R uses a
complete installation of Tcl/Tk in form of a bundle that is distributed with
the R binary distribution, but not part of the R sources. That also has to be
installed manually.

## Rtools

RTools include a compiler toolchain for R (GCC with MinGW), the build tools
(built against Cygwin runtime, often coming from Msys2) and most libraries
needed by R and packages, all in binary forms.

In RTools 3.x, files are distributed via an offline installer and several
archives, which can be unpacked manually at appropriate locations, as
documented in R Admin manual, R FAQ and other materials linked from the CRAN
website.  Rtools are used from the Windows prompt (cmd.exe).  Some people
may prefer to use externally Git Bash or even Msys2 for additional command
line tools, a good practice is to do that in another Window to not mix the
PATHs. RTools 3.x are based on GCC 4.9, so they are old by now but can still
be used to build R and R packages.

RTools 4 are a slightly modified version of Msys2.  Some  of the build tools
were modified, such as tar not to be confused by a colon in the path, but
mostly they are a subset of those in Msys2.  Some things have been changed,
including the home directory (in RTools 4, it is the user profile, but in
Msys2, it is in the Msys2 file-system tree) and the installer, which in
Rtools 4 writes to the system registry and hence requires administrator
privileges.  The biggest change from Msys2 is that libraries are built for
static linking. Only a small subset of Msys2 packages are available in
RTools4, but there are also some new that are needed by R packages.

As in Msys2 and in Linux distributions, libraries needed for R packages and
build tools can be installed using the Msys2 package manager (pacman),
automatically caring for dependencies.  There is no mechanism to find an
Msys2/RTools 4 package needed to build a particular R package, but as in
other software distributions one can query which Msys2/RTools 4 package
provides file of a given name (usually a header file or a library). 

Rtools 4 (like Msys2) is used with mintty terminal and bash, providing a
similar experience to Unix, but very unusual for Windows. The expected usage
scenario is to build R from this terminal, but one can also run it from
there. One still needs some external tools for certain tasks, when they are
not available in RTools 4, such as subversion for checking out R source
code.

## Building R 

This part provides all steps needed to build R from source on a fresh
installation of Windows 10 and with recent external software. All using
RTools 4.

### Install MikTeX

This is an optional prerequisite, MikTeX is needed to build the
documentation, but not necessary otherwise to build R/packages from
testing. Some R regression tests require a TeX installation, though.

Install MikTeX from an installer available from
[here](https://miktex.org/download), at the time of this writing it was
[this one](https://miktex.org/download/ctan/systems/win32/miktex/setup/windows-x64/basic-miktex-2.9.7386-x64.exe),
version 2.9, installed into `C:\Program Files\MiKTeX 2.9` (when one chooses
to install for all users, one may also install only for the current user).

Create a mapping for inconsolata fonts. To do that, with MikTeX on PATH, run

```
initexmf --update-fndb
initexmf --edit-config-file updmap
```

The latter opens an editor, add this line to the end and save the file:

```
Map zi4.map
```

Then run `initexmf --mkmaps`.


MiKTeX should be able to install automatically missing styles, it can be
configured via MikTeX console. However, when testing these instructions, it
turned out that this feature does not work when building R, concretely the
NEWS.pdf file.

As a workaround, build manually [this](NEWS.tex) sample LaTeX file from the
command line.  Place this file into a new directory and add a copy of Rd.sty
and Rlogo.pdf from the R source tree (also downloadable from here:
[Rd.sty](Rd.sty) [Rlogo.pdf](Rlogo.pdf)).  Then build the document,
MikTeX will ask for permission and then install all needed MikTeX packages:

```
pdflatex NEWS.tex
```

### Get the Tcl bundle

This is only needed when building R from source, not when only building the
packages.  The easiest way to get a Tcl/Tk bundle needed for R is to install
R from a binary installer, a recent released version of R, but it does not
have to be the latest snapshot.  The bundle is in `Tcl` subdirectory of the
installation tree.  That directory just needs to be copied into the R source
tree (next to directory `src`) whenever building R.

### Install RTools 4

Install Rtools 4 via its [installer](https://cran.r-project.org/bin/windows/Rtools/rtools40-x86_64.exe)
using the defaults.

Run the Msys2 shell from `c:\rtools40\msys2.exe`. The default directory is
`/c/Users/tomas` for user tomas, also known as the user's profile (`C:\Users\tomas`).
The installer arranges for RTOOLS40_HOME variable to be set to RTools 4
installation directory (`c:\rtools40' by default).

Upgrade Msys2/RTools 4 packages: `pacman -Syu`. This may require re-running the
same command in a new shell as instructed by pacman.

Install these parts of the compiler toolchain and libraries for R and R packages (from "mingw64"
sub-repository):

```
pacman -S mingw-w64-x86_64-cairo mingw-w64-x86_64-curl mingw-w64-x86_64-icu
  mingw-w64-x86_64-libjpeg-turbo mingw64/mingw-w64-x86_64-libtiff mingw-w64-x86_64-pcre2
  mingw-w64-x86_64-xz
```

### Get R tarball

Download an R tarball, for example
[this one](`https://cran.r-project.org/src/base-prerelease/R-latest.tar.gz`) via 
`curl -OL https://cran.r-project.org/src/base-prerelease/R-latest.tar.gz`.

Ideally set environment variables
`set TAR_OPTIONS=--no-same-owner --no-same-permissions` and 
`set MSYS=winsymlinks:lnk`
so that permissions and symlinks will be created correctly.

Unpack the tarball: `tar xfzh R-latest.tar.gz`. 
In case you have not set the environment variables shown above, tar will
unpack some files, but eventually it will fail because of symlinks (used for
recommended packages) appearing before their targets.  Just re-run the
command again, then it should finish successfully

### Build R

An R tarball already includes recommended packages, so they will be built as
well.

Create MkRules.local file in `src/gnuwin32` with this content, e.g. using
`cat >MkRules.local` or an external editor.

```
WIN = 64
LOCAL_SOFT =  /c/rtools40/mingw64
BINPREF64 = $(LOCAL_SOFT)/bin/
USE_ICU = yes
ICU_PATH = $(LOCAL_SOFT)
ICU_LIBS = -licuin -licuuc -licudt -lstdc++
USE_LIBCURL = yes
CURL_PATH = $(LOCAL_SOFT)
CURL_LIBS = -lcurl -lrtmp -lssl -lssh2 -lcrypto -lgdi32 -lcrypt32 -lz -lws2_32 -lgdi32 -lcrypt32 -lwldap32 -lwinmm
USE_CAIRO = yes
TEXI2ANY = texi2any
TEXI2DVI = texi2dvi
```

Copy the Tcl bundle to be next to `src`.

Set PATH to include MikTeX:

```
export PATH="/c/Program Files/MiKTeX 2.9/miktex/bin/x64":$PATH
```

Note that when the RTools 4 shell (mintty/bash) executes an external Windows
program such as pdflatex, some environment variables including PATH are
converted, adapting the paths like `/c/msys64` or `/home` to `C:\msys64` and
`C:\msys64\home`, converting also the separators. The same applies e.g. when
running R from the shell.

Go to `src/gnuwin32` and run `make 2>&1 | tee make.out`.  Once it passes
correctly, build also the recommended packages using `make recommended 2>&1
| tee makerp.out`.

As a quick check to validate the installation, run R from `../../bin/R` and
test `sessionInfo()`, check that `extSoftVersion()` gives version numbers
for PCRE and ICU and check that `libCurlVersion()` gives a version number
for curl.

As a more thorough check, run `make check`, possibly also `make check-devel`
and `make check-all`, as when checking a build on other platforms.

R (including RTerm, Rgui) can be run both from the Rtools 4 and from other
Windows shells, including cmd.exe and PowerShell. The Rtools 4 installation
is no longer needed once R is built, except from when building e.g.
packages.

With R built from source this way, one can install a source version of a
package via `install.packages(,type="source")`. This needs to be done with R
running from the RTools 4 shell.

### Build R packages

R packages can be built using R built from source or R installed from the
binary installer. In both cases, it is necessary to install RTools 4
libraries needed by each package. There is not an automated way to map an R
package to RTools 4 packages it needs, but similarly to Linux distributions,
one can do it manually using the package manager.

Download a database of files allowing to find an RTools 4/Msys2 package that
provides a given file: `pacman -Fy`.

Find a package providing `lzma.h`: `pacman -F lzma.h`. Note: when building
64-bit versions of R packages, the RTools 4/Msys2 package name with a
library needs to start with "mingw-w64-x86_64". Packages without the "mingw"
prefix can only be installed if they are build tools that will be only used
for the building (not libraries, not headers).

List of packages already installed: `pacman -Q`.

List of files provided by a package: `pacman -Ql mingw-w64-x86_64-xz`.

Package providing (owning) a given installed file: `pacman -Qo /mingw64/lib/liblzma.a`

All available packages (not only installed): `pacman -Sl` or a more compact
version `pacman -Slq`.

### Build R packages without building R

One can build R packages without re-building R itself from source. To do
that, first install R from the CRAN binary installer, e.g. from
[here](https://cran.r-project.org/bin/windows/base/R-4.0.0-win.exe), that
is the same installer as any R user on Windows would normally use. 

When running R from the installer, lets decide to install a package from
source, e.g. `install.packages("digest", type="source")`. The installation
will fail, not finding `make`. Installation of some other packages may fail
due to other reasons, e.g. not finding `sh` when the package uses
`configure.win`.

Install RTools 4 from its
[installer](https://cran.r-project.org/bin/windows/Rtools/rtools40-x86_64.exe).

Modify PATH variable so that it includes `c:\rtools40\usr\bin'. One can do
this even from the same R session without re-running it:

```
Sys.setenv(PATH=paste("C:\\rtools40\\usr\\bin", Sys.getenv("PATH"), sep=";"))
```

Now, repeat `install.packages("digest", type="source")` and it should pass
properly.

One may add the PATH setting to `~/.Renviron` or other suitable place and
use RTOOLS40_HOME instead of hard-coding the default `c:\rtools40'.

The CRAN R binaries include both 32-bit and 64-bit versions of R and
packages will be also built for both versions by default. This means that
when installing libraries needed by packages, one may have to install also
both versions.

