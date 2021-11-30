---
title: "R-Devel build for Windows (UCRT 64-bit UTF-8)"
author: Tomas Kalibera
output: html_document
---

# R-Devel build for Windows (UCRT 64-bit UTF-8)

[Download R-Devel build for Windows](../R-devel-win-RDEV.exe) (MEGA megabytes, UCRT 64-bit UTF-8)

This build requires UCRT, which is part of Windows since Windows 10 and Windows Server
2016. On older systems, UCRT has to be installed manually from
[here](https://support.microsoft.com/en-us/topic/update-for-universal-c-runtime-in-windows-c0514201-7fe6-95a3-b0a5-287930f3560c).

On Windows since Windows 10 1903, Windows Server 2022 and Windows Server 1903
(semi-annual channel), UTF-8 will be used as the native encoding in R. On
older Windows systems, the locale code page will be used as with R 4.1 and
earlier.

This build of R requires all packages to be built for UCRT using RTools42. 
One cannot re-use installed packages from earlier RTools4 MSVCRT-based
builds of R-devel nor released versions.

This is a development version of R.  **It likely contains bugs, so be careful
if you use it.**  Please do not report bugs in this version through the usual R
bug reporting system, please report them on the [r-devel mailing list](https://stat.ethz.ch/mailman/listinfo/r-devel)---but
only if they persist for a few days.

As a temporary measure during the transition to UCRT, this version of R is
[patched](../R-devel-RDIFF.diff) and set up to automatically install
[patched](../patches) CRAN and dependent Bioconductor packages.

## Frequently asked questions

Please see the [R FAQ](https://cran.r-project.org/doc/FAQ/R-FAQ.html) for
general information about R and the
[R Windows FAQ](https://cran.r-project.org/bin/windows/base/rw-FAQ.html) for
Windows-specific information. Please see
[Howto: UTF-8 as native encoding in R on Windows with UCRT](https://svn.r-project.org/R-dev-web/trunk/WindowsBuilds/winutf8/ucrt3/howto.html)
for specific information about UTF-8, UCRT and RTools42.

## Other builds

* [The current official  release.](https://cran.r-project.org/bin/windows/base/index.html)
* Patches to this release are incorporated in the [r-patched snapshot build](https://cran.r-project.org/bin/windows/base/rpatched.html).
* [Previous releases](https://cran.r-project.org/bin/windows/base/old/).

---

Last build: YYYY-MM-DD
