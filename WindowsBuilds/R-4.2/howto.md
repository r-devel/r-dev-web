---
title: "Howto: Building R 4.2 and packages on Windows"
author: Tomas Kalibera
output: html_document
---

This document is written as a tutorial intended to be read from the
beginning until reaching the point with the required information.
Users only needing to build existing packages from source will
need to read only the first two sections.

## External software for building from source

MikTeX (with basic packages and `inconsolata`) is needed to build
package vignettes and documentation. Inno Setup is needed to build the
R installer.

Not needed for the "recommended" packages, but some other contributed
CRAN R packages may require additional external software to install or
for the checks (more below).


## Installing Rtools42

R and packages are built using Rtools, which is a collection of build
tools, a compiler toolchain, headers and pre-compiled static libraries.

R 4.2 uses [Rtools42](https://cran.r-project.org/bin/windows/Rtools/rtools42/rtools.html),
where the build tools are from Msys2 and QPDF.  The compiler
toolchain, headers and pre-compiled static libraries are built using
MXE.  Rtools42 is available via a standalone offline installer which
contains all of these components and is available from
[here](https://cran.r-project.org/bin/windows/Rtools/rtools42/files/),
as a file named like `rtools42-4737-4741.exe`, where `4737-4741` are
version numbers.

The installer has currently about 400MB in size and about 3GB will be
used after installation.  It is bigger than Rtools4 because it
includes libraries needed by almost all CRAN packages, so that such
libraries don't have to and shouldn't be downloaded from external
sources (the [CRAN Repository
Policy](https://cran.r-project.org/web/packages/policies.html) has
details on requirements on CRAN).

The advantage is that this way it is easy to ensure that the toolchain and
the libraries are always compatible, and to upgrade the toolchain and all
libraries together. 

It is recommended to use the defaults and install into `c:/rtools42`. When
done that way, Rtools42 may be used in the same R session which installed
it or which was started before Rtools42 was installed.

From the user perspective, Rtools42 works the same as Rtools4 and the
installer is almost the same, but the installation is one step easier (one
does not have to set PATH).

## Building packages from source using Rtools42

One only needs to install the R build (via the installer) and Rtools42 (as
described above), in either order.

No further set up is needed to e.g.:

```
install.packages("PKI", type="source")
```

which will build from source `PKI` and its dependency `base64enc`. 

As a harder and longer test, let's try installing `RcppCWB` from github. 

First, install `devtools` (accept to build packages from source when
offered, but most needed packages will be installed as binary):

```
install.packages(devtools)
```

And then install `RcppCWB` from github as source:

```
devtools::install_github("PolMine/RcppCWB")
```

Finally, let's check installing package `tiff`:

```
download.packages("tiff", destdir=".")
tools::Rcmd("check tiff_0.1-8.tar.gz") # update file name as needed
```

One can run the package check also from command-line, e.g.  cmd.exe, as
usual.  No setting of PATH is necessary, Rtools42 will be found
automatically by R.

R 4.2 on Windows uses UCRT as the C runtime and all native code is built
for this runtime. It is not possible to use static libraries compiled by
previous versions of Rtools, which were built for MSVCRT, an older C runtime
for Windows. UCRT allows UTF-8 to be used as the native encoding.

## Building R from source using Rtools42

As with Rtools4, one may run the Msys2 shell ("Rtools bash" from the startup
menu, or run `c:/rtools42/msys2.exe` and run R from there).  One may also
install additional Msys2 software using `pacman`, e.g.  additional build
tools.

Run the Msys2 shell, update the Msys2 part and install two more package:

```
pacman -Syuu
pacman -Sy wget subversion
```

These pacman commands may also be useful:

* Install an index of available files using `pacman -Fy` and then get e.g. 
a package providing file `unzip.exe` by `pacman -F unzip.exe`.

* List all available packages (not necessarily installed) using `pacman
-Sl`.  List installed packages using `pacman -Q`.

One should only be installing packages from "msys" sub-repository of Msys2,
mixing other sub-repositories with the toolchain may cause trouble.

Like Rtools4, but unlike Msys2 default, the home directory in `bash` is the
user profile (e.g. `C:\Users\username`).

As a next step to install R from source, download and unpack the Tcl/Tk bundle
from [here](https://cran.r-project.org/bin/windows/Rtools/rtools42/files/), a file
named such as `tcltk-4983-4987.zip`, then download the R sources.

```
TCLBUNDLE=tcltk-4983-4987.zip
wget https://cran.r-project.org/bin/windows/Rtools/rtools42/files/$TCLBUNDLE

svn checkout https://svn.r-project.org/R/branches/R-4-2-branch

cd R-4-2-branch
unzip ../$TCLBUNDLE

cd src/gnuwin32
```

To automatically download always the current/latest version of the Tcl
bundle, one can do e.g.  this:

```
wget -np -nd -r -l1 -A 'tcltk-*.zip' https://cran.r-project.org/bin/windows/Rtools/rtools42/files/
```

And a similar trick can be used to obtain other files that always
exist but and have changing version names.

Set environment variables as follows (update the MiKTeX installation
directory in the commands below if needed, this one is "non-standard"
from an automated installation described later below):

```
export PATH=/x86_64-w64-mingw32.static.posix/bin:$PATH
export PATH=/c/Program\ Files/MiKTeX/miktex/bin/x64:$PATH
export TAR="/usr/bin/tar"
export TAR_OPTIONS="--force-local"
```

Test that the tools are available by running

```
which make gcc pdflatex tar
```

Note: GNU `tar`, which is part of Rtools42, does not work with colons used
in drive letters on Windows paths, because it instead uses colons when
specifying non-local archives.  By adding `--force-local` to `TAR_OPTIONS`,
this is disabled and colons work for drive letters.  One can, instead, use
the Windows tar (a variant of BSD tar) on Windows 10 and newer, e.g. 
`/c/Windows/System32/tar`, but several CRAN packages rely on GNU tar
features particularly during installation.  Rtools4 and earlier used a
customized version of GNU tar, which did not need the `--force-local`
options for drive letters to work.

`MkRules.rules` expects Inno Setup in `C:/Program Files (x86)/Inno Setup 6`.
If you have installed it into a different directory, specify it in
`MkRules.local`, as shown here:

```
cat <<EOF >MkRules.local
ISDIR = C:/Program Files (x86)/InnoSetup
EOF
```

Build R and the recommended packages:

```
make rsync-recommended
make all recommended
```

When the build succeeds, one can run R via `../../bin/R`.

To build the installer, run `make distribution`, it will appear in
`installer/R-devel-win.exe`. Note, one may use parallel make via `-j` for
`all` and `recommended`, but not for `distribution` (because the manual
cannot be built in parallel).

To build R with debug symbols, set `export DEBUG=T` in the terminal before
the build (and possibly add `EOPTS = -O0" to MkRules.local to disable
compiler optimizations, hence obtaining more reliable debug information).

## Upgrading Rtools42

Please note that when Rtools42 is uninstalled, one loses also the Msys2
packages installed there in addition to the default set (or any other
possibly accidentally added files to the installation directory, so to
`c:\rtools42` by default).

One might use a standalone installation of Msys2 and use the toolchain from
the tarball (as described later in the text). 

Also, one may upgrade the Msys2 part of Rtools42 by `pacman`:

```
pacman -Syuu
```

The toolchain and libraries in Rtools42 can be upgraded from the Rtools42
Msys2 bash. The toolchain and libraries are inside
`/x86_64-w64-mingw32.static.posix` (which corresponds to
`c:\rtools42\x86_64-w64-mingw32.static.posix` outside the shell).

To find what is the current installed version, run

```
cat /x86_64-w64-mingw32.static.posix/.version
```

You will get a single number, such as `4911`, which corresponds to the
number in the toolchain tarball name, e.g. `rtools42-toolchain-libs-full-4911.tar.zst`. So
all that is needed is to delete the directory, download the current full toolchain tarball from
[here](https://cran.r-project.org/bin/windows/Rtools/rtools42/files/)
and extract it. This can be done from the shell using commands like

```
cd /
wget https://cran.r-project.org/bin/windows/Rtools/rtools42/files/rtools42-toolchain-libs-full-4911.tar.zst
rm -rf /x86_64-w64-mingw32.static.posix
tar xf rtools42-toolchain-libs-full-4911.tar.zst
rm rtools42-toolchain-libs-full-4911.tar.zst
```

For reference, one may find out exactly how that version of the toolchain
was built by checking out

```
svn checkout -r 4911 https://svn.r-project.org/R-dev-web/trunk/WindowsBuilds/winutf8/ucrt3/toolchain_libs/mxe/
```

The version numbers, download URLs for the sources, and build configurations
are under "src" (not all of those packages are part of the toolchain). So
e.g. to find out how `tiff` was built, one may run

```
svn cat -r 4911 https://svn.r-project.org/R-dev-web/trunk/WindowsBuilds/winutf8/ucrt3/toolchain_libs/mxe/src/tiff.mk
```

This is one way to quickly find out if an upgrade would provide a newer
version of a specific library.

An upgrade "to fix things, without knowing for sure it will help" may be
useful when one is building someone else's source packages (so not from
CRAN, where binary packages are provided, but say from github) and the
package doesn't build due to say linking errors, but it builds correctly
somewhere else (say via github actions on the package github page).  One
might also try on Winbuilder.  When such package is building on Winbuilder
or via github actions fine, but locally has linking errors, it may be that
an upgrade could help.

In other cases, a package author working on their own package would probably
know for sure that an upgrade is needed, e.g.  when local installation of
Rtools42 does not have a library which was however already added to
Rtools42.  Upgrading in other cases would likely be a waste of time and
resources.

## Co-existence of different Rtools and R versions

Package authors may prefer to have both Rtools4 and Rtools42 installed in
their system.  This is possible, these are treated as different applications
by Windows and are installed in different directories (by default
`c:\rtools40` and `c:\rtools42`).  It means one would have duplicate
installations of Msys2 (which are included in both), so there would be
different sets of Msys2 packages and different versions in the two
corresponding "Rtools" Msys2 shells. The home directory as perceived by the
shells will be the same (the user profile), which may be a good thing, yet,
there are potential issues with configurations of some of the tools, if they
have different versions.  That would be easiest to solve by upgrading the
Msys2 packages in both installations of Rtools.

R version 4.1 and 4.0 would automatically use Rtools40 as documented for
those versions (with the necessity to put the build tools on PATH, as
documented). R 4.2 uses Rtools42 automatically as documented here.

Note that mixing build tools from different versions of Msys2 may not work
due to incompatibilities in the Cygwin/Msys runtime in those versions.  It
is not a good idea to put tools from different versions on PATH, nor to call
from an Msys2 bash tools from a different installation.  However, the
toolchain and libraries themselves
(`c:\rtools42\x86_64-w64-mingw32.static.posix` in Rtools42 or
`c:\rtools40\mingw64` in Rtools40) do not link to the Cygwin/Msys runtime
and hence can be used from an external Msys2 installation.  Please note that
the delineation of what is a build tool and what is inside the toolchain and
libraries part is not always clear and may change over time, depending on
how it is easiest to build the tool.

## Installing software for building using a toolchain tarball

Alternatively, one may also use custom build tools (e.g.  a standalone
version of Msys2) with a "toolchain tarball" consisting only of the compiler
toolchain, headers and pre-compiled static libraries. This is useful for
server and expert use.

The "base" version of the toolchain tarball contains the compiler toolchain
and libraries needed to build R itself, including the recommended packages,
but it is enough for most CRAN packages.  The "full" version
contains libraries for almost all CRAN packages.

The tarballs do not include Msys2.  One instead needs to have a separate
installation of the required build tools, typically a standalone
installation of Msys2.  This text assumes a standalone Msys2 installation at
least with packages `unzip diffutils make winpty rsync texinfo tar
texinfo-tex zip subversion bison moreutils xz patch`.

The tarballs are more flexible in that one does not need to always install
Msys2 nor the full set of libraries.  Also, tarballs are compressed using
the Zstandard compressor, which works better for this content than the
compressor used by Rtools42 (InnoSetup does not support Zstandard as of this
writing), so the compressed file is smaller and decompresses faster.

The script below automatically installs Msys2, MiKTeX and Inno Setup (the
last two into non-standard directories) and can be used on fresh systems or
virtual machines or containers without previous installation of this
software.  It could also be used as an inspiration for installing on real
systems, but one should review it first or run selected lines manually,
to prevent damage to the existing installations:

```
cd \
Invoke-WebRequest -Uri https://svn.r-project.org/R-dev-web/trunk/WindowsBuilds/winutf8/ucrt3/r/setup.ps1 -OutFile setup.ps1 -UseBasicParsing
PowerShell -ExecutionPolicy Bypass -File setup.ps1
```

One may also want to clean up after the script (`temp` can be deleted).

## Additional external software for building and checking from source

Additional software is needed by some contributed CRAN packages, including
Pandoc, Ghostscript, JDK, JAGS, MSMPI, and one package even GDAL including
executables.  A script is
[available](https://svn.r-project.org/R-dev-web/trunk/WindowsBuilds/winutf8/ucrt3/r_packages/setup_checks.ps1)
to install these automatically on a new system, following the `setup.ps1`
script mentioned earlier.  These scripts are regularly used in a setup for
testing newer versions of Rtools (named "ucrt3"), they are not regularly
tested with R 4.2 anymore, so may require some adaptations.  Also, when the
scripts are run (regularly) with "ucrt3", the installers are pre-downloaded:
eventually it may be necessary to update them for newer versions when the
older installers become inaccessible.


## Building packages from source using the toolchain tarball

This section assumes that R has been installed from its binary
installer.

First, download the toolchain and libraries. They are available in a
single tarball
[here](https://cran.r-project.org/bin/windows/Rtools/rtools42/files/),
a file named such as `rtools42-toolchain-libs-full-4737.tar.zst` (4737
is the version number).  The "base" toolchain is named
`rtools42-toolchain-libs-base-4737.tar.zst`.

You may run an Msys2 shell `C:\msys64\msys2.exe` and the following commands
(please note the number 4737 in this example needs to be replaced by the
current release available, there is always only one at a time):

```
mkdir ucrt3
cd ucrt3
wget https://cran.r-project.org/bin/windows/Rtools/rtools42/files/rtools42-toolchain-libs-full-4737.tar.zst
tar xf rtools42-toolchain-libs-full-4737.tar.zst

export R_CUSTOM_TOOLS_SOFT=`pwd`/x86_64-w64-mingw32.static.posix
export R_CUSTOM_TOOLS_PATH=`pwd`/x86_64-w64-mingw32.static.posix/bin:/usr/bin
export PATH=/c/Program\ Files/MiKTeX/miktex/bin/x64:$PATH
export TAR="/usr/bin/tar"
export TAR_OPTIONS="--force-local"
```

To make the use of Rtools42 simpler, when R is installed via the binary
installer it by default uses Rtools42 for the compilers and libraries. 
`PATH` will be set by R (inside front-ends like RGui and RTerm, but also R
CMD) to include the build tools (e.g.  make) and the compilers (e.g.  gcc). 
In addition, R installed via the binary installer will automatically set
`R_TOOLS_SOFT` (and `LOCAL_SOFT` for backwards compatibility) to the
Rtools42 location for building R packages.  This feature is only present in
the installer builds of R, not when R is installed from source.

Now we are building packages using a custom installation of the toolchain
(the toolchain tarball) at an arbitrary location, and we use R installed
from the binary installer, and hence as shown above we set
`R_CUSTOM_TOOLS_PATH` and `R_CUSTOM_TOOLS_SOFT`.  `R_CUSTOM_TOOLS_PATH` will
be prepended to PATH instead of the Rtools42 directories. 
`R_CUSTOM_TOOLS_SOFT` value will be used as `R_TOOLS_SOFT` (and
`LOCAL_SOFT`) instead of the Rtools42 soft directory.  See below in this
text for discussion re `LOCAL_SOFT`.

This is not needed when installing R from source and building R packages
using that installation. In such case, the build tools and compilers already
have to be on PATH, and R uses by default `R_TOOLS_SOFT` (and `LOCAL_SOFT`)
derived from that. See below in this text for discussion re `LOCAL_SOFT`.

One wouldn't have to add `/usr/bin` to `R_CUSTOM_TOOLS_PATH` when running in
a standard installation of Msys2, but it is done here for instructional
purposes and may be useful in more complicated setups where a mix of tools
may be on PATH, such as github actions (but note the problems with
incompatible Cygwin/Msys runtimes mentioned above).

Note in the above example that the compiler toolchain does not have to be on
PATH itself, but it would do no harm if it were.

Now run R from the same terminal by `/c/Program\ Files/R/R-4.2.0/bin/R`. Try
installing "PKI": `install.packages("PKI", type="source")`.

This will build from source `PKI` and its dependency `base64enc`. 

Examples in this document use Msys2 with mintty and bash, which is the
default with Msys2 and is perhaps easier to use with building/testing for
those familiar with Unix. One can, however, also use cmd.exe, with the
benefit of nicer fonts and more reliable line editing (mintty uses a
different interface to communicate with RTerm).

## Building R from source using the toolchain tarball

Download and unpack Tcl/Tk bundle from
[here](https://cran.r-project.org/bin/windows/Rtools/rtools42/files/), a file named such as
`tcltk-4983-4987.zip`.
Do this in the Msys2 shell  (please note that
the numbers 80890 and 4736 need to be replaced by the current ones)

```
TCLBUNDLE=tcltk-4983-4987.zip
wget https://cran.r-project.org/bin/windows/Rtools/rtools42/files/$TCLBUNDLE

svn checkout https://svn.r-project.org/R/branches/R-4-2-branch

cd R-4-2-branch
unzip ../$TCLBUNDLE

cd src/gnuwin32
```

Set environment variables. Note that when building R, one needs to have the
compiler toolchain on PATH, it is not added automatically in this case
(adjust below if the toolchain tarball was unpacked in a different
directory). The `R_CUSTOM_TOOLS_SOFT` and `R_CUSTOM_TOOL_PATH` variables are
not needed when buillding R from source, but setting them would do no harm:

```
export PATH=/c/my_toolchain_location/x86_64-w64-mingw32.static.posix/bin
export PATH=/c/Program\ Files/MiKTeX/miktex/bin/x64:$PATH
export TAR="/usr/bin/tar"
export TAR_OPTIONS="--force-local"
```

Test that the tools are available by running (set variables like for
building R packages, as shown above):

```
which make gcc pdflatex tar
```

`MkRules.rules` expects Inno Setup in `C:/Program Files (x86)/Inno Setup 6`.
If you have installed it into a different directory (such as by the
automated script above), specify it in `MkRules.local`:

```
cat <<EOF >MkRules.local
ISDIR = C:/Program Files (x86)/InnoSetup
EOF
```

Build R and recommended packages:

```
make rsync-recommended
make all recommended
```

When the build succeeds, one can run R via `../../bin/R`.

To build the installer, run `make distribution`, it will appear in
`installer/R-*.exe`.

To build R with debug symbols, set `export DEBUG=T` in the terminal before
the build (and possibly add `EOPTS = -O0" to MkRules.local to disable
compiler optimizations, hence obtaining reliable debug information).

## Testing packages using github actions

Github default runners for github actions include Windows Server 2022, which
has support for UTF-8 as native encoding and has pre-installed build tools. 
It is thus convenient to install only the toolchain tarball there, packaged
using Zstandard compression (smaller, faster to decompress).

For packages that only need libraries from the "base" toolchain, it is
better to use that, saving more time and bandwidth.  The actions should
download the toolchain from github, not from CRAN servers.

R itself can be installed from the binary installer and cached. Caching the
toolchain itself is not helpful: the default compression currently used for
that is much less efficient than Zstandard, so using the cache checking
takes longer and requires more resources.

An experiment has been carried out using `codetools` (a package without
dependencies and not needing compilation) and using `tiff` (a package needed
compilation and depending on two more packages). 

With `tiff`, checking with a missing toolchain (which fails) took over 1
minute. Checking with the base toolchain took nearly 2 minutes (and
passed, it is enough for the involved packages). Checking with the full
toolchain took 3 minutes (note: the timings are expected to vary based on
internal github setup). More information is available
[here](https://github.com/kalibera/ucrt3), based on "ucrt3" when it was the
same as R-devel. However, for use with current R 4.2 and Rtools42,
this will have to be updated.

## Other package building/checking options

As with previous versions of R and Rtools, the
[Winbuilder](https://win-builder.r-project.org/) service can be used for
building and checking packages on Windows, with the same setup that is used
for CRAN incomming checks and CRAN binary package builds, with all CRAN and
Bioconductor packages available for checking.

Additional checking services are available including
[R-hub](https://builder.r-hub.io/).

## Debugging packages with native code

R is built and distributed without debug symbols, so the first step should
be building R from source including debug symbols.  It is recommended to
build R without compiler optimizations (`-O0`) to make sure the debug
symbols are precise (and only fall back to default optimizations if
necessary to reproduce the problem).

It is better not to build the R installer, but use R for debugging from the
build tree, so that the sources are readily available for modification and
also for the debugger (otherwise one would have to instruct the debugger
where to find the sources; `directory` is the command for `gdb`).  See the
previous sections on building R from source.

When R is built with debug symbols this way, R packages installed by it from
source will also have debug symbols. It may be convenient to install the
package from a directory, rather than a tarball, e.g.

```
tar xf PKI_0.1-11.tar.gz
../../bin/R CMD INSTALL PKI
```

To use `gdb` as the debugger, one may install it using `pacman` in Rtools42
(and hence Msys2) as follows:

```
pacman -Sy gdb
```

Lets say we want to debug PKI R function `PKI.genRSAkey` which is
implemented in C in `PKI_RSAkeygen`. We will need two Rtools42 (Msys2) shell
windows.

In the first window, run R, load the PKI package (DLL) and find out the
process ID:

```
$ ../../bin/R
> library(PKI)
Loading required package: base64enc

> Sys.getpid()
[1] 11860
```

In the second window, run `gdb`, attach to the R process, set a break-point
on the `PKI_RSAkeygen` function and let the R process continue:

```
$ gdb
(gdb) attach 11860
Attaching to process 11860
(gdb) b PKI_RSAkeygen
Breakpoint 1 at 0x7ffd06226491: file pki-x509.c, line 629.
(gdb) c
Continuing.
```

Now, in the first window, run the R function to debug:

```
key <- PKI::PKI.genRSAkey(bits = 512L)
```

In the second windows, the debugger will give a prompt to debug the C
function:

```
Thread 1 hit Breakpoint 1, PKI_RSAkeygen (sBits=0x21fdea4b2a8) at pki-x509.c:629
629         int bits = asInteger(sBits);
(gdb)
```

For more, please refer to GDB documentation.  Useful commands are `p` (print
value of a variable), `c` (continue executing), `n` (execute one step not
interrupting inside called functions), `s` (execute one step interrupting inside
called functions), `bt` (print C stacktrace).  One can also use `p` to call
some functions defined in R, e.g.  to print R stacktrace (in the R window):

```
(gdb) p Rf_printwhere()
```

And to print an R value (SEXP):

```
(gdb) p Rf_PrintValue()
```

or to modify value of a variable.

Please note that interrupting R execution to enter the debugger by pressing
Ctrl-C does not work reliably, hence attaching to the R process is
preferred. Also please note that one cannot reliably place the breakpoint
before the DLL is loaded (pending breakpoints don't work).

But, one can instruct R to enter the debugger prompt (break into it) if
running inside a debugger.  Rgui has this feature.  Run Rgui in `gdb`:

```
gdb ../../bin/x64/Rgui.exe
(gdb) r
```
And once Rgui opens up, load the package:

```
library(PKI)
```

and then resize the Rgui window to see also the gdb window and choose
`Misc/Break to debugger` from the Rgui menu.  That way you will get into
`gdb` prompt in the terminal window from which you have run Rgui, and
continue as in the previous example.

### Additional debugging hints

It is recommended to combine C code modifications (adding debug messages,
checks, etc) when debugging issues. Oftentimes it may be easier than using
a debugger. In some cases, combining C code modifications and the debugger
is useful.

Inside R source code, one may also call a function `breaktodebuger()` which
does the same thing as entering the debugger from Rgui menu mentioned above. 
In any code, including packages, a primitive trick is to cause a crash when
an interesting code path is reached.  One can do this e.g.  by `*(int *)0 =
1` in C.  However, additional consideration is needed on Windows to make
sure the debugger is entered (more below).

For example, assume that we modify the PKI package file
`PKI/src/pki-x509.c` as follows:

```
SEXP PKI_RSAkeygen(SEXP sBits) {
    EVP_PKEY *key;
    RSA *rsa;
    int bits = asInteger(sBits);
    if (bits == 2192)
        *(int *)0 = 1; /* crash */
```

and reinstall the package using `R CMD INSTALL PKI`.

For this to work, `gdb` has to be on the image and process that will crash,
not on a parent process.  One can debug `../../bin/x64/Rgui.exe` as shown
above, but to do this in Rterm, one needs to debug directly
`../../bin/x64/Rterm.exe` and run `gdb` from a standard Windows console
program, such as `cmd.exe`, e.g.  as follows:

```
Microsoft Windows [Version 10.0.19044.1620]
(c) Microsoft Corporation. All rights reserved.

C:\Users\tomas>c:\rtools42\usr\bin\bash.exe -l

$ cd trunk/src/gnuwin32/
$ gdb ../../bin/x64/Rterm.exe
```

The issue with the Rtools42/Msys2 shell (mintty terminal) is that it needs
re-execution using `winpty` for line editing to work. That is done
automatically by Rterm on Windows, but then we are not running `gdb` on the
process that will crash.

At the time of this writing, `gdb` in Msys2/Rtools42 prints a python error
message at startup like

```
Traceback (most recent call last):
  File "<string>", line 3, in <module>
ModuleNotFoundError: No module named 'libstdcxx'
/etc/gdbinit:6: Error in sourced command file:
Error while executing Python code.
```

This is because of a missing Python module and has been reported to Msys2.
That module is part of the `gcc` package, which one may also install to get
rid of this, but then one has to be careful not to accidentally use that
version of `gcc` instead of the one from `/x86_64-w64-mingw32.static.posix`.
It is safe to instead ignore this error message.


## Writing/updating R packages for Rtools42

R packages with only R code do not need any special consideration as they
don't need Rtools.  R packages with native code (C, Fortran, C++) but
without any dependencies on external libraries, should not need any
Rtools42-specific customizations; they should work even when authored for
Rtools4 or older.

Other packages will typically need some updates/consideration, because
traditionally R packages on Windows hard-code the list of libraries to link
and the include directories for headers, and so far there is not a working,
easy-to-use alternative. The updates are needed as things change in Rtools,
and the changes between Rtools4 and Rtools42 were significant.

### Prepared patches for packages

During the transition from MSVCRT (and Rtools40) to UCRT (and Rtools 42),
patches were created for over a 100 of CRAN and Bioconductor packages.  Some
packages have been fixed by adopting those patches, but other were fixed
differently.  In case package authors run into a problem, it may be useful
first consulting an old patch when available, because it may be working fine
as is or after some small update.

A typical example would be using external libraries from Rtools42 as opposed
to downloading them (more in the next section).  Also, some packages may
have been archived from CRAN as they haven't been fixed in time, but the
patches to fix them are still available, so can be consulted if such
packages are to be re-submitted.

The patches are available
[here](https://svn.r-project.org/R-dev-web/trunk/WindowsBuilds/winutf8/ucrt3/r_packages/patches/)
and
[here](https://svn.r-project.org/R-dev-web/trunk/WindowsBuilds/winutf8/ucrt3/r_packages/old_patches/).

During a transitional period, these patches were applied automatically by
(patched and then un-patched) R-devel at installation time, but that is no
longer the case.  The history of the patches, as well as some that were
deleted rather than moved to `old_patches` can be found in the subversion
history using a subversion client.

### Linking to pre-built static libraries

With Rtools40, some R packages used to download external static libraries
during their installation from "winlibs"/"r-winlib" or other sources.  When
these downloaded libraries were built for MSVCRT (incompatible with UCRT),
one got linking errors.

A common symptom was  undefined references
to various symbols, often  `__imp___iob_func`, `__ms_vsnprintf` or
`_setjmp`. Downloading
of external code is usually obvious from `src/Makevars.win` (e.g. presence
of "winlibs" or from `configure.win`) and from installation outputs.

These symptoms will be seen again when one accidentally links an
incompatible library built for MSVCRT.  To fix this, one needs to instead
build against libraries built for UCRT.  While libraries built for UCRT may
become available for download, it is not a good idea downloading them during
package installation and see [CRAN Repository
Policy](https://cran.r-project.org/web/packages/policies.html) for
restrictions on CRAN.

For transparency, source packages should contain source (not executable
code).  Using pre-compiled libraries may lead to that after few years the
information on how they were built gets lost or significantly outdated and
no longer working.  Using older binary code may provide insufficient
performance (newer compilers tend to optimize better).  Also, the CRAN (and
Bioconductor) repositories are used as a unique test suite not only for R
itself but also the toolchain, and by re-using pre-compiled libraries, some
parts will not be tested. Compiler bugs are found and when fixed, the code
needs to be re-compiled. Finally, object files (and hence static
libraries, particularly when using C++) on Windows tend to become
incompatible when even the same toolchain is upgraded.  Going from MSVCRT to
UCRT is an extreme case when all such code becomes incompatible, and adding
support to 64-bit ARM would be another extreme case, but smaller updates of
different parts of the toolchain or even some libraries in it lead to
incompatibilities. The issues mentioned here are based on experience with
the transition to UCRT and Rtools42; all of these things have happened and
dealing with the downloads and re-use of static libraries was one of the
biggest challenges.

As an example of the necessary updates to move from downloading of
pre-compiled static libraries, package `tiff` used to have in
`src/Makevars.win`:

```
RWINLIB = ../windows/libtiff-4.1.0/mingw$(WIN)
PKG_CPPFLAGS = -I$(RWINLIB)/include
PKG_LIBS = -L$(RWINLIB)/lib -ltiff -ljpeg -lz

all: clean winlibs

winlibs:
        "${R_HOME}/bin${R_ARCH_BIN}/Rscript.exe" "../tools/winlibs.R"
```

To make the package build with UCRT and Rtools42, one could
replace these lines by:

```
PKG_LIBS = -ltiff -ljpeg -lz -lzstd -lwebp -llzma 
all: clean 

```

Note that even Rtools4 has these libraries, so one could make a similar
change also for building the package with Rtools4 (even for MSVCRT, so avoid
downloading pre-compiled libraries).

However, the same set and ordering of libraries often does not work with
Rtools4, because the names would sometimes be different (in some cases,
though, it is still possible to create a linking order that works with both
Rtools42 and Rtools4, when libraries are available in both under the same
name).

So, typically, a new Makevars file is needed, and R 4.2 added support for
`Makevars.ucrt` for that, which are used in preference of `Makevars.win`,
when present.  See Writing R Extensions] for more information about support
for `configure.ucrt`, `cleanup.ucrt`, `Makefile.ucrt` and `Makevars.ucrt`
files. Packages meant and specified to work only with R 4.2 and newer should
use the traditional `.win` suffixes with the new content.

### Multiple definitions of symbols

Another common issue observed with the new toolchain were linker errors about
multiply defined symbols.  GCC 10 is stricter about the use of tentative
definitions (global variables defined without an initializer) than earlier
versions, which allowed merging of tentative definitions by the linker by
putting them into a single "common" block.
 
With GCC 10, and earlier version with `-fno-common`, this merging does not
happen and one instead gets the linker error.  A quick hack is to build with
`-fcommon` to still use the common block, and this is also a reliable way of
detecting the cause of the problem. See
[Writing R Extensions](https://cran.r-project.org/doc/manuals/r-release/R-exts.html#Common-symbols)
for more details.

### Other issues

Other problems faced already included missing external libraries (MXE
configurations need to be added, as described below), external libraries
built in a way unexpected by the package or in an unexpected version (e.g. 
HDF5), headers stored in different directories (note `R_TOOLS_SOFT` variable
is set to the root of the toolchain, so `$(R_TOOLS_SOFT)/include` is added
automatically and subdirectories may be added explicitly), explicit setting
of Windows target version (`_WIN32_WINNT`).  Posix thread-safe functions are
only available when `_POSIX_THREAD_SAFE_FUNCTIONS` macro is defined.

Most of the issues have been resolved before the release of R 4.2 in
packages on CRAN and Bioconductor repositories, but similar issues may
re-appear when creating new packages from older code.

## Building the toolchain and libraries from source

The toolchain and libraries are built using a modified version of
[MXE](https://mxe.cc/), which is available
[here](https://svn.r-project.org/R-dev-web/trunk/WindowsBuilds/winutf8/ucrt3/toolchain_libs/mxe). 
The build is run on an x86_64 Linux machine, so it involves building a
GCC10/MinGW-W64/UCRT cross-compilation toolchain, cross-compiling a large
number of libraries needed by R and R packages, and then building also a
native compiler toolchain so that R and R packages can be built natively on
Windows.

Scripts for setting up the build in docker running Ubuntu, Debian or Fedora are
available
[here](https://svn.r-project.org/R-dev-web/trunk/WindowsBuilds/winutf8/ucrt3/toolchain_libs/).
However, this is easy enough and convenient to run natively. On Ubuntu
20.04, following the [MXE documentation](https://mxe.cc/#requirements-debian),
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
    python3 \
    python3-mako \
    python3-setuptools \
    python \
    ruby \
    sed \
    unzip \
    wget \
    xz-utils
```

And then also install these:

```
apt-get install -y texinfo sqlite3 zstd
```

For Fedora distributions, see the script `build_in_docker.sh` for the
required dependencies. Please refer to the script for any updates to the
list of packages shown above also for Debian/Ubuntu.

If you wish to do everything from scratch, run `make` (or `make -j`)  in
`mxe` (see the next section for how to re-use pre-compiled binaries to
reduce the time needed).
The build takes about 2 hours on a server machine with 20 cores, so
don't expect that to be fast, but then building individual MXE packages
(new, modified) is fast as the build is incremental using `make`.  It has
been reported that 8G of RAM and two cores is enough for the build.  Even a
full re-build is reasonably fast as MXE uses ccache.

The result will appear in `mxe/usr`, the native toolchain and libraries
specifically in `mxe/usr/x86_64-w64-mingw32.static.posix`. The content of
that directory is currently just packed into a tarball available as
e.g. `rtools42-toolchain-libs-full-4354.tar.zst`
[here](https://cran.r-project.org/bin/windows/Rtools/rtools42/files/),
with some filtering to reduce the size.

The rest of `mxe/usr` is then packed into a tarball available
as e.g. `rtools42-toolchain-libs-cross-4354.tar.zst`, as it contains the
cross-compilation toolchain.

The toolchain is now regularly built in a docker container using the
provided script. One of the advantages is that it is easier to ensure that
absolute paths (some files use them, see below) are set up properly, but for
experimentation and development, it is easy to work natively on Linux.

By default, `make` builds the full toolchain. This is controlled by make
variable `R_TOOLCHAIN_TYPE`, so to build the (smaller) base toolchain, run

```
make -j R_TOOLCHAIN_TYPE=base
```

## Setting up MXE build from pre-built tarballs

To save the time of building the full toolchain from scratch, e.g.  when the
goal is to create a new MXE package or upgrade an existing one, one might
re-use the pre-compiled code already distributed in the full and the
cross-compiler toolchain tarball.  This requires root access to the machine
(to create a symlink, indeed one may do this in docker) and is not regularly
tested as Rtools built tree is normally started from scratch.

With the current/given version number of Rtools42, here we assume it is
5164, one can proceed as follows:

```
svn checkout -r 5164 https://svn.r-project.org/R-dev-web/trunk/WindowsBuilds/winutf8/ucrt3/toolchain_libs/mxe
cd mxe
wget
https://cran.r-project.org/bin/windows/Rtools/rtools42/files/rtools42-toolchain-libs-cross-5164.tar.zst
wget https://cran.r-project.org/bin/windows/Rtools/rtools42/files/rtools42-toolchain-libs-full-5164.tar.zst

mkdir usr
cd usr
tar xf ../rtools42-toolchain-libs-cross-5164.tar.zst
tar xf ../rtools42-toolchain-libs-full-5164.tar.zst
cd ..

MXE_ROOT=`pwd`/usr
sudo mkdir /usr/lib/mxe
sudo ln -s $MXE_ROOT /usr/lib/mxe #

make ccache

make -j MXE_BUILD_DRY_RUN=1
make -j MXE_BUILD_DRY_RUN=1 # repeat until [pkg-list] is last line of output
rm `find usr -name "*.dry-run"`

make -j # a check that nothing is built

```
The "make ccache" step will build the compiler cache tool and create native
C/C++ and cross compilers as links to it. The compiler cache will speed up
repeated compilations.

The "dry run" will download all source packages (about 1G at the time of
this writing) and it will create as a side effect also time-stamps telling
MXE that the packages have already been built. The command needs to be
repeated twice (or more times, if there are intermittent download failures)
until the output looks like this (nothing downloaded, no "[dry-run]"):

```
fatal: not a git repository (or any of the parent directories): .git
Building full R toolchain
[pkg-list]  # long list of packages in the list

```

Please note that errors about failed downloads will be displayed even when
the package is later sucessfully downloaded from a backup location. The best
way to see all has been downloaded correctly is to keep repeating the
command as suggested.

The time-stamps are necessary, the downloading isn't (and one probably could
easily comment out that part in Makefile if needed, but there doesn't seem
to be an obvious elegant solution).

One can then check that MXE knows/thinks that all packages are up to date
simply by running

```
make -j
```

Which should take a few seconds only to figure out that nothing is needed,
so again "[pkg-list]" should be the last line of output.

Please note that this does not create a completely identical output to
building from scratch.  It does not include some files excluded from Rtools
to limit size (test executables, executables not needed by R packages).  It
does not re-create symlinks but instead has file copies as this is how the
tarballs are created to be Windows-friendly.  But it should be enough for
most use cases.

Now one can use the dependencies in make file to rebuild only what is
needed, e.g. running

```
touch src/libxml2.mk
make -j
```

rebuilds XML library and all packages that depend on it (note: expect this
to take about 15 minutes on a server machine when ran the first time, the
second run would be faster because of ccache).

## Adding/updating an MXE package

Some R packages cannot be built or don't work, because they depend on an
external library not available in the toolchain. To add such
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

When maintaining open-source software distributions, often one may take
inspiration from somewhere else.  First, many packages are already available
in MXE; if they just work, they only need to be added to `settings.mk`. 
Still, a number of packages had to be adapted or upgraded to build with
UCRT.  Then, some packages may be available in a similar customized version
of MXE used by Octave, [MXE-Octave](https://wiki.octave.org/MXE).  Then some
packages popular in the R community but not present in MXE may be available
in [Msys2](https://github.com/msys2/MINGW-packages) or
[Rtools4](https://github.com/r-windows/rtools-packages), yet those package
configurations are in a different format and not written for
cross-compilation nor static linking.  Linux distributions, e.g.  Debian,
then have much bigger selection of build configurations of packages, again
in a different format.

If your package needs a library not currently supported by the modified
version of MXE used to build in this toolchain, you are welcome to provide a
build configuration for such library. Primarily, such package
configuration would be contributed directly to upstream MXE, which may be a
forcing function to test such package in a wider context (e.g. also
dynamic linking, also MSVCRT, etc), but a much wider group of users will be
able to benefit from that. Also, it would reduce the maintenance overhead
of the toolchain.

## Establishing the linking order from existing patches

As noted above, R packages on Windows need to explicitly specify a linking
order, ordered names of libraries to link to the package.

## (Not) establishing the linking order in R packages via pkg-config

This section may be skipped by those looking only for instructions to
follow.

The linking order can be obtained via `pkg-config`. On the 
cross-compilation host (Linux) one may run

```
env PKG_CONFIG_PATH=usr/x86_64-w64-mingw32.static.posix/lib/pkgconfig ./usr/x86_64-pc-linux-gnu/bin/pkgconf --static libtiff-4 --libs-only-l
```

to get `-ltiff -lwebp -lzstd -llzma -ljpeg -lz`, a correct linking order
which may be added to the package `src/Makevars.ucrt` (`src/Makevars.win`)
for package tiff.  One still has to figure out that the pkg-config package
name is `libtiff-4` (the MXE package is `tiff`, the Rtool4 package is
`libtiff`), so this would not allow a completely automatic computation on
its own.

Worse still, `pkg-config` does not always provide a working linking order.
For example, for `opencv`, at the time of this writing (running on Linux),

```
env PKG_CONFIG_PATH=usr/x86_64-w64-mingw32.static.posix/lib/pkgconfig ./usr/x86_64-pc-linux-gnu/bin/pkgconf --static opencv4 --libs-only-l
```

gives

```
-lopencv_highgui451 -lopencv_ml451 -lopencv_objdetect451 -lopencv_photo451 -lopencv_stitching451 -lopencv_video451 -lopencv_calib3d451 -lopencv_features2d451 -lopencv_dnn451 -lopencv_flann451 -lopencv_videoio451 -lopencv_imgcodecs451 -lopencv_imgproc451 -lopencv_core451 -llibopenjp2 -lquirc -lprotobuf -lcomctl32 -lgdi32 -lole32 -lsetupapi -lws2_32 -ljpeg -lwebp -lpng -lz -ltiff -lzstd -llzma -lopengl32 -lglu32
```

which does not work, it is not enough.  One has to add
`-L$(R_TOOLS_SOFT)/lib/opencv4/3rdparty` so that `-llibopenjp2 -lquirc` are
found.

`R_TOOLS_SOFT` is set to the root of the compiled native toolchain,
`R_TOOLS_SOFT`/include is automatically available for headers,
`R_TOOLS_SOFT`/lib is automatically available for libraries, but when one
needs to refer to files in different locations or for different tools, one
may have to use that variable.

There is also `LOCAL_SOFT` variable which by default points to the root of
the compiled toolchain and in some CRAN packages has been used for this
purpose (well before this toolchain existed).  However, the original idea of
`LOCAL_SOFT` was to use it for libraries not available with the toolchain,
like `/usr/local` is used on Unix machines to refer to software not part of
the OS distribution.  It is hence more portable to use `R_TOOLS_SOFT` for
the purpose of referring to the libraries/headers which are part of the
toolchain.

Going back to the list of libraries obtained by pkg-config for opencv, this
list is not complete, a number of dependencies are missing (`webp` is one of
them).  In principle, this is a common problem that `pkg-config`
configurations are not thoroughly tested with static linking.

Packages hence should not use `pkg-config` directly in their make files, but
in some cases, it may give a hint/starting point when establisthing the
linking order. In Rtools42 (so running on Windows), one may install
`pkg-config` and get the libraries for `opencv` as follows:

```
pacman -Sy pkg-config
env PKG_CONFIG_PATH=/x86_64-w64-mingw32.static.posix/lib/pkgconfig pkg-config --static opencv4 --libs-only-l
```

But, again, they don't work. Installing pkg-config should definitely not be
done from R packages: the tool will be added to Rtools when the package
databases are fixed for static linking.

## Computing linking orders (background)

This section may be skipped by those looking only for instructions to
follow.

R on Windows uses static linking.  Static libraries are just archives of
object files, without any references to other static libraries they may need
as dependencies.  The linker keeps track of the currently undefined symbols
and goes through the list of libraries (so archives of object files) from
left to right.  If an object file from a library defines a symbol that the
linker knows is undefined, the linker will add that object file to the
binary.  It will then add any additional object files from the same library
which define any undefined symbols arising from the same library, but it
will not add other object files from that library.  This may result in that
new symbols would become undefined after processing that library.  These
symbols have to be defined by some of the additional libraries in the list.

For this to work, one needs to make sure that any time one library uses a
symbol from another library, it is processed earlier by the linker.  This is
a problem when there is a loop of dependent libraries, however, one can
usually resolve that by adding some libraries multiple times to the list or
moving some library in the list, taking advantage of the mechanism described
above: only the object files with some currently needed symbols are added
from the library.

The GNU linker also allows to specify linking groups, within which linking
is repeated in the given order re-starting until all symbols are resolved
(see `--start-group` and `--end-group`), with a price in performance.  This
feature has not been needed yet in Rtools42.

Symbols exported from object files and actually missing at linking time are
mostly unique in Rtools42.  Non-unique are some inlined
C++ functions (but then they are not missing at linking time), alternative
implementations (e.g.  parallel OpenBLAS, serial OpenBLAS, reference BLAS),
runtime library wrappers (but they are not missing at linking time).  As
these exceptions are rare, it was possible to come up with a simple tool
which can reasonably well advice on the list and order of libraries to link,
with heuristics to resolve some edge cases.

Traditionally, this is done in Unix using `lorder` script and `tsort`. 
`lorder` generates a list of dependencies between static libraries,
defensively assuming that all object files from those libraries are needed. 
`tsort` establishes a topological ordering on the result of `lorder`.  One
can just try to build an R package without linking any libraries, parse the
output from the linker looking for undefined symbols, find static libraries
providing such symbols, and establish the topological ordering.  The
resulting linking order can be then added to the `src/Makevars.ucrt`
(`src/Makevars.win`), the build of the R package tried again, generating
another list of undefined symbols.  Then one can merge the list of libraries
established previously with the list established now, do the topological
sort again, and iterate this way until linking succeeds. `findLinkingOrder`
does this, with some additional heuristics, as shown below.

This is how linking orders for most patched CRAN packages were obtained, but
thorough testing is needed to figure out whether they produce a working
package.  In principle, a better tool could definitely make this process
faster and more automated, and not requiring manual iterative linking
attempts.

Some manual adaptations to the linking orders created that way were needed,
anyway, and probably always will.  These included resolving loops (`tsort`
gives warning when it sees them, which is a hint) by shifting libraries in
the ordering and adding some twice.  Also, some symbols are not completely
unique in the toolchain and the semi-automated process did not choose the
best library (e.g.  `libmincore` and `libwindowsapp` should not be linked,
because they depend on console Windows DLLs which are not present on Windows
Server). `-lsbml-static` should be used instead of `-lsbml.dll` (the latter
is an import library for a DLL, not a static library with the code per se).

None of this should be needed if the `pkg-config` databases were fixed to
work reliably with static linking.  That could be done via improving MXE
package configurations, but the effort required may be bigger than improving
a hint tool described above, but if fixed, the results could be more
reliable.  One still would need to know the right names of the pkg-config
packages, which are distribution specific.

Note that similar problems with other toolchains may be hidden when
pre-built (bigger) static libraries are being downloaded during package
installation.

## Using findLinkingOrder with Rtools42 (tiff package example)

In the end all the linking orders in patches for CRAN and Bioconductor
packages mentioned above were established via computation over the
compiled static libraries as described above, based on which
`findLinkingOrder` has been created.

This example uses Rtools42 and binary build of R. Run Rtools42 shell (Msys2
bash), download and extract the source package `tiff`. Create a temporary
`Makevars.ucrt` file as follows:

```
PKG_LIBS = -Wl,--no-demangle $(shell cat /tmp/tiff.libs)
```

Get the `findLinkingOrder` tool

```
svn checkout https://svn.r-project.org/R-dev-web/trunk/WindowsBuilds/winutf8/ucrt3/linking_order
```

Run the tool, specifying the file to hold the found linking order:

```
./linking_order/findLinkingOrder tiff /tmp/tiff.libs
```

First time, it will take long as it will be creating an index of the
libraries. The end of the output is:

```
Installation failed, trying to find required link order
 -ltiff

Saved in /tmp/tiff.libs
```

Which means, that the linking was not successful (indeed, we provided no
libraries), but we know that the directly missing symbols will be satisfied
by `-ltiff`, which was automatically added. So lets simply run the tool
again:

```
./linking_order/findLinkingOrder tiff /tmp/tiff.libs
```

The output now ends with:

```
Installation failed, trying to find required link order
-ltiff -lzstd -lz -lwebpdecoder -lwebp -llzma -ljpeg -lcfitsio

Saved in /tmp/tiff.libs
```

Which means that `-ltiff` was not enough, but there is an extended
suggestions. Lets run the tool the same way again. The output ends with

```
Installation succeeded!
```

Which means the list of libraries is complete. So now we can modify the
`Makevars.ucrt` using the computed list of libraries:

```
PKG_LIBS=-ltiff -lzstd -lz -lwebpdecoder -lwebp -llzma -ljpeg -lcfitsio
```

The `-Wl,--no-demangle` option is removed, because it is only needed for the
tool (and only for code using C++).

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
API call (to `LoadLibrary`), which is the case when loading DLLs of R
packages, Windows is unable to say which DLL is missing:


```
Error: package or namespace load failed for 'magick' in inDL(x, as.logical(local
), as.logical(now), ...):
 unable to load shared object 'C:/msys64/home/tomas/ucrt3/svn/ucrt3/r_packages/r
inst/library/00LOCK-magick/00new/magick/libs/x64/magick.dll':
  LoadLibrary failure:  The specified module could not be found.
```

Note: in the above, `magick.dll` is present on the path listed.  It is some
of its dependencies that is not found, but Windows would tell which one. 
The confusing error message comes directly from Windows and R cannot
possibly fix that.

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

The flag can be removed using `-sls`. Note that the Msys2 console (mintty
with bash, by default) is very different from cmd.exe in Windows: the latter
uses a different API and e.g. sometimes shows more debugging messages,
etc. It is better to use cmd.exe when debugging (with `WinDbg` but also
gdb). One may use `gdb` from Msys2 with this toolchain the same way as with
Rtools4.

## Native building of external applications: JAGS

R packages are sometimes linked against dynamic libraries installed by
external applications. It may become necessary to rebuild such libraries as
well to be built for UCRT. It is advisable for encodings to be handled
properly (yet that depends on how that library handles encodings), but it
may be the least inconvenient solution also to avoid other clashes between
runtimes, such as in memory allocation.

[JAGS](http://mcmc-jags.sourceforge.net/) (Just Another Gibbs Sampler) is
used by R package rjags and some other packages.  JAGS is installed as a
standalone application via its interactive installer and includes shared
libraries (JAGS library and a number of modules) and C headers.  R packages
at build time use those C headers and link against that JAGS shared library.

When R package rjags is built with Rtools42 and linked against the JAGS
library from the official JAGS 4.3.0 distribution, it does not work.  The
linking of the R package library is successful, but building of the package
indices fail, unfortunately without any detailed error message.  The problem
is that building of package indices already involves loading the rjags
package and running it, and that crashes because of C runtime mismatch, the
JAGS library built for MSVCRT ends up calling UCRT free function on an
object allocated using MSVCRT.

There is now an official distribution of
[JAGS 4.3.1](https://sourceforge.net/projects/mcmc-jags/files/JAGS/4.x/Windows/JAGS-4.3.1.exe)
for UCRT, which needs to be used with R >= 4.2 on Windows instead of JAGS
4.3.0. The following text contains instructions which were used before to
create an unofficial JAGS build using Rtools42, which may still be useful as
inspiration for building other applications.

The script used to create the unofficial build is available
[here](https://svn.r-project.org/R-dev-web/trunk/WindowsBuilds/winutf8/ucrt3/extra/jags).

JAGS uses `configure`, but when running in Msys2, the host system
identification is different from what the MXE-built toolchain has, so some
utilities (but not all) are not detected correctly.  `configure` has to be
run with `--host=x86_64-w64-mingw32.static.posix`.

Futhermore, as documented in JAGS installation manual, JAGS uses libtool and
libtool will not link a static library to a shared library created as
"module".  This causes trouble for some JAGS modules, such as "bugs", which
link against LAPACK and BLAS.  The Rtools42 includes static libraries for
reference LAPACK and BLAS, but libtool refuses to link them (also, they
don't have `.la` files).

This can be solved by building wrapper dynamic libraries for these static
LAPACK and BLAS libraries, following instructions from the JAGS manual, with
the toolchain on PATH (as when building R and packages):

```
export TLIB=~/svn/ucrt3/r/x86_64-w64-mingw32.static.posix/lib
dlltool -z libblas.def --export-all-symbols $TLIB/libblas.a
gfortran -shared -o libblas.dll -Wl,--out-implib=libblas.dll.a libblas.def $TLIB/libblas.a
dlltool -z liblapack.def --export-all-symbols $TLIB/liblapack.a
gfortran -shared -o liblapack.dll -Wl,--out-implib=liblapack.dll.a liblapack.def $TLIB/liblapack.a  -L. -lblas
SHAREDLB=`pwd`
```

One can then provide these libraries to JAGS configure via
`-with-blas="-L$SHAREDLB -lblas" --with-lapack="-L$SHAREDLB -llapack"`, where
`$SHAREDLB` is the directory with `liblapack.dll` and `libblas.dll`.  These two
DLLs have to be then copied into the JAGS build tree before running the
installer:

```
./configure --host=x86_64-w64-mingw32.static.posix --with-blas="-L$TLHOME -lblas" --with-lapack="-L $TLHOME -llapack"
make win64-install
cp $TLHOME/libblas.dll $TLHOME/liblapack.dll win/inst64/bin
make installer
```

But, before running `make installer`, one needs to fix the installer script
for 64-bit-only build. The original installer supported both 32-bit and
64-bit architecture, but R on Windows since R 4.2 and Rtools42 only supports 64-bit.
The patch is available with the build script,
[here](https://svn.r-project.org/R-dev-web/trunk/WindowsBuilds/winutf8/ucrt3/extra/jags).

## Native building of external libraries: Nlopt

Nlopt is included in Rtools42, so it does not have to be built for use with
R packages (and it shouldn't be according to CRAN repository policy, because
it is available in the system). But it can be built in Rtools42 simply
as follows (version
[2.7.1](https://github.com/stevengj/nlopt/archive/v2.7.1.tar.gz)):

```
export PATH=/x86_64-w64-mingw32.static.posix/bin/:$PATH
tar xf v2.7.1.tar.gz
mkdir build
cd build
cmake ../nlopt-2.7.1 -DBUILD_SHARED_LIBS=OFF -DNLOPT_PYTHON=OFF \
      -DNLOPT_OCTAVE=OFF -DNLOPT_MATLAB=OFF -DNLOPT_GUILE=OFF \
      -DNLOPT_SWIG=OFF
cmake --build .
```

CMake is part of the toolchain (so built by MXE) and is patched to use Unix
Makefiles as the default generator.

## Cross-compilation of external applications: Tcl/Tk (configure)

R is distibuted with a binary build of Tcl/Tk (aka "Tcl/Tk bundle"), which is
needed for the `tcltk` package and can be used from R, but also can be used
externally.  Since R 4.2, the bundle is cross-compiled on Linux and only
supports 64-bit builds, as does R 4.2. The current version is 8.6.12.
Traditionally the bundle includes TkTable and BWidget.

Scripts used to build the bundle are available in subversion
[here](https://svn.r-project.org/R-dev-web/trunk/WindowsBuilds/winutf8/ucrt3/tcl_bundle).

One needs first to download the toolchain tarball, a file named such as
rtools42-toolchain-libs-base-5038.tar.zst from Rtools42, available
[here](https://cran.r-project.org/bin/windows/Rtools/rtools42/files/). This
tarball includes the libraries and headers, which are needed, and the native
compiler toolchain, which is not. We also need to download the
cross-compiler tarball, a file named such as
rtools42-toolchain-libs-cross-5038.tar.zst.

These should be extracted in the same directory, `/usr/lib/mxe/usr` (or a
directory simlinked from there), e.g.

```
cd /usr/lib/mxe/usr
tar xf rtools42-toolchain-libs-base-5038.tar.zst
tar xf rtools42-toolchain-libs-cross-5038.tar.zst
```

and the cross-compiler needs to be put on PATH

```
export PATH=/usr/lib/mxe/usr/bin:$PATH
```

The concrete commands can be found in the script and the bundle had to be
patched to build successfuly with this version of GCC and UCRT, but a
general rule applicable to also other software is that one again needs to
specify the host and target, `x86_64-w64-mingw32.static.posix` (this
identification is used by MXE), so e.g. 

```
BINST=`pwd`/Tcl
./configure --enable-64bit --prefix=$BINST --enable-threads --bindir=$BINST/bin --libdir=$BINST/lib --target=$TRIPLET --host=$TRIPLET
```

is used to configure Tcl.

## Cross-compilation of external libraries: Nlopt (cmake)

Similarly to the native compilation of Nlopt, one can also cross-compile it
(again, please note this is just an example, as Nlopt is already present in
Rtools42).  Set up the cross-compiler as for Tcl/Tk, but in addition create
links for the cross-compilers to be found by cmake.

```
cd /usr/lib/mxe/usr
ln -st x86_64-pc-linux-gnu/bin \
  ../../bin/x86_64-w64-mingw32.static.posix-gcc \
  ../../bin/x86_64-w64-mingw32.static.posix-g++
```

Alternatively, see the section on "Setting up MXE build from pre-built tarballs"
for how to set up compiler cache for the cross-compilers instead of those
links.

Once this is done, build NLopt as follows:

```
export PATH=/usr/lib/mxe/usr/bin:$PATH
tar xf v2.7.1.tar.gz
mkdir build
cd build
x86_64-w64-mingw32.static.posix-cmake ../nlopt-2.7.1 \
      -DBUILD_SHARED_LIBS=OFF -DNLOPT_PYTHON=OFF \
      -DNLOPT_OCTAVE=OFF -DNLOPT_MATLAB=OFF -DNLOPT_GUILE=OFF \
      -DNLOPT_SWIG=OFF
cmake --build .
```

## Versioning of the Rtools42 components

At the time of this writing, the Rtools42 files available [here](https://cran.r-project.org/bin/windows/Rtools/rtools42/files/)
are:

```
rtools42-5038-5046.exe
rtools42-toolchain-libs-base-5038.tar.zst
rtools42-toolchain-libs-cross-5038.tar.zst
rtools42-toolchain-libs-full-5038.tar.zst
tcltk-5038-5090.zip
```

In the above, 5038 is the version of the toolchain. 5046 is the version of
scripts used to build the Rtools42 installer. 5090 is the version of scripts
used to build the Tcl/Tk bundle.

The version of the toolchain is also store in file
`x86_64-w64-mingw32.static.posix/.version` in all the toolchain
distributions and Rtools42.

These versions correspond to subversion releases of these subversion
directories for the toolchain, the rtools installer, and the Tcl/Tk bundle:

```
https://svn.r-project.org/R-dev-web/trunk/WindowsBuilds/winutf8/ucrt3/toolchain_libs
https://svn.r-project.org/R-dev-web/trunk/WindowsBuilds/winutf8/ucrt3/rtools
https://svn.r-project.org/R-dev-web/trunk/WindowsBuilds/winutf8/ucrt3/tcl_bundle
```

Please note that to be able to fully reproduce the builds, one also needs
exactly the same versions of external software (both executables but also
source code for all open-source software that is built into the toolchain
libraries).  The repositories shown have docker scripts to ensure that the
exact versions used are recorded and the process is reproducible from
scratch.  Also, MXE uses backup download locations for software libraries. 
However, in case of interest in fully reproducing the builds, it is adviced
to do that rather soon, when the external software will most likely still be
downloadable, and keep copies for later use.
