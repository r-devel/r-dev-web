---
title: "Rtools42 for Windows (UCRT 64-bit UTF-8)"
output: html_document
---

[R-Devel (UCRT 64-bit UTF-8)](rdevel.html) for Windows uses a toolchain
bundle Rtools42 consisting of Msys2 build tools, GCC 10/MinGW-w64 compiler
toolchain and libraries.  Rtools42 supports 64-bit Windows and UCRT as the C
runtime.  The code compiled by earlier versions of Rtools for MSVCRT as the
C runtime is incompatible and has to be recompiled with Rtools42 for use in
R packages.  Switching to UCRT allows to use UTF-8 as the native encoding on
Windows.

## Installing Rtools42

Rtools42 is only needed for installation of R packages from source or
building R from source.  R can be installed from the
[R installer](rdevel.html)
and by default will install binary versions of CRAN packages, which does not
require Rtools42.

Rtools42 may be installed from the [Rtools42 installer](../rtools42-RTVER.exe).
It is recommended to use the defaults, including the default installation
location of `C:\rtools42`.

When using R installed from the binary installer, no further setup is
necessary after installing Rtools42 to build R packages from source.  When
using the default installation location, R and Rtools42 may be installed in
any order and Rtools42 may be installed when R is already running.

## Using build services

The [R-hub](https://builder.r-hub.io/advanced) builder supports building and
checking R packages using Rtools42.

GitHub actions may be used to install R, a tarball variant of Rtools42, and to check packages using these
[GitHub Actions package checking](https://github.com/kalibera/ucrt3) resources.

## Additional information

A detailed tutorial for R package authors is available in
[Howto: UTF-8 as native encoding in R on Windows with UCRT](https://svn.r-project.org/R-dev-web/trunk/WindowsBuilds/winutf8/ucrt3/howto.html).

From the user perspective, Rtools42 is almost the same as Rtools4. Both
include Msys2 build tools.

Unlike Rtools4

* Msys2 is unmodified (e.g.  no patched version of tar) and the toolchain
  and libraries are built using MXE.

* All libraries are included, instead of relying on external sources for
  downloading them. Rtools42 takes slightly over 3G when installed.

* A tarball of the compiler toolchain and libraries, excluding Msys2, can be
  installed directly for those preferring their own installation of Msys2 or
  other build tools.  One then needs to set environment variables
  `R_CUSTOM_TOOLS_SOFT` and `R_CUSTOM_TOOLS_PATH`.  The
  [base](../gcc10_ucrt3_base_TLVER.tar.zst)
  variant of the tarball is available for building R and most packages, the 
  [full](../gcc10_ucrt3_full_TLVER.tar.zst)
  one has all provided libraries.

* When R is installed from the binary installer, PATH to the compiler toolchain
  and build tools is set automatically (by R)
  based on the default location, information in the registry, or the
  `R_CUSTOM_TOOLS_PATH` variable.

* QPDF is currently not included, it is recommended to install an
  [upstream release](https://github.com/qpdf/qpdf/releases) to reduce the
  risk of accidental use of incompatible libraries within Rtools. This may
  be changed soon.

See 
[Howto: UTF-8 as native encoding in R on Windows with UCRT](https://svn.r-project.org/R-dev-web/trunk/WindowsBuilds/winutf8/ucrt3/howto.html)
for more information on `R_CUSTOM_TOOLS_SOFT` and `R_CUSTOM_TOOLS_PATH`. 

Rtools42 re-use the installer code (only with minor modifications) from
Rtools4.

The 32-bit target will no longer be supported by R.

Sources are available for the
[toochain tarballs](https://svn.r-project.org/R-dev-web/trunk/WindowsBuilds/winutf8/ucrt3/toolchain_libs/)
and the
[Rtools42 installer](https://svn.r-project.org/R-dev-web/trunk/WindowsBuilds/winutf8/ucrt3/rtools/).
