---
title: "Supporting UTF-8 (and building R) on Windows"
author: Tomas Kalibera
output: html_document
---
## Introduction

In R (4.0 and earlier), it is not possible to set UTF-8 as the current
native encoding in R on Windows.  This causes issues when working with
characters not representable in the current native encoding, which can lead
to a runtime error and warnings, non-representable characters may be quoted
using various escapes, replaced by a similarly looking representable
character, replaced by a question mark, deleted, etc.

R has been trying to solve this by various "shortcuts": during some
operations it can work directly with UTF-8 without intermediate conversion
to native encoding.  Yet, it is not possible to reliably cover all cases
without rewriting R, and then we would still have all the external software
R depends on.  The core of the problem is that Windows just could not set
UTF-8 as the encoding of the current locale for decades.  On Unix systems
and macOS, this has been possible for years and R has no problems working
with UTF-8 strings on these systems.

Windows 10 made this finally possible, too.  For R to use this new feature,
not much has to be changed in the R source code, but unfortunately we need
to change how we are building R and R packages.  We need a new toolchain,
newer than RTools 4, and all packages and their dependencies have to be
re-built from source - not a single static library nor object file left
around from the past can be reused.

This document provides explains this in more detail and introduces an
experimental "toolchain" (in the terminology of the following sections, it
is a compiler toolchain and external libraries, but not build tools) that
allows to use UTF-8 on recent versions of Windows 10.  Also, R has been
modified to accept UTF-8 as the current encoding also on Windows.

This experimental toolchain serves as a demonstration of this way to support
UTF-8 on Windows.  It may be used for experimenting with packages, for
testing packages "in advance", but not for real/production work: it does not
support all necessary libraries, it includes new and unstable versions of
software, some build issues were not solved in a proper way, and it has not
been well tested.

## Background on encoding support in Windows

In R, the current native encoding is also the current locale of the C
library.  It is the encoding set via C's `setlocale()` function, and that is
what is normally done in portable applications.

On Windows, there are two problems with this.  First, the Windows C runtime
(C library) did not support UTF-8 as the current encoding.  It only
supported single-byte encodings and some double-byte encodings, but not
multi-byte encodings and specifically not UTF-8.

Another problem is that Windows has multiple "current encodings" at a time,
it is not just the encoding understood by the C runtime, but also the system
code page understood by the operating system.  The system encoding is used
in Windows API calls, e.g.  when listing a directory, the result will be
encoded in the system encoding.  Normally, these two encodings should be the
same and often they are almost the same, but not always.  This is especially
tricky when such Windows API calls are wrapped and one does not expect
results in the system encoding.  Windows did not support UTF-8 as the system
encoding, either.

Windows applications that needed to support all (or almost all) Unicode
characters at a time had to be written in a special, non-portable way.  They
needed to use wide characters, which are defined by the C standard, but not
in much detail (they don't have to use any Unicode encoding).  Moreover,
programs had to bypass the C library and call the Windows API directly,
using the wide-character variants of the Windows API, hence increasing the
amount of platform-specific code.

Initially, the encoding on Windows was UCS-2, but now it is UTF-16LE, so it
is also a variable-length encoding (as UTF-8), and there is probably no
single benefit in using it.  Except perhaps for applications intended to be
Windows-only, because one avoids conversions by having all strings in UTF-16
all the time, because Windows internally use UTF-16.  R did not go that path
and probably couldn't, as it uses so much external software that did not go
that path, either.

Instead, R internally allows strings to be in different encodings, not just
in the current native encoding, but also in "latin1" or "UTF-8"; CHARSXPs
can be in multiple encodings with appropriate flags set.  More information
is available in [R Internals](https://cran.r-project.org/doc/manuals/r-release/R-ints.html#Encodings-for-CHARSXPs),
in [Writing R Extensions](https://cran.r-project.org/doc/manuals/r-release/R-exts.html)
and in the R help system.  Hence, R supports UTF-8 strings even on Windows,
the problem is "just" that when calling into external software or the C
library the strings have to be converted to the native encoding.

Sometimes the conversion in R was done slightly prematurely and some of
these cases were handled via shortcuts (such as when reading a file in UTF-8
or when parsing), which however have complicated the semantics for users, it
made it harder to maintain the source code, and it could not solve the
problem completely: strings sometimes needed to be passed to Windows or
external software.  In the past, though, there was no practical alternative. 
Also, conversion works fine as long as the characters can be represented in
both encodings, and that was often true, though lately reports when users
run into non-representable characters are common.

The only realistic solution is to use UTF-8 as the native encoding.  With
Windows 10 it is finally possible.

It is possible to use UTF-8 as the system code page (system encoding).  This
has been first announced as a BETA option that allowed to set it for the
whole system and required a reboot.  Later, a better way has been
added/documented: one can specify in a manifest of a Windows application
that it wants to use UTF-8.  It turns out that this option also changes the
C runtime current encoding to UTF-8, but only when that is supported by the
C runtime (so not in MSVCRT, and it seems not in older UCRT, either -
details later in this text).  In addition to that, with UCRT the C runtime
current encoding can be also set to UTF-8 via setlocale() function, as it
should.

The key caveat for R and a lot of open-source applications is the
requirement for UCRT. That requires a new toolchain and a rebuild of all
external code.

## Background on building R

To build R on Windows, one needs a *compiler toolchain* and *build tools* to
build R and external *libraries* needed by packages.  Previous sections of
this text and many from the R community refer to all these three things as a
toolchain, but this text tries further to maintain the distinction.

### Compiler toolchain

The compiler toolchain needs to include a compiler for C and Fortran, for
packages also a compiler for C++ and then the necessary runtime libraries
and binutils (linker, archiver, objdump, etc).  The toolchain needs to
include *MinGW* in the form of headers and static libraries to build
applications with.  Traditionally R uses GCC, Clang would probably work as
well after minimal effort, but GFortran is needed anyway (LLVM does not have
a mature Fortran compiler yet), so it is easier to use GCC to compile C as
well.

MinGW is an implementation of some Posix functionality on Windows and it
also includes headers for Windows API functions and C runtime functions. 
The level of emulation Posix provided by MinGW is sufficient for R and for
libraries needed by R and packages.  MinGW is linked statically, so the
resulting DLLs and binaries appear and can be used as the usual Windows
binaries.  This text for simplicity and with apologies to the authors refers
to MinGW even when it is in fact already its fork, MinGW-w64.  Originally, R
used the original MinGW project (32-bit builds), but for about the last 8
years it has been using MinGW-W64 and providing both 32-bit and 64-bit
builds. Wikipedia has information on history of both of the projects
([MinGW](https://en.wikipedia.org/wiki/MinGW) and
[MinGW-w64](https://en.wikipedia.org/wiki/Mingw-w64)).

R usually tries to use functions normally available on Windows without
MinGW, so the direct dependence on the Posix emulation may not be very high. 
Also, in the past R has been even experimentally built with MSVC.  On the
other hand, libraries used by R packages depend on the Posix emulation
heavily, so in practice MinGW is necessary.

On Windows, the C runtime is historically compiler-specific and even
specific to MSVC compiler version, including file access or heap allocation,
to the point that memory allocated by one version of the runtime cannot be
freed by another.  DLLs are expected to be designed with this in mind: never
pass handles to files, always provide functions to free memory if they
return pointers to allocated memory, etc.  Object files, including static
libraries, built by compilers using different C runtimes cannot be linked
together at all.  Upgrading a compiler then means "rebuild everything from
scratch", at least at the boundary of a DLL.

MinGW/software distributions have decided to solve it by using the oldest
version of MSVCRT always as a common denominator and common interface to
avoid these issues.  Microsoft sometimes fixed things inside this old MSVCRT
without changing the interface, but primarily it adds new things and
improvements always to the latest version.  Traditionally, R uses MSVCRT
with MinGW, so far in all binaries provided by CRAN.

However, Microsoft recently came up with a new C runtime named UCRT which
finally implements in one common runtime what should be compiler
independent, as it has been historically in Unix systems (including file
access and heap allocation).  UCRT also gets new features, notably finally
one can set UTF-8 as the current native encoding of the C runtime/library.
More information on UCRT can be found in a 
[blog post](https://devblogs.microsoft.com/cppblog/introducing-the-universal-crt/),
its [continuation](https://devblogs.microsoft.com/cppblog/introducing-the-universal-crt/)
and in Microsoft documentation.

MinGW already supports UCRT and R-devel can be built with it, but thorough
testing is needed and experiments with packages require rebuilding all code
from scratch, ensuring to object file built with MSVCRT gets in, hence all
libraries for packages to test.  Note that MinGW and hence the compiler
toolchain itself has to be built for either MSVCRT or UCRT, as MinGW takes
care of the C runtime part that is compiler specific (and some of that needs
to be).

One needs a native compiler toolchain for R, that is compilers and binutils
that run on Windows.  Neither R nor R packages can be cross-compiled.  In
the past, R was experimentally cross-compiled, so perhaps this would not be
too hard to support if there was a need, but it is not clear how hard would
it be to cross-compile R packages.  Many, but most likely not all libraries
needed by R packages can be cross-compiled.  All libraries needed by R and
base + recommended packages can be currently cross-compiled.

Getting such a compiler toolchain is easy as scripts and docker files are
readily available, provided and used by at least MinGW developers and MXE. 
These scripts typically build the compiler toolchain on Linux: they build a
cross-compiler using the compilers and tools available on Linux and
cross-build the native compilers, binutils, MinGW runtime, etc, including
several libraries needed by GCC itself.

### Build tools

Since R has to be built natively on Windows, we need some tools on Windows
to do that.  To reduce these build-time dependencies, R on Windows is built
via Windows-specific make files.  These use also some tools from coreutils
and several other command line tools (such as sed, cat, grep, cp, rm, cmp,
cut, mkdir, echo, uniq, unzip, comm, sort, ls, mv, gzip, basename, date),
but not autoconf/automake.

Some of these build tools from coreutils cannot be easily built using the
MinGW compiler toolchain, because coreutils need more of Posix emulation
than what is provided by MinGW.  In the past, some of these utilities were
ported to Windows, but those ports are unmaintained and too old by now.

Today, coreutils for Windows are built using toolchains that use Cygwin
emulation of Posix.  The Cygwin emulation runtime already needs to be rather
large and is linked dynamically to applications that use it.  Build tools
are only needed for those building R packages with native code and those
building R from source, they are not needed for R end users, who only use R
binaries and R package binaries provided by others (e.g. CRAN).

Probably on today's modern Msys2/Cygwin installations it would not be too
hard to support building of R using configure scripts (autoconf), automake,
etc, and in the past Cygwin was supported, but it is not supported
currently. Many current open-source applications on Windows are built via
configure.

### Libraries

Most external libraries used by R are linked statically to the R dynamic
library.  There are several exceptions: Tcl/Tk is linked dynamically and
distributed together with R in binary form.  Iconv and BLAS/LAPACK are also
linked dynamically, but the default implementations are built during the
build of R itself from source included in the R source base.

R packages with native code are built into dynamic libraries, but all
external libraries should be linked statically into these dynamic libraries. 
These external libraries for CRAN/BIOC packages are the biggest amount of
work and concern when supporting R on Windows (adapting build configurations
and maintaining them), due to their number, currently well over a hundred.

## Infrastructures overview

R and packages can be built using any infrastructure providing what has been
mentioned in the previous section.  These are primarily RTools which are
used to build R binaries provided by CRAN, including the installers, and
package binaries of CRAN/BIOC.  However, R and many R packages can be built
also using general infrastructures, including Msys2 and MXE, but probably
many more.  When for local use and testing, this is easy particularly with
Msys2.

### Msys2

Msys2 is a software distribution of open source programs for Windows, which
provides a MinGW compiler toolchain, a number of libraries built using that
toolchain, and a number of build tools that are themselves built against the
Cygwin runtime and that are a (large) super-set of tools needed to build R. 
Msys2 is based on the Arch Linux package system: there is a way to install
individual packages, with their dependencies, etc. Currently it uses MSVCRT
as the C runtime.

Msys2 has many more libraries than those needed by R packages, but not
clearly a super-set, some are missing.  Msys2 uses dynamic linking:
libraries are dynamically linked to other libraries.  Also, by default
today's linkers including those in Msys2 prefer dynamic libraries when both
static and dynamic are available, so linking static libraries is then more
difficult even when they are available in addition: some build commands have
to be rewritten.

Still, for a local installation from scratch that is not intended for
relocation and that will always be used alongside the Msys2 installation,
one can use Msys2 to build R from source using dynamic linking.  This method
has been used several times to spot issues with newer compilers/newer
versions of MinGW than those provided by RTools, particularly looking at
compiler warnings and header file incompatibilities.  It is relatively easy
to get R and base+recommended packages to build and pass `check-all`. 
Probably many other packages would be easily test-able as well.  Also, in
the full Msys2, it should not be hard to build missing libraries from
source.

One minor issue is the tar utility.  GNU tar in Msys2 does not allow Windows
paths with a double colon (a double colon is also used in URLs), but one can
force it to use `--force-local` option with `TAR` environment variable. 
Preferably with a full path to prevent clashes with tar utility sometimes
bundled with Windows, which supports the double colon, but not
`--force-local`.  Also one should change R to link against PCRE dynamically
for this (look for _STATIC in the R source code).

### MXE

MXE is a cross-compiling environment based on make, with build configuration
for many open-source packages, including all external libraries needed by R
and base+recommended packages, and most (but clearly not all) libraries for
other CRAN/BIOC packages.  MXE can also be used to build the native
compiler toolchain needed to build R.  MXE supports static linking. MXE can
be uses also to build applications natively.

Experimental MinGW toolchains and libraries have been built both with MSVCRT
and UCRT, which allowed to build R and base+recommended packages.  Build
tools to build R were used from Msys2 distribution: running from Msys2, but
using the toolchain and libraries built using MXE.  This allowed to build R
and base+recommended packages, pass `check-all` and build the installer
(done only for 64-bit).  In principle, one can also cross-compile tools that
use the Cygwin runtime via MXE, e.g.  Octave have their own variant of MXE
with configuration to build a number of build tools originating from Msys2.

The experimental MXE-based toolchain was used as a test-bed for UTF-8
support on Windows as current native encoding (a recent update of R-devel to
support this).

In principle, it should be possible to build Msys2 also with/for UCRT.  For
this work, MXE was chosen as it seemed easier to have control that no object
files built with MSVCRT will get in, but one would have to become familiar
with both infrastructures to compare.  With MXE, it is one fewer step when
one can build the cross-compiler and native compiler the same way as the
libraries.

Unlike Msys2, MXE itself does not provide the binaries, one has to build
everything from source, which takes more time.  If what one needs is already
available in Msys2 (for testing R, testing R packages), it is probably
faster to use it from there.  MXE does not have any runtime of its own, it
is just a minimal infrastructure with make files, with build configurations
for many open-source projects. There is no support for distributing the
libraries, unlike Msys2 which has a package system.

### RTools

RTools include a compiler toolchain for R, the build tools and some
libraries needed by R and packages (headers and archive files with compiled
object files).

*RTools 3.x* are a static distribution.  Files are included in an offline
installer, including the compiler toolchain, build tools with the Cygwin
runtime libraries they need, and libraries needed to build R and base +
recommended packages.  Additional libraries and tools are available in
several tarballs that can be manually installed on top, downloaded from
locations mentioned in the R manuals for the versions of R that are built
with them.  They are in binary form (headers and static libraries).

The C runtime is MSVCRT.  RTools 3.x can be easily used from the Windows
command line (cmd.exe) with PATH appropriately set, as well as from Msys2:
the Cygwin runtime linked to the tools is older and named differently than
in Msys2, so there are no conflicts in DLL loading.

A good practice though is to use cmd.exe to run the builds, but do other
operations requiring more tools from another Msys2 window or Git Bash
window, which is a variant of Msys2 as well.  This makes it also easier to
ensure the right compilers are used.  RTools 3.x have been documented in
detail in R Admin manual, R FAQ for Windows, and materials linked from the
CRAN website.

RTools 3.x still work with the current R-devel and until recently have been
used also for all testing of packages, so they should still be usable for
some time, but are based on GCC 4.9, which is old by now.  Not all libraries
needed by CRAN and BIOC are easily available, some have been been compiled
later and are available at least on CRAN systems, but have not been
distributed systematically in their binary forms.

*RTools 4* are a slightly modified version of Msys2.  Some  of the build
tools were modified, such as tar to resolve the mentioned problem with a
double colon (the same change was already in RTools 3.x), but mostly they
are a subset of those in Msys2.  Some things have been changed, including
the home directory (in RTools 4, it is the user profile, but in Msys2, it is
in the Msys2 file-system tree) and the installer.

The biggest change compared to Msys2 is how the libraries are built.  Static
linking is used and dynamic libraries are not built at all (to prevent them
from being used, but it saves space, too).  Only packages needed for
CRAN/BIOC packages are included from Msys2, so many are missing, but there
are some extra ones not available in Msys2.  Versions of packages are
usually older than in Msys2, including the compilers.  RTools 4 use MSVCRT
and GCC 8.3.

As in Msys2 and in Linux distributions, libraries needed for R packages can
be installed using the Msys2 package manager (pacman), automatically caring
for dependencies.  There is no mechanism to find an Msys2/RTools 4 package
needed to build a particular R package, but as in other software
distributions, one can query which Msys2/RTools 4 package provides a file of
a given name (usually a header file or a library).

Not all external libraries needed to build R packages are available in
RTools 4, but the number is already higher than what is available in the
publicly distributed libraries for RTools 3.x.  Rtools 4 (like Msys2) is
typically used with mintty terminal and bash, providing a similar experience
to Unix, but very unusual for Windows.  One can also run bash terminal
directly (still Unix experience), or cmd.exe/other Windows terminal
application, but with PATH and other environment variables appropriately
set.

Sometimes one needs more build tools than those available in RTools 4.  It
may be a good practice again to use external tools in a separate window
with isolated PATH settings from those from RTools 4.  Sometimes it is
necessary also because such tools may not run from mintty/bash, e.g.  R
itself had to be modified to run from this shell due to differences in how
this shell communicates the keystrokes to the application.
 
Although RTools 4 is a modified version of Msys2, it cannot be used from
Msys2 easily via PATH settings, because RTools 4 has a runtime (DLL) of the
same name, but older, and they cannot easily coexist in one process: Windows
always use the newest version of a DLL, even when it is not the "right" one. 
This was incidentally not a problem with RTools 3.x, which used older Cygwin
runtime that had a different name.

One can still have a separate installation of vanilla Msys2 for build tools
and all applications needing the Cygwin runtime, but use the package
libraries and the compiler toolchain from RTools 4 installation,
appropriately setting PATH and completely bypassing build tools from RTools 4
(build tools here refer to all programs in the main Msys2 sub-distribution,
which links against the Cygwin runtime).  Then it is necessary to handle
some (minor) issues such as the tar command incompatibility described in the
previous section about Msys2.

More information on RTools 4 can be found
[here](https://cran.r-project.org/bin/windows/Rtools/).

## Building R 

This part provides all steps needed to build R from source on a fresh
installation of Windows 10.  It may not be repeatable in all details on
different Windows 10 installation and particularly not in the future as the
involved software evolves.

For learning purposes, it may be worthwhile first installing Msys2 and
learning to build R there.  It is fewer new things at a time, and for some
tasks it may be useful to have a vanilla installation of Msys2 alongside
RTools 4, anyway.  This way it also becomes clear that RTools 4 handles some
things one has to patch when building with vanilla Msys2. The text is also
intended to be read linearly including the Msys2 section, parts that are the
same for RTools 4 or MXE are not repeated in detail.

The description focuses on building R from source, from the tarball, and
only the 64-bit version.  The process requires several gigabytes of disk
space (tested in a VM with 40G disk) and installs some software not
necessarily needed.  Particularly the Msys2 repository tends to be slow
recently, so allow plenty of time for the initial installation even on
systems that are well connected to Internet.

### Msys2

A short description of Msys2 is available
[here](https://www.msys2.org/wiki/Using-packages/) and a detailed
description of its package manager, pacman, from Arch Linux is available
[here](https://wiki.archlinux.org/index.php/Pacman).

Download and install Msys2/x86_64 from installer available
[here](https://www.msys2.org/), at the time of this writing it was [this
one](http://repo.msys2.org/distrib/x86_64/msys2-x86_64-20190524.exe). Use
the defaults.  

Upgrade Msys2 packages: `pacman -Syu`.  This may require re-running the
upgrade in a new shell as instructed.  By default, the shell is in
`C:\msys64\msys`. The default home directory is `/home/tomas` (for Windows
user tomas) as displayed in the Msys2 shell (mintty/bash), which is also
accessible as `/c/msys64/home/tomas/` (when on Windows drive C) and from
Windows cmd.exe as `C:\msys64\home\tomas`.

It is useful but optional to download a database of files allowing to find
an Msys2 package that provides a given file: `pacman -Fy`.  One can now find
a package providing `unzip.exe` by `pacman -F unzip.exe` Note that Msys2 has
three sub-repositories, "msys" (the one to this text refers as build tools,
linked against the Cygwin runtime), "mingw64" (the one this text refers to
as compiler toolchain and libraries for R and packages, linked statically
with MinGW runtime and compiler by MinGW compilers), and "mingw32" (like
mingw64, but targeting 32-bit applications, which is ignored in this text). 
It is important that "msys" is only used for build tools (package names not
starting with "mingw", software only used during the build but not ending up
in the resulting binary) and "mingw64" is only used for libraries for R and
packages (packages starting with "mingw64").  Tools used for preparing the
code only, e.g.  version control, editors, etc, are also from "msys"
sub-repository.

All available packages (not necessarily installed) can be listed using
`pacman -Sl` (or without the sub-repository prefix, using `pacman -Slq`).
Installed packages can be listed using `pacman -Q`.

Install these "build" tools:
`pacman -S unzip diffutils make winpty rsync texinfo tar texinfo-tex zip subversion bison moreutils`.

Install a text editor:
`pacman -S vim`.

Install wget to download the tarball: `pacman -S wget`.

Download R tarball: `wget https://cran.r-project.org/src/base-prerelease/R-rc_2020-04-21_r78276.tar.gz`.

Unpack the tarball: `tar xfzh R-rc_2020-04-21_r78276.tar.gz`.  Tar will
unpack some files, but eventually fail because of symlinks (used for
recommended packages) appearing before their targets.  Just re-run the
command again, then it finishes successfully.  Alternatively, one can
instruct Msys2/Cygwin to implement symlinks differently by setting
`MSYS="winsymlinks:lnk"` while running the tar command.  More information on
symlink emulation can be found
[here](https://cygwin.com/cygwin-ug-net/using.html#pathnames-symlinks).

Install Tcl/Tk: a quick and dirty way is to install R from the CRAN binary
installer and copy Tcl directory next to 'src' in the R tree, e.g.  into
`R-rc/Tcl`.  The longer story is that Tcl/Tk can be built from source in
Msys2 (an older description is [here](https://github.com/waddella/Tclbuild/).
Tcl/Tk can be installed also from Msys2 packages, but R cannot readily use
it in that form. One can still install them as Msys2 packages and then
copy-out the files into a bundle, a script that does it for RTools4 is
available
[here](https://raw.githubusercontent.com/r-windows/r-base/master/create-tcltk-bundle.sh).
More details are available in a dedicated section below.

Install MikTeX from an installer available from
[here](https://miktex.org/download), at the time of this writing it was
[this one](https://miktex.org/download/ctan/systems/win32/miktex/setup/windows-x64/basic-miktex-2.9.7386-x64.exe),
version 2.9, installed into `C:\Program Files\MiKTeX 2.9`.  MikTeX is needed
to build the documentation, because Msys2 does not provide pdflatex.  This
is optional, only needed to build the documentation and to pass tests.  While the
documentation is being built and also while the tests are running, one may
be asked by MikTeX for permission to install LaTeX style files.
Unfortunately this version of MikTeX came with a number of caveats: read the
following paragraphs before deciding on how to set it up.

Set these environment variables. It may be useful to put these settings into
a file and include that when starting a new shell (`. renv.sh`).

```
export TAR="/usr/bin/tar --force-local"
export PATH=/c/msys64/mingw64/bin:"/c/Program Files/MiKTeX 2.9/miktex/bin/x64":$PATH
```

Note that when mintty/bash of Msys2 executes an external Windows program
such as pdflatex, some environment variables including PATH are converted,
adapting the paths like `/c/msys64` or `/home` to `C:\msys64` and
`C:\msys64\home`, converting also the separators. Also, vice versa,
mintty/bash inherits a converted version of some (but not all) variables,

When installing it this way, MikTeX needs to install a number of its
packages to build NEWS.pdf, which is built during R build (`make all`, `make
NEWSdocs`), however for some reason MikTeX's automatic installation does not
work during the R build process when instructed to ask before installing
external packages, which is the default. The MikTeX error that can be found
in the log files is "GUI framework cannot be initialized".

One possible workaround is to build NEWS.pdf manually the first time from
the command line, during which automatic installation works.  To do that,
create a directory `news` next to `R-rc`, from that directory with MikTeX
already on PATH (pdflatex must be available), run R and paste these commands
to produce NEWS.tex; they are adapted from R sources:

```
f <- readRDS("../R-rc/doc/NEWS.rds")
f2 <- tempfile()
out <- file("NEWS.tex", "w")
tools:::Rd2latex(f, f2,
         stages = c("install", "render"),
         outputEncoding = "UTF-8", writeEncoding = FALSE,
         macros = file.path(R.home("share"), "Rd", "macros", "system.Rd"))
cat("\\documentclass[", Sys.getenv("R_PAPERSIZE"), "paper]{book}\n",
    "\\usepackage[ae,hyper]{Rd}\n",
    "\\usepackage[utf8]{inputenc}\n",
    "\\usepackage{graphicx}\n",
    "\\setkeys{Gin}{width=0.7\\textwidth}\n",
    "\\graphicspath{{\"", normalizePath(file.path(R.home("doc"), "html"), "/"),
                        "/\"}}\n",
    "\\hypersetup{pdfpagemode=None,pdfstartview=FitH}\n",
    "\\begin{document}\n",
    "\\chapter*{}\\sloppy\n",
    "\\begin{center}\n\\huge\n",
    "NEWS for ", R.version$version.string, "\n",
    "\\end{center}\n",
    sep = "", file = out)
writeLines(readLines(f2), out)
writeLines("\\end{document}", out)
close(out)
```
Then exit R, copy the necessary style file
`cp ../R-rc/share/texmf/tex/latex/Rd.sty .`, the Rlogo 
`cp ../R-rc/doc/html/Rlogo.pdf .`,
and run `pdflatex NEWS.tex`. MikTeX will open a dialog asking whether
packages should be installed, and install them. 
Alternatively, one may do this even before installing R, using files copied
from here ([NEWS.tex](NEWS.tex), [Rd.sty](Rd.sty), [Rlogo.pdf](Rlogo.pdf)).

Another workaround is to change MikTeX settings to install needed packages
without asking.  MikTeX will install the packages even from R build, but the
version tested here segfaulted after producing NEWS.pdf, consequently R
build still failed to produce NEWS.pdf (R checks the exit status, which will
be nonzero due to the segfault).  Re-running the installation will then work
correctly.

Note that if setting MikTeX to install missing packages for all users, it
will have to often ask for elevated permissions, because R runs many
processes during the build and package checking.  For guaranteed
non-interactive use, it may hence be better to install these MikTeX packages
only with user privileges.

In addition, to pass the tests (`make check-all`, `reg-packages.R`), it is
necessary to get inconsolata fonts (or fonts named that way).  To do that,
run

```
initexmf --update-fndb
initexmf --edit-config-file updmap
```

The latter opens an editor, add this line to the end and save the file:

```
Map zi4.map
```

Then run `initexmf --mkmaps`. MikTeX log files can be found in
`~/AppData/Local/MikTeX/2.9/miktex/log` where `~` is the user profile.

Install these parts of the compiler toolchain and libraries for R and
R packages:

```
pacman -S mingw-w64-x86_64-gcc mingw-w64-x86_64-gcc-fortran mingw-w64-x86_64-pdcurses
  mingw-w64-x86_64-cairo mingw-w64-x86_64-curl mingw-w64-x86_64-icu mingw-w64-x86_64-libzip
  mingw-w64-x86_64-bzip2 mingw-w64-x86_64-libjpeg-turbo mingw64/mingw-w64-x86_64-libtiff
  mingw-w64-x86_64-pcre2
```

Patch R for dynamic linking of libraries against R.  As noted earlier, this
is not the standard supported way by R.

To apply the patch, install `pacman -S patch` and then run `patch
-p0 < nostatic.diff`. The patch is available [here](nostatic.diff). Do *not*
use this patch with RTools nor with any other toolchain that uses static
libraries.

Patch R's make file for Msys2 library naming, applying [this](extlib.diff)
patch.

Create MkRules.local file in 'src/gnuwin32' with this content:

```
WIN = 64
LOCAL_SOFT = /c/msys64/mingw64
BINPREF64 = $(LOCAL_SOFT)/bin/
USE_ICU = yes
ICU_PATH = $(LOCAL_SOFT)
ICU_LIBS = -licuin -licuuc -licudt -lstdc++
USE_LIBCURL = yes
CURL_PATH = $(LOCAL_SOFT)
CURL_LIBS = -lcurl -lssl -lssh2 -lcrypto -lgdi32 -lcrypt32 -lz -lws2_32 -lgdi32 -lcrypt32 -lwldap32 -lwinmm
USE_CAIRO = yes
TEXI2ANY = texi2any
TEXI2DVI = texi2dvi
```

Finally run `make 2>&1 | tee make.out`. Once it passes correctly, build also
the recommended packages using `make recommended 2>&1 | tee makerp.out`.

R, including RTerm and Rgui, can be run directly from the mintty/bash Msys2
terminal.  In case of RTerm, this is implemented via executing winpty
automatically.  R (RTerm, Rgui) can also be run from cmd.exe or PowerShell
and other Windows shells, but when built this way, one needs to set PATH
accordingly so that the necessary dynamic libraries from Msys2 are found,
e.g.  (again, one needs to replace the user name):

```
set PATH=C:\msys64\mingw64\bin;C:\Program Files\MiKTeX 2.9\miktex\bin\x64;%PATH%
```

After checking the build outputs for error messages, the next step to
validate the build is to check that external libraries are available from R
by running `extSoftVersion()`, `libCurlVersion()` (check there is a version
for PCRE, ICU, curl). Also test that Tcl/Tk can be loaded: `library(tcltk)`.

The next step of validation is to run the tests (`make check`, `make check-devel`, `make
check-all`).

Now one can try installing packages from source, e.g.  with
`install.packages(,type="source")` from R.  One may have to install missing
external libraries.  As note before, some packages may not build properly
with dynamic linking of external libraries (some use preprocessor macros to
indicate that static linking is used). Also, libraries in Msys2 may have
different set of dependencies from RTools, so the linking options, the
list of external libraries to link against, in R packages tested with RTools
4 may not work with a recent version of Msys2. 

To build directly from SVN, instead, create a working copy using

`svn checkout https://svn.r-project.org/R/trunk R-devel`

Copy the Tcl bundle inside the tree.  Create MkRules.local in `src/gnuwin32`
as when building from the tarball.  In `src/gnuwin32`, run `make
rsync-recommended` to get the recommended packages, which are already
contained in the tarball.

### RTools 4

RTools 4 build configurations for packages are available
[here](https://github.com/r-windows/rtools-packages), the original Msys2
configurations are [here](https://github.com/msys2/MINGW-packages) (the
compiler toolchain and libraries). Documentation for RTools 4 is available
[here](https://github.com/r-windows/docs).

Install Rtools 4 via its [installer](https://cran.r-project.org/bin/windows/Rtools/rtools40-x86_64.exe)
using the defaults.

Run the Msys2 shell from `c:\rtools40\msys2.exe`. The default directory is
`/c/Users/tomas` for user tomas, so the user's profile (`C:\Users\tomas`). 
RTools4 also set environment variable RTOOLS40_HOME with what is by default
`c:\rtools40`.

Upgrade Msys2/RTools 4 packages: `pacman -Syu`. 

Get an index of files provided by available packages using `pacman -Fy`
(optional). 

Download R tarball:
`https://cran.r-project.org/src/base-prerelease/R-rc_2020-04-21_r78276.tar.gz`.
Rtools 4 does not provide wget, but one can download files from the command
line using curl.

Extract the tarball, install the Tcl/Tk bundle, install MikTeX and create a
mapping for inconsolata fonts as described for Msys2 in the previous
section.

Install these parts of the compiler toolchain and libraries for R and
R packages:

```
pacman -S mingw-w64-x86_64-cairo mingw-w64-x86_64-curl mingw-w64-x86_64-icu
  mingw-w64-x86_64-libjpeg-turbo mingw64/mingw-w64-x86_64-libtiff mingw-w64-x86_64-pcre2
  mingw-w64-x86_64-xz
```

Create MkRules.local file in 'src/gnuwin32' with this content, e.g. using
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

Set PATH to include MikTeX.  This example differs from the previous section
(Msys2) where MikTeX was installed for all users.  Here MikTeX was installed
only for the current user, so it is located in a different directory:

```
export PATH="/c/Users/tomas/AppData/Local/Programs/MiKTeX 2.9/miktex/bin/x64":$PATH
```

Run `make 2>&1 | tee make.out` and `make recommended 2>&1 | tee makerp.out`,
check the output and run tests.

To build directly from an SVN checkout, one needs to get that checkout
externally, because RTools 4 do not include subversion.

Documentation on how the R binaries provided on CRAN pages are built is
available [here](https://github.com/r-windows/r-base#readme).

### MXE

Install Msys2 as described when building only with Msys2, including the
build tools, but not including the compiler toolchain. It is ok to use an
installation of Msys2 which already has that toolchain, the toolchain and
libraries ("mingw64" sub-repository) will just not be used with MXE.

Download an experimental MXE-based compiler toolchain + libraries (file
[gcc9_ucrt2.txz, 733M](https://www.r-project.org/nosvn/winutf8/gcc9_ucrt2.txz)).
This experimental archive requires UCRT, which is
available in Windows 10 and can be installed into older versions of Windows
(more information
[here](https://support.microsoft.com/en-us/help/2999226/update-for-universal-c-runtime-in-windows)).

Only 64-bit compiler toolchain and libraries are included. This is not only
in anticipation that the 32-bit toolchain will no longer be needed, but also
because there appeared more problems building libraries with 32-bit than
64-bit, so preparing the 32-bit toolchain might require more effort. After
unpacking, about 5.5G of space will be used. The archive does not include
symlinks (files are copied instead) for easier use.

Extract the archive into a directory of choice: `tar xf gcc9_ucrt2.txz`. In
this text, that directory is `/c/Users/tomas/ucrt` so that one can run
`/c/Users/tomas/ucrt/x86_64-w64-mingw32.static.posix/bin/gcc -v`.

Get R-devel source code, e.g. via subversion. It needs to be at least
version 78185 (support for UTF-8 as current native encoding on Windows), but
it is best to take the latest as more updated may turn out to be necessary.
Last tested this with R-devel 78739.

Apply this [patch](r_gcc9_ucrt2_2.diff).  The patch also sets the system
code page and the current native encoding to UTF-8 for R, which requires
Windows 10 November 2019 release (version 1909, which is build 18363) or
newer.  On older version of Windows, revert to the original manifest files,
UTF-8 will then not be used as either of these two encodings.  If trying on
an old version of Windows without UCRT, it can be downloaded from
[here](https://support.microsoft.com/en-us/help/2999226/update-for-universal-c-runtime-in-windows),
yet this toolchain has not been tested with it.

Install Inno Setup (optional, to build the R installer), download from
[here](https://jrsoftware.org/isdl.php). The Unicode version is needed (the
latest, Inno Setup version 6, has only the Unicode version).

Customize `src/gnuwin32/MkRules.local` with the
following content (it is also part of the patch, so shown here only for
reference):

```
LOCAL_SOFT = /c/Users/tomas/ucrt/x86_64-w64-mingw32.static.posix
WIN = 64
BINPREF64 = $(LOCAL_SOFT)/bin/
USE_ICU = YES
ICU_LIBS = -lsicuin -lsicuuc $(LOCAL_SOFT)/lib/sicudt.a -lstdc++
USE_LIBCURL = YES
CURL_LIBS = -lcurl -lrtmp -lssl -lssh2 -lgcrypt -lcrypto -lgdi32 -lz -lws2_32 -lgdi32 -lcrypt32 -lidn2 -lunistring -liconv -lgpg-error -lwldap32 -lwinmm
USE_CAIRO = YES
CAIRO_LIBS = "-lcairo -lfontconfig -lfreetype -lpng -lpixman-1 -lexpat -lharfbuzz -lbz2 -lintl -lz -liconv -lgdi32 -lmsimg32"
CAIRO_CPPFLAGS = "-I$(LOCAL_SOFT)/include/cairo"
TEXI2ANY = texi2any
MAKEINFO = texi2any
ISDIR = C:/Program Files (x86)/Inno Setup 6
```

Add the Tcl bundle to the tree.  Set these environment variables (adjust
user name etc).  These include a path to the 64-bit binaries of the Tcl
bundle in the build tree:

```
export PATH=/c/Users/tomas/ucrt/x86_64-w64-mingw32.static.posix/bin:/c/Users/tomas/ucrt/x86_64-w64-mingw32.static.posix/libexec/gcc/x86_64-w64-mingw32.static.posix/9.3.0:/c/Users/tomas/r/ucrt64/Tcl/bin64:"/c/Program Files/MiKTeX 2.9/miktex/bin/x64":$PATH
export TAR="/usr/bin/tar --force-local"
export JAVA_HOME=/c/opt/jdk-12.0.1
```

Run `make all 2>&1 | tee make.out` and `make recommended 2>&1 | tee makerp.out`.

Check that UTF-8 is used as current native encoding.  Session info should
show (the switch happens automatically via the manifest):

```
locale:
[1] LC_COLLATE=English_United States.utf8
[2] LC_CTYPE=English_United States.utf8
[3] LC_MONETARY=English_United States.utf8
[4] LC_NUMERIC=C
[5] LC_TIME=English_United States.utf8
```

and there should be nothing about the system code page (`sessionInfo()`
shows the system code page only when different from the current native
encoding).  `l10n_info()` should show

```
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

65001 is the Windows code page number for UTF-8.  Validate the build as
described in the previous sections.

Before creating the installer, make sure that the Tcl/Tk bundle does not
contain 32-bit files which would confuse the installer creation (delete
directories "lib" and "bin" from the Tcl bundle).  Create the installer: run
`make distribution` in `src/gnuwin32`.  The installer should appear as
`installer/R-devel-win.exe`.

Note that the official CRAN binary R packages will very unlikely work with
this build and definitely not correctly handle UTF-8, because they are built
for MSVCRT.  Technically, however, dynamic libraries on Windows can use
different C runtimes in the same application, so something could work, yet
there will be other incompatibilities (threading, C++ exceptions - not
investigated/tested yet, after all the incompatibility of encodings would
already be bad enough). Source versions of some CRAN packages will work as
they are, but not those that download pre-built static libraries. This
experimental version of R has been patched to install binary packages built
by this experimental toolchain (some of them were patched - more details in
the following sections).

Also note that for RTerm to work properly with "unusual" characters for the
local Windows installation (Unicode characters not representable in some
native encoding), one needs to use fonts that support those characters, e.g. 
in cmd.exe one can use `chcp 65001` to switch to UTF-8 code page, which will
also load the fonts.  `chcp 65001` needs to be run before running
`RTerm.exe`.  This is similar to that in RGui, one needs to switch to fonts
properly displaying Chinese when using Chinese characters, even though Rgui
is a Windows Unicode application.

`winpty` does not seem to support UTF-8 at present, so unusual characters
will not work in mintty/bash Msys2 terminal.  The workaround is to run from
cmd.exe or some other Windows shell.  One can also uninstall winpty, then
unusual characters will work, but some special keys including cursor
movements will not, which makes working with R rather difficult.  RGui is
not affected, it should always be able to accept and display unusual
characters as it has been in earlier versions of R.

## Building UTF-8 capable toolchain with MXE

[MXE](https://mxe.cc/) build configurations have been modified to use UCRT,
to use the latest version of MinGW, to use newer versions of other software
where there were build issues, to build with static linking. The modified
version used to build the experimental toolchain and libraries is available
[here](https://www.r-project.org/nosvn/winutf8/mxe_gcc9_ucrt2.tgz).

Building the toolchain should work on most Linux distributions.  The list of
required Linux packages to run it is documented
[here](https://mxe.cc/#requirements).  No further configuration is needed,
one just runs "make" (or parallel with "-j"). For this experiment, the build
was run on Ubuntu 19.04.

File `settings.mk` includes MXE configuration for this build:

```
MXE_PLUGIN_DIRS += plugins/examples/host-toolchain plugins/gcc9
MXE_TARGETS := x86_64-w64-mingw32.static.posix

#  --- base toolchain, plus libraries for base and recommended R packages ---

LOCAL_PKG_LIST := bzip2 cairo curl fontconfig freetype gcc icu4c jpeg libpng ncurses openssl pcre2 pixman readline tiff xz zlib librtmp
LOCAL_PKG_LIST += gcc-host

#  --- libraries for other contributed R packages, development tools ---

LOCAL_PKG_LIST += binutils boost cfitsio cmake expat ffmpeg fftw gdal gdb geos gettext giflib glpk gmp gpgme gsl harfbuzz hdf4 hdf5 isl jasper jsoncpp lame lapack libarchive libassuan libffi libgeotiff libgit2 libiconv libsndfile libssh libssh2 libtool libuv libvpx libwebp libxml2 lz4 mpc mpfr nasm netcdf nettle nlopt openblas opencv pcre poppler proj protobuf tcl termcap x264 xvidcore yasm zstd intel-tbb json-c
LOCAL_PKG_LIST += freexl gpgme ogg spatialite tre vorbis yaml-cpp jsoncpp lzo openjpeg pkgconf sqlite libgit2

```

One can reduce the amount of external libraries to be built just to those
needed for the base R and recommended packages (uncomment the last two lines
that add to `LOCAL_PKG_LIST`).  The set used by default includes much more,
but not all that is needed to build all CRAN/BIOC packages.  Also a number
of CRAN/BIOC packages do not build sucessfully for other reasons that would
have to be investigated, and it might be more difficult where R packages try
to download external source code and build that on their own.

MXE supports static linking (in contrast to Msys2), so proper adaptations
made to support builds with UCRT and with the newest versions of packages
may be merged back into MXE.  Some adaptations for the purpose of this
experiment were hacks, though.  One example is disabling format errors when
printing 64-bit integers, which cannot be printed with a compile warning
currently with Gcc/MinGW/UCRT without opting-out from the UCRT
implementations of print functions (reported).

R installer created using this toolchain can be downloaded from 
[here](https://www.r-project.org/nosvn/winutf8/R-devel-win.exe). 

It includes a 64-bit build of R with base and recommended packages.  In
principle one could then install the toolchain and libraries from the
archive mentioned here and set up to be usable from R, but it is probably
easier/better for validation then to build also R from source, anyway, as a
validation of the setup.

## Building packages with UTF-8 capable toolchain

The experimental build of R (and the installer mentioned above) is set up to
use binary versions of CRAN packages and dependent BIOC packages from
[here](https://www.r-project.org/nosvn/winutf8/demo).  The directory
structure is described [here](https://www.r-project.org/nosvn/winutf8/README).

The packages were built using the experimental build of R and the MXE-based
toolchain and libraries.  The static snapshot of CRAN and required BIOC
packages included 15793 packages in total.  About 92% can be built and pass
their tests with OK/NOTE (14656 CRAN and 59 BIOC packages). The binary
versions are available even for packages that did not pass the tests, for
all packages for which those could have been built. The percentage is not
representative of how much work is left: most of the CRAN packages luckily
don't include any native code.

54 CRAN packages were patched, so that they could be built. In most cases,
the patch only replaced parts that were downloading pre-built static
libraries by linker commands which use libraries provided by the toolchain.
Downloading binary builds of static libraries does not work, because such
binaries are dependent on the C runtime (in addition to other things), so
libraries built using MSVCRT cannot be used. In many cases, the packages
were downloading libraries that are even available in Msys2 (Rtools4).

The packages were built natively on a Windows machine and the process was
partially manual.  In principle, it is simple (`R CMD build --binary`), the
harder part is patching the packages. To support all packages, a number of
libraries would have to be added to the MXE-based toolchain.

## Tcl/Tk bundle

R is distibuted with a binary build of Tcl/Tk, which is needed for the
`tcltk` package and can be used from R, but also can be used externally. The
bundle includes both 32-bit and 64-bit builds.

R source code refers to that in older versions of R, the bundle has been
built using scripts by Adrian Waddell, available
[here](https://github.com/waddella/Tclbuild/).  Those scripts build Tcl/Tk
from source natively, running in an Msys2 installation, adding extensions
BWidget and TkTable. The scripts produced two separate builds, one 32-bit
and one 64-bit.

CRAN/official builds of R 3.6.3 and earlier, at least including R 3.4.3, included
a combined bundle with 32-bit and 64-bit builds.  Package BWidget's
directory was named really "BWidget" (so probably renamed after unpacking an
archive, from a form that included version number).  Tktable was included in
version 2.11, which is newer than what is available on the download sites
mentioned in the readme, it is not known to the author of this text where it
originated from.  The combined bundle uses the directory scheme where "bin"
has 32-bit binaries and DLLs, "bin64" has the same but for 64-bit, "lib" has
extensions with 32-bit DLLs and extensions without DLLs, and "lib64" has
extensions with 64-bit DLLs.  Hence, BWidget, which does not have DLLs, is
only in "lib", while "Tktable", which has DLLs, is both in "lib" and
"lib64".  Similarly, most "tcl8.6" files are only in "lib" and not in
"lib64".  To find 64-bit extension DLLs on 64-bit builds of R, R
automatically sets `TCLLIBPATH` in `.onLoad` handler of `tcltk` package. 
However, this means one has to set this variable by other means when using
Tcl/Tk from outside R. This Tcl/Tk bundle links against a dynamic build of
zlib1.dll (the original Tcl/Tk sources come with a binary of that DLL).

CRAN/official builds of R 4.0.2 use a Tcl/Tk bundle most likely created
using a script available
[here](https://raw.githubusercontent.com/r-windows/r-base/master/create-tcltk-bundle.sh).
The script copies out files from Msys2/RTools4 binary packages for Tcl,
BWidget and Tktable. A number of patches from Msys2 are applied. The
directory structure is changed so that 64-bit files are under "bin64/lib",
and these are all files, including the platform-independent ones. So,
BWidget copy is both in "bin64/lib" and in "lib". The relocation is done via
a patch to Tcl/Tk sources. Consequently, 64-bit extension DLLs can be
accessed from outside R without setting `TCLLIBPATH`. Tktable version 2.10
is used. The builds link statically against ZLIB, the version that is part of
Msys2/RTools4. BWidget has its original name from the sources
(`bwidget-1.9.12`). 

The Tcl/Tk bundle can also be cross-compiled, as described below.  One could
most likely use a cross-compiler built the way described above, but this has
been so far only tested with cross-compilers that are already part of Ubuntu
20.04 (they link against MSVCRT).  There may, still, potentially be issues
when Tcl/Tk libraries are linked against a different Windows runtime, so
doing this with the new cross-compilers in the future would make sense.  At
the time of this writing, the script chooses to mimic the structure of R
3.6.3's Tcl/Tk: 64-bit and 32-bit files are combined the same way, ZLIB is
linked dynamically, BWidget has the name `BWidget`.  Still, some patching of
the sources Msys2 does was still needed: fix path to `tclUnixPort.h` for the
cross-compilation, avoid linking the provided ZLIB1.DLL (it did not work in
32-bit builds, so using the one available in Ubuntu 20.04 with the
toolchain).  Tktable's tcl.m4 seems to be too old for cross-compilation, so
the scripts updates it with a version take from `sqlite` extensions, part of
Tcl 8.6.10 sources.  Tktable is installed in a modification of 2.10,
versioned `0.0.0.2010.08.18.09.02.05` (from
[here](http://teapot.activestate.com/package/name/Tktable)).

The files are available [here](tcltk): `bundle86.sh` is the script that
builds the bundle, `build_in_docker.sh` runs the former inside Docker, so
that one does not have to mess with the host distribution.

