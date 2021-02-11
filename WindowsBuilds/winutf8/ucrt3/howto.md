---
title: "Howto: UTF-8 as native encoding in R on Windows"
author: Tomas Kalibera
output: html_document
---

# Howto: UTF-8 as native encoding in R on Windows

For UTF-8 as native encoding on Windows, we need a new compiler toolchain
using UCRT as C runtime and we have to rebuild all native code with it: R,
packages with native code and libraries used by those.  Some of that code
needs patching (for UCRT, for newer toolchain, etc).

We also need to adapt our code to work with multi-byte encodings where it
may previously have expected single-byte or double-byte encodings.  Sooner
we find about these problems and fix them, sooner we can enjoy UTF-8 in R on
Windows.

This document describes how to get things started to help with testing.
Regular CRAN checks (kind gcc10-UCRT) are being run using the experimental
toolchain described here.

## Binary installer of R, binary packages

One needs recent Windows 10 (May 2019 Update).  The binary installer is
available [here](https://www.r-project.org/nosvn/winutf8/ucrt3/) in a file
named such as `R-devel-win-79604-4354-4361.exe`.  Make sure that this
version of R-devel gets its own library of R packages, it is not possible to
share the library with a usual build of R-devel.  Only 64-bit version is
available.

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
select a font with a wide set of glyphs. In cmd.exe, use `chcp 65001` and
select e.g. `NSimFun` before running R.

R is patched to install binary packages built with UCRT.  Most of CRAN and
several of their BIOC dependencies are available at this point and some of
them are patched.  For example, try on `PKI`, which is patched.

## Installation of external software for building from source

To build R from source, one needs Msys2 (with packages `unzip diffutils make
winpty rsync texinfo tar texinfo-tex zip subversion bison moreutils xz
patch`), MikTeX (with basic packages and `inconsolata`), and Inno Setup.
Inno Setup is only needed for building R, not R packages.

For automated installation (ideal for fresh Windows installs e.g.  in a
virtual machine or a container):

```
cd \
Invoke-WebRequest -Uri https://svn.r-project.org/R-dev-web/trunk/WindowsBuilds/winutf8/ucrt3/r/setup.ps1 -OutFile setup.ps1 -UseBasicParsing
PowerShell -ExecutionPolicy Bypass -File setup.ps1
```

Use that script with care on machines used also for anything else, e.g. 
apply the needed steps manually.  One may also want to clean up after the
script (`temp` can be deleted).

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
installing "PKI": `install.packages("PKI", type="source")`.

This will build from source `PKI` and its dependency `base64enc`. A patch
for `PKI` to build with UCRT will be downloaded and applied automatically.

## Building R from source

Do all the steps as above (yet there is no need to install binary version of
R).

Download and unpack Tcl/Tk bundle from
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

Note that a single patch containing for all the above, used to build the
installer [here](https://www.r-project.org/nosvn/winutf8/ucrt3/), is in a
file named such as `R-devel-79975-4413.diff`.

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
CURL_LIBS = -lcurl -lzstd -lrtmp -lssl -lssh2 -lgcrypt -lcrypto -lgdi32 -lz -lws2_32 -lgdi32 -lcrypt32 -lidn2 -lunistring -liconv -lgpg-error -lwldap32 -lwinmm
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

Now one can run R via `../../bin/R`.

To build the installer, run `make distribution`, it will appear in
`installer/R-devel-win.exe`.  To build R with debug symbols, set `export
DEBUG=T` in the terminal before the build (and possibly add `EOPTS = -O0" to
MkRules.local.

## Updating R packages

R packages with only R code should work without any modification. R packages
with native code (C, Fortran, C++) but without any dependencies on external
libraries, may work right away as well. Other packages will typically need
some work.

### Linking to pre-built static libraries

Some R packages tend to download external static libraries during their
installation, from "winlibs" or other sources.  Such libraries are, however,
built against MSVCRT so they cannot work with UCRT.  A common symptom is
that one gets error messages about undefined references to
`__imp___iob_func` or `__ms_vsnprintf` or `_setjmp`, but downloading of
external code is usually obvious from `src/Makevars.win` or `configure.win`.

To fix this, one needs to instead build against libraries built for UCRT. A
number of these libraries are available with the toolchain. For example,
package `tiff` as of this writing has in `src/Makevars.win`:

```
RWINLIB = ../windows/libtiff-4.1.0/mingw$(WIN)
PKG_CPPFLAGS = -I$(RWINLIB)/include
PKG_LIBS = -L$(RWINLIB)/lib -ltiff -ljpeg -lz

all: clean winlibs

winlibs:
        "${R_HOME}/bin${R_ARCH_BIN}/Rscript.exe" "../tools/winlibs.R"
```

To make the package build with UCRT and the experimental toolchain, one can
replace these lines by:

```
PKG_LIBS = -ltiff -ljpeg -lz -lzstd -lwebp -llzma 
all: clean 

```

Note that even Rtools4 has these libraries, so one may and should reduce the
use of downloading of external pre-built code also with the main package
versions.  Still, one cannot always use the same linking orders with
different toolchains, because libraries may have different names and/or
dependencies. See below for more details how to find the libraries to link
and their order.

### Creating a package patch

This experimental build of R automatically downloads and applies patches to
packages from [here](https://www.r-project.org/nosvn/winutf8/ucrt3/patches), so
[tiff.diff](https://www.r-project.org/nosvn/winutf8/ucrt3/patches/CRAN/tiff.diff)
is a patch for the tiff package discussed above.

To create such a patch, get and unpack the sources

```
wget https://cran.r-project.org/src/contrib/tiff_0.1-6.tar.gz
mkdir original patched
cd original
tar xfz ../tiff_0.1-6.tar.gz
cd ../patched
tar xfz ../tiff_0.1-6.tar.gz
```

If updating an existing patch, apply it first:

```
cd patched
wget https://svn.r-project.org/R-dev-web/trunk/WindowsBuilds/winutf8/ucrt3/r_packages/patches/CRAN/tiff.diff
patch -p1 <tiff.diff
```

now edit `patched/tiff/src/Makevars.win` as shown above.

Test the package:

```
R CMD build patched/tiff # possibly with --no-build-vignettes
R CMD INSTALL tiff_0.1-6.tar.gz
R CMD check tiff_0.1-6.tar.gz
```

Note, "R CMD INSTALL" will still try applying an old patch if present.  That
would probably fail, so it does usually not matter.  To disable this
reliably, set environment variable `_R_INSTALL_TIME_PATCHES_` to e.g. 
`/tmp` (a directory that does not have a patch index, more details later
below).

And when done, create the patch using

```
diff -Nru original/tiff patched/tiff > tiff.diff
```

One may instruct R to download patches, instead, from a local directory. To
do so, download first the current patches from
[here](https://svn.r-project.org/R-dev-web/trunk/WindowsBuilds/winutf8/ucrt3/r_packages/patches/),
update them as needed, then run script [build_patches_idx.r](https://svn.r-project.org/R-dev-web/trunk/WindowsBuilds/winutf8/ucrt3/r_packages/build_patches_idx.r)
to build patch index `patches_idx.rds`, and then tell R via environment
variable `_R_INSTALL_TIME_PATCHES_` about the directory where this index is.

Please contribute any new/updated well tested patches.

### Multiple definitions of symbols

Another common issue observed with the new toolchain are linker errors about
multiply defined symbols.  This may be because GCC 10 is stricter about the
use of tentative definitions (global variables defined without an
initializer) than earlier versions, which allowed merging of tentative
definitions by the linker by putting them into a single "common" block. 
With GCC 10, and earlier version with `-fno-common`, this merging does not
happen and one instead gets the linker error.  A quick hack is to build with
`-fcommon` to still use the common block, and this is also a reliable way of
detecting the cause of the problem.  However, packages with these problem
should be fixed in their main versions rather than by adding `-fcommon` via
a patch for this toolchain (even those for which such toolchain-specific
installation patch has already been created).

### Other issues

Other problems faced already included missing external libraries (MXE
configurations need to be added, as described below), external libraries
built in a way unexpected by the package or in an unexpected version,
headers stored in different directories (note `LOCAL_SOFT` variable is set
to the root of the toolchain, so `$(LOCAL_SOFT)/include` is added
automatically and subdirectories may be added explicitly), explicit setting
of Windows target version (`_WIN32_WINNT`).  Posix thread-safe functions are
only available when `_POSIX_THREAD_SAFE_FUNCTIONS` macro is defined.

## Building the toolchain and libraries from source

The toolchain and libraries are built using a modified version of
[MXE](https://mxe.cc/), which is available
[here](https://svn.r-project.org/R-dev-web/trunk/WindowsBuilds/winutf8/ucrt3/toolchain_libs/mxe). 
The build is run on a Linux machine, so it involves building a
GCC10/MinGW-W64/UCRT cross-compilation toolchain, cross-compiling a large
number of libraries needed by R and R packages, and then building also a
native compiler toolchain so that R and R packages can be built natively on
Windows.

Scripts for setting up the build in docker running Ubuntu 20.04 are
available
[here](https://svn.r-project.org/R-dev-web/trunk/WindowsBuilds/winutf8/ucrt3/toolchain_libs/).
However, this is easy enough and convenient to run natively. On Ubuntu
20.04, following [MXE documentation](https://mxe.cc/#requirements-debian),
install these packages:

```
apt-get install -y \
    autoconf \
    automake \
    autopoint \
    bash \
    bison \
    bzip2 \
    flex \
    g++ \
    g++-multilib \
    gettext \
    git \
    gperf \
    intltool \
    libc6-dev-i386 \
    libgdk-pixbuf2.0-dev \
    libltdl-dev \
    libssl-dev \
    libtool-bin \
    libxml-parser-perl \
    lzip \
    make \
    openssl \
    p7zip-full \
    patch \
    perl \
    python \
    ruby \
    sed \
    unzip \
    wget \
    xz-utils
```

And then also install these:

```
apt-get install -y texinfo sqlite3
```

Run `make` (or `make -j`)  in `mxe`.  The build takes about 2 hours on a
recent server machine, so don't expect that to be fast, but then building
individual MXE packages (new, modified) is fast as the build is incremental
using `make`.

The result will appear in `mxe/usr`, the native toolchain and libraries
specifically in `mxe/usr/x86_64-w64-mingw32.static.posix`. The content of
that directory is currently just packed into a tarball available as
e.g. `gcc10_ucrt3_4354.txz` [here](https://www.r-project.org/nosvn/winutf8/ucrt3/).

## Adding/updating MXE package

Some R packages cannot be built or don't work, because they depend on an
external library not available in the experimental toolchain. To add such
software, one needs to create an appropriate MXE package or update one. [MXE](https://mxe.cc/)
documentation has more details, but for example the package for the tiff
library is named "tiff" and available [here](https://github.com/mxe/mxe/blob/master/src/tiff.mk)
and did not have to be customized for R:

```
# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := tiff
$(PKG)_WEBSITE  := http://simplesystems.org/libtiff/
$(PKG)_DESCR    := LibTIFF
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 4.2.0
$(PKG)_CHECKSUM := eb0484e568ead8fa23b513e9b0041df7e327f4ee2d22db5a533929dfc19633cb
$(PKG)_SUBDIR   := tiff-$($(PKG)_VERSION)
$(PKG)_FILE     := tiff-$($(PKG)_VERSION).tar.gz
$(PKG)_URL      := https://download.osgeo.org/libtiff/$($(PKG)_FILE)
$(PKG)_DEPS     := cc jpeg libwebp xz zlib

define $(PKG)_UPDATE
    $(WGET) -q -O- 'http://simplesystems.org/libtiff/' | \
    $(SED) -n 's,.*>v\([0-9][^<]*\)<.*,\1,p' | \
    head -1
endef

define $(PKG)_BUILD
    cd '$(1)' && ./configure \
        $(MXE_CONFIGURE_OPTS) \
        --without-x
    $(MAKE) -C '$(1)' -j '$(JOBS)' install $(MXE_DISABLE_CRUFT)
endef
```

One may add a new package to `src`, then build it using `make pkgname`, and
when ready, add that to `settings.mk` to the `LOCAL_PKG_LIST` so that it is
built automatically. One the needs to copy the updated
`usr/86_64-w64-mingw32.static.posix` to the Windows machine and perform R
package builds there.

Often one may take inspiration from somewhere else.  First, many packages
are already available in MXE; if they just work, they only need to be added
to `settings.mk`.  Still, a number of packages had to be adapted or upgraded
to build with UCRT.  Then, some packages may be available in a similar
customized version of MXE used by Octave,
[MXE-Octave](https://wiki.octave.org/MXE).  Then some packages popular in R
community not present in MXE may be available in
[Msys2](https://github.com/msys2/MINGW-packages) or in its customized
version [Rtools4](https://github.com/r-windows/rtools-packages), yet those
package configurations are in a different format.  Linux
distributions, e.g.  Debian, then have much bigger selection of build
configurations of packages.

Please contribute any new/updated well tested MXE packages. In the ideal
case, such package configurations should be contributed directly to MXE,
that makes merging upstream changes easier, is a forcing function to meet
their coding style, and a good thing to do.

## Establishing the linking order in R packages via pkg-config

The linking order can be obtained via `pkg-config`, which is only available
on the cross-compilation host (Linux). One may run

```
env PKG_CONFIG_PATH=usr/x86_64-w64-mingw32.static.posix/lib/pkgconfig ./usr/x86_64-pc-linux-gnu/bin/pkgconf --static libtiff-4 --libs-only-l
```

to get `-ltiff -lwebp -lzstd -llzma -ljpeg -lz`, a correct linking order
which may be added to the package `src/Makevars.win` for package tiff.  One
still has to figure out that the pkg-config package name is `libtiff-4` (the
MXE package is `tiff`).

Unfortunately, `pkg-config` does not always provide a working linking order. 
For example, for `opencv`, at the time of this writing,

```
env PKG_CONFIG_PATH=usr/x86_64-w64-mingw32.static.posix/lib/pkgconfig ./usr/x86_64-pc-linux-gnu/bin/pkgconf --static opencv4 --libs-only-l
```

gives

```
-lopencv_highgui451 -lopencv_ml451 -lopencv_objdetect451 -lopencv_photo451 -lopencv_stitching451 -lopencv_video451 -lopencv_calib3d451 -lopencv_features2d451 -lopencv_dnn451 -lopencv_flann451 -lopencv_videoio451 -lopencv_imgcodecs451 -lopencv_imgproc451 -lopencv_core451 -llibopenjp2 -lquirc -lprotobuf -lcomctl32 -lgdi32 -lole32 -lsetupapi -lws2_32 -ljpeg -lwebp -lpng -lz -ltiff -lzstd -llzma -lopengl32 -lglu32
```

which does not work.  One has to add `-L$(LOCAL_SOFT)/lib/opencv4/3rdparty`
so that `-llibopenjp2 -lquirc` are found (`LOCAL_SOFT` is set to the root of
the compiled native toolchain).  Still, this list of libraries is not
complete, a number of dependencies are missing (`webp` is one of them).

## Establishing the linking order via topological sort

As of this writing, the more successful way of establishing linking orders
was via computation over the compiled static libraries.  For this, a little
background follows, substantially simplified.

R on Windows uses static linking.  Static libraries are just archives of
object files, without any references to other static libraries they may need
as dependencies.  The linker keeps track of currently undefined symbols and
goes through the list of libraries (so archives of object files) from left
to right.  If an object file from a library defines a symbol that the linker
knows is undefined, the linker will add that object file to the binary.  It
will then add any additional object files from the same library which define
any undefined symbols arising from the same library, but it will not add
other object files from that library.  This may result in that new symbols
would become undefined after processing that library.  These symbols have to
be defined by some of the additional libraries in the list.

For this to work, one needs to make sure that anytime one library uses
symbols from another, it is processed earlier by the linker.  This is a
problem when there is a loop of dependent libraries, however, one can
usually resolve that by adding some libraries multiple times to the list. 
Note also, as explained before, whether there is a loop or not in practice
depends on which symbols happened to be undefined (needed from the library)
at that particular point, so sometimes this can be resolved by placing the
library earlier or later in the list.  The GNU linker also allows to specify
linking groups, within which linking is repeated in the given order
re-starting until all symbols are resolved (see `--start-group` and
`--end-group`), with a price in performance. This feature has not been
needed yet in the experimental toolchain.

Symbols exported from object files and actually missing at linking time tend
to be unique, and they mostly are in the experimental toolchain.  Exceptions
include inlined C++ functions (but then they are not missing at linking
time), alternative implementations (e.g.  parallel, serial OpenBLAS,
reference BLAS), runtime library wrappers (but they are not missing at
linking time).  Still, it should be possible to come up with a tool that
could well advice on the list and order of libraries to link.  Possibly with
heuristics to resolve some edge cases.

Traditionally, this is done in Unix using `lorder` script and `tsort`. 
`lorder` generates a list of dependencies between static libraries,
defensively assuming that all object files from those libraries are needed. 
`tsort` establishes a topological ordering on the result of `lorder`.  One
can just try to build an R package without linking any libraries, parse the
output from the linker looking for undefined symbols, find static libraries
providing such symbols, and establish the topological ordering.  The
resulting linking order can be then added to the `src/Makevars.win`, the
build of the R package tried again, generating another list of undefined
symbols.  Then one can merge the list of libraries established previously
with the list established now, do the topological sort again, and iterate
this way until linking succeeds.

This is how linking orders for most patched CRAN packages were obtained, but
thorough testing is needed to figure out whether they produce a working
package.  In principle, a better tool could definitely make this process
faster and more automated, and not requiring manual iterative linking
attempts.

Some manual adaptations were needed, anyway, and probably always will. These
included resolving loops (`tsort` gives warning when it sees them, which is
a hint) by shifting libraries in the ordering and adding some twice. Also,
some symbols are not unique and the semi-automated process did not choose
the best library (e.g. `libmincore` and `libwindowsapp` should not be
linked, because they depend on console Windows DLLs which are not present on
Windows Server).

None of this should be needed if the `pkg-config` databases were fixed to
work reliably with static linking.  That could be done via improving MXE
package configurations.  Even though MXE supports static linking, it may not
have been tested as well as dynamic linking.  The effort required may be
bigger than improving a hint tool described above, but if fixed, the results
could be more reliable. One still would need to know the right names of the
pkg-config packages, which are distribution specific.

Note that similar problems with other toolchains may be hidden when
pre-built (bigger) static libraries are being downloaded during package
installation.

## Troubleshooting library loading failures

Sometimes a package DLL is linked succesfully, but the DLL cannot be loaded.
Sometimes it can be loaded on the machine where it was built, but not on
another machine. One example is the linking of console API present on
Windows 10, but not on Windows Server. A common problem why a DLL cannot be
loaded is that a dependent DLL is not found (unlike static libraries, DLLs
know their dependencies). This is a common problem which can happen on
Windows with any toolchain.

When this happens to a DLL linked to an application, such as `Rblas` linked
to `R`, an error message will appear helpfully saying that `Rblas` could not
be found.  However, when such DLL is being loaded explicitly via a Windows
API call (to `LoadLibrary), which is the case when loading DLLs from R
packages, Windows is unable to say which DLL is missing:


```
Error: package or namespace load failed for 'magick' in inDL(x, as.logical(local
), as.logical(now), ...):
 unable to load shared object 'C:/msys64/home/tomas/ucrt3/svn/ucrt3/r_packages/r
inst/library/00LOCK-magick/00new/magick/libs/x64/magick.dll':
  LoadLibrary failure:  The specified module could not be found.
```

Note: in the above, `magick.dll` is present on the path listed.  It is some
of its dependencies that is not found.  The confusing error message comes
directly from Windows.

There is still a way to debug this.  One can install
[WinDbg](https://docs.microsoft.com/en-us/windows-hardware/drivers/debugger/)
from Microsoft (for free), which also includes
[gflags](https://docs.microsoft.com/en-us/windows-hardware/drivers/debugger/gflags).

Using `gflags /i Rterm.exe +sls` (note `gflags` gets installed to `C:\Program Files (x86)\Windows
Kits\10\Debuggers\x64\`) set "loaded snaps" for the R executable. Then run
R, get its process ID using `Sys.getpid()`, start `WinDbg`, attach to the R
process via that process ID, type 'g' (to continue running). In the R
process, try to load the problematic package, e.g. `library(magick)`. This
will produce a number of messages, but in this case, one of them was

```
3e94:29f8 @ 674068078 - LdrpProcessWork - ERROR: Unable to load DLL: "api-ms-win-core-console-l1-2-0.dll", Parent Module: "C:\msys64\home\tomas\ucrt3\svn\ucrt3\r\build_opt\trunk\library\magick\libs\x64\magick.dll", Status: 0xc0000135
```

Which made it clear that `api-ms-win-core-console-l1-2-0.dll` was the
missing DLL.
