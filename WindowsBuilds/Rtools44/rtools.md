---
title: "Rtools44 for Windows"
output: html_document
---

Rtools is a toolchain bundle used for building R packages from source (those
that need compilation of C/C++ or Fortran code) and for building R itself. 
Rtools44 is currently used for R 4.4 and R-devel, the development version of
R, to become R 4.5.0.

Rtools44 consists of Msys2 build tools, GCC 13/MinGW-w64 compiler toolchain,
libraries built using the toolchain, and QPDF.  Rtools44 supports 64-bit
Windows and UCRT as the C runtime.

Compared to Rtools43, Rtools44 for 64-bit Intel machines has newer versions
of three core components: GCC, MinGW-w64, and binutils.  It is therefore
recommended to re-compile all code with the new toolchain to avoid problems. 
The code compiled by Rtools older than Rtools42 is incompatible due to use
of MSVCRT and has to be recompiled with Rtools44 for use in R packages.

Rtools44 is also available for 64-bit ARM machines (aarch64): it includes
Msys2 build tools (64-bit Intel builds running via emulation) and aarch64
builds of LLVM 17/MinGW-w64 compiler toolchain, libraries built using the
toolchain, and again QPDF.  The 64-bit ARM version of Rtools44 is
experimental: a number of CRAN packages don't work with it and the Fortran
compiler (flang-new) is not yet able to compile Fortran code of all CRAN
packages. A number of CRAN packages doesn't work because they require
not-yet-available 64-bit ARM versions of external software.

## Installing Rtools44

Rtools is only needed for installation of R packages from source (those that
need compilation of C/C++ of Fortran code) or building R from source.  R can
be installed from the R binary installer and by default will install binary
versions of CRAN packages, which does not require Rtools44.

Moreover, online build services are available to check and build R packages
for Windows, for which again one does not need to install Rtools44 locally.
The [Winbuilder](https://win-builder.r-project.org/) check service uses
identical setup as the CRAN incoming packages checks and has already all
CRAN and Bioconductor packages pre-installed.

Rtools44 may be installed from the [Rtools44 installer](files/rtools44-RTVER.exe)
or [64-bit ARM Rtools44 installer](files/rtools44-aarch64-RTVER.exe).
It is recommended to use the defaults, including the default installation
location of `C:\rtools44`. 

When using R installed by the installer, no further setup is necessary after
installing Rtools44 to build R packages from source.  When using the default
installation location, R and Rtools44 may be installed in any order and
Rtools44 may be installed when R is already running.

On ARM, binary versions of packages are currently not available from CRAN,
so Rtools44 is required to install any package that needs compilation.

## Additional information

A detailed tutorial on how to build R and packages using Rtools44 for R package
authors and R developers is available for [R 4.4.x](../../base/howto-R-4.4.html)
and [R-devel](../../base/howto-R-devel.html).

From the user perspective, Rtools44 is the same as Rtools43 (and Rtools42). 
However, it uses newer versions of the compiler toolchain and libraries, and
hence some package authors will have to extend their make files to link
additional libraries.  Maintainers of CRAN and Bioconductor packages may use
[these patches](https://www.r-project.org/nosvn/winutf8/ucrt3/patches/) for
reference or re-use them in their code.

A change log for Rtools44 vs Rtools43 and of individual revisions of
Rtools44 is available [here](news.html)

Rtools44 is also available in base and full toolchain tarballs suitable for
users who have their own installation of Msys2.  The base toolchain tarball
is smaller and includes only what is needed to build R and the recommended
packages.  All Rtools files are available [here](files).

Sources are available for the
[toochain tarballs](https://svn.r-project.org/R-dev-web/trunk/WindowsBuilds/winutf8/ucrt3/toolchain_libs/)
and the
[Rtools44 installer](https://svn.r-project.org/R-dev-web/trunk/WindowsBuilds/winutf8/ucrt3/rtools/).
