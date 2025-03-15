---
title: "Rtools45 for Windows"
output: html_document
---

Rtools is a toolchain bundle used for building R packages from source (those
that need compilation of C/C++ or Fortran code) and for building R itself. 
Rtools45 is currently used for R 4.5 and R-devel, the development version of
R, to become R 4.6.0.

Rtools45 consists of Msys2 build tools, GCC 14/MinGW-w64 compiler toolchain,
libraries built using the toolchain, and QPDF.  Rtools45 supports 64-bit
Windows and UCRT as the C runtime.

Compared to Rtools44, Rtools45 for 64-bit Intel machines has newer versions
of two core components: GCC and binutils.  It is recommended to re-compile
all code with the new toolchain to avoid problems.  

Rtools45 is also available for 64-bit ARM machines (aarch64): it includes
Msys2 build tools (64-bit Intel builds running via emulation) and aarch64
builds of LLVM 19/MinGW-w64 compiler toolchain, libraries built using the
toolchain, and again QPDF.  The 64-bit ARM version of Rtools45 is
experimental: a number of CRAN packages don't work with it and the Fortran
compiler (flang-new) is not yet able to compile Fortran code of all CRAN
packages.  A number of CRAN packages don't work because they require
not-yet-available 64-bit ARM versions of external software.

## Installing Rtools45

Rtools is only needed for installation of R packages from source (those that
need compilation of C/C++ of Fortran code) or building R from source.  R can
be installed from the R binary installer and by default will install binary
versions of CRAN packages, which does not require Rtools45.

Moreover, online build services are available to check and build R packages
for Windows, for which again one does not need to install Rtools45 locally.
The [Winbuilder](https://win-builder.r-project.org/) check service uses
identical setup as the CRAN incoming packages checks and has already all
CRAN and Bioconductor packages pre-installed.

Rtools45 may be installed from the [Rtools45 installer](files/rtools45-RTVER.exe)
or [64-bit ARM Rtools45 installer](files/rtools45-aarch64-RTVER.exe).
It is recommended to use the defaults, including the default installation
location of `C:\rtools45`. 

When using R installed by the installer, no further setup is necessary after
installing Rtools45 to build R packages from source.  When using the default
installation location, R and Rtools45 may be installed in any order and
Rtools45 may be installed when R is already running.

On ARM, binary versions of packages are currently not available from CRAN,
so Rtools45 is required to install any package that needs compilation.

## Additional information

A detailed tutorial on how to build R and packages using Rtools45 for R package
authors and R developers is available for [R 4.5.x](../../base/howto-R-4.5.html)
and [R-devel](../../base/howto-R-devel.html).

From the user perspective, Rtools45 is the same as Rtools42-44.  However, it
uses newer versions of the compiler toolchain and libraries and some
libraries have been added, hence some package authors will have to adapt
their make files.  Maintainers of CRAN and Bioconductor packages may use
[these patches](https://www.r-project.org/nosvn/winutf8/ucrt3/patches/) for
reference or re-use them in their code.

A change log for Rtools45 vs Rtools44 and of individual revisions of
Rtools45 is available [here](news.html)

Rtools45 is also available in base and full toolchain tarballs suitable for
users who have their own installation of Msys2.  The base toolchain tarball
is smaller and includes only what is needed to build R and the recommended
packages.  All Rtools files are available [here](files).

Sources are available for the
[toochain tarballs](https://svn.r-project.org/R-dev-web/trunk/WindowsBuilds/winutf8/ucrt3/toolchain_libs/)
and the
[Rtools45 installer](https://svn.r-project.org/R-dev-web/trunk/WindowsBuilds/winutf8/ucrt3/rtools/).
