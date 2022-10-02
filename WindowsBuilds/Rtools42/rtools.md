---
title: "Rtools42 for Windows"
output: html_document
---

Rtools is a toolchain bundle used for building R packages from source (those
that need compilation of C/C++ or Fortran code) and for build R itself. 
Rtools42 is used for R 4.2.x and currently for R-devel, the development version of
R since revision 81360.

Rtools42 consists of Msys2 build tools, GCC 10/MinGW-w64 compiler toolchain
and libraries and QPDF.  Rtools42 supports 64-bit Windows and UCRT as the C
runtime.  The code compiled by earlier versions of Rtools is incompatible
and has to be recompiled with Rtools42 for use in R packages. Switching to
UCRT allows to use UTF-8 as the native encoding on Windows.

## Installing Rtools42

Rtools42 is only needed for installation of R packages from source or
building R from source.  R can be installed from the R binary installer and
by default will install binary versions of CRAN packages, which does not
require Rtools42.

Moreover, online build services are available to check and build R packages
for Windows, for which again one does not need to install Rtools42 locally.
The [Winbuilder](https://win-builder.r-project.org/) check service uses
identical setup as the CRAN incomming packages checks and has already all
CRAN and Bioconductor packages pre-installed.

Rtools42 may be installed from the [Rtools42 installer](files/rtools42-RTVER.exe).
It is recommended to use the defaults, including the default installation
location of `C:\rtools42`.

When using R installed by the installer, no further setup is necessary after
installing Rtools42 to build R packages from source.  When using the default
installation location, R and Rtools42 may be installed in any order and
Rtools42 may be installed when R is already running.

## Additional information

A detailed tutorial on how to build R and packages using Rtools42 for R package
authors and R developers is available for
[R-4.2.x](../../base/howto-R-4.2.html)
and
[R-devel](../../base/howto-R-devel.html).

From the user perspective, Rtools42 is almost the same as Rtools4. Both
include Msys2 build tools.

Unlike Rtools4

* Msys2 is unmodified (e.g.  no patched version of tar) and the toolchain
  and libraries are built using MXE. QPDF is added from its own
  installation.

* All libraries are included, instead of relying on external sources for
  downloading them. Rtools42 takes slightly over 3G when installed.

* A tarball of the compiler toolchain and libraries, excluding Msys2, can be
  installed directly for those preferring their own installation of Msys2 or
  other build tools.  One then needs to set environment variables
  `R_CUSTOM_TOOLS_SOFT` and `R_CUSTOM_TOOLS_PATH`.  The
  [base](files/rtools42-toolchain-libs-base-TLVER.tar.zst)
  variant of the tarball is available for building R and most packages, the 
  [full](files/rtools42-toolchain-libs-base-TLVER.tar.zst)
  one has all provided libraries.

* When R is installed from the binary installer, PATH to the compiler toolchain
  and build tools is set automatically (by R)
  based on the default location, information in the registry, or the
  `R_CUSTOM_TOOLS_PATH` variable.

* 32-bit builds are no longer supported

* Rtools42 is also available in base and full toolchain tarballs suitable
  for users who have their own installation of Msys2. The base toolchain
  tarball is smaller and includes only what is needed to build R and the
  recommended packages. All Rtools files are available [here](files).

Rtools42 re-use the installer code (only with minor modifications) from
Rtools4.

A change log for individual revisions of Rtools42 is available
[here](news.html).

Sources are available for the
[toochain tarballs](https://svn.r-project.org/R-dev-web/trunk/WindowsBuilds/winutf8/ucrt3/toolchain_libs/)
and the
[Rtools42 installer](https://svn.r-project.org/R-dev-web/trunk/WindowsBuilds/winutf8/ucrt3/rtools/).
