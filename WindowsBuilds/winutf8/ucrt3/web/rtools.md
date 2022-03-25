---
title: "UCRT3 Experimental Rtools for Windows"
output: html_document
---

[UCRT3 Experimental R-devel](rdevel.html) for Windows uses this experimental
version of Rtools (currently Rtools42) for Windows.

The experimental Rtools installer is available [here](../rtools42-RTVER.exe).

More information about UCRT3 is available
[here](https://developer.r-project.org/WindowsBuilds/winutf8/ucrt3/howto.html).

**Please switch to the [official download
locations](https://cran.r-project.org/bin/windows/Rtools/rtools42/rtools.html)
for Rtools42, as these UCRT3 builds will get out of sync with
it.**

One can also download the [base](../gcc10_ucrt3_base_TLVER.tar.zst)
toolchain tarball, the [full](../gcc10_ucrt3_full_TLVER.tar.zst) toolchain
tarball and the [cross](../gcc10_ucrt3_cross_TLVER.tar.zst) toolchain
tarball.

GitHub actions may be used to install R, a tarball variant of Rtools, and
to check packages using these [GitHub Actions package
checking](https://github.com/kalibera/ucrt3) resources.

Sources are available for the
[toochain tarballs](https://svn.r-project.org/R-dev-web/trunk/WindowsBuilds/winutf8/ucrt3/toolchain_libs/)
and the
[Rtools installer](https://svn.r-project.org/R-dev-web/trunk/WindowsBuilds/winutf8/ucrt3/rtools/).
