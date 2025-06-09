---
title: "Changes in Rtools45 for Windows"
output: html_document
---
### 6608
Distributed as rtools45-6608-6492.exe and rtools45-aarch64-6608-6492.exe.

In this Rtools release, package `quantlib 1.38` has been added.  Upstream
MXE changes have been merged from 53a0021aec08cda84c26eb0bb603961eb84f91dc. 
and additional packages have been updated as detailed below:

```
boost 1.87.0 to 1.88.0
cairo 1.18.2 to 1.18.4
c-ares 1.34.4 to 1.34.5
curl 8.12.1 to 8.13.0
dlfcn-win32 1.4.1 to 1.4.2
expat 2.6.4 to 2.7.1
ffmpeg 7.1 to 7.1.1
flint 3.1.3-p1 to 3.2.2
fluidsynth 2.4.3 to 2.4.6
gdal 3.10.2 to 3.11.0
gettext 0.24 to 0.25
glib 2.83.4 to 2.85.0
gpgme 1.24.2 to 1.24.3
harfbuzz 10.3.0 to 11.2.1
hiredis 1.2.0 to 1.3.0
icu4c 76.1 to 77.1
imagemagick 7.1.1-44 to 7.1.1-47
intel-tbb 2022.0.0 to 2022.1.0
jasper 4.2.4 to 4.2.5
kealib 1.6.1 to 1.6.2
libarchive 3.7.7 to 3.8.0
libde265 1.0.15 to 1.0.16
libdeflate 1.23 to 1.24
libffi 3.4.7 to 3.4.8
libgcrypt 1.11.0 to 1.11.1
libgpg_error 1.51 to 1.55
libheif 1.19.5 to 1.19.8
libidn2 2.3.7 to 2.3.8
libpng 1.6.47 to 1.6.48
libraw 0.21.3 to 0.21.4
libsbml 5.20.4 to 5.20.5
libuv 1.50.0 to 1.51.0
libvpx 1.15.0 to 1.15.1
libxml2 2.12.9 to 2.12.10
libxslt 1.1.42 to 1.1.43
minizip 4.0.8 to 4.0.10
mpfr 4.2.1 to 4.2.2
nghttp2 1.64.0 to 1.65.0
openssl 3.4.1 to 3.5.0
pango 1.56.1 to 1.56.3
pixman 0.44.2 to 0.46.0
poppler 25.02.0 to 25.05.0
postgresql 13.20 to 16.9
proj 9.5.1 to 9.6.0
sqlite 3490100 to 3490200
theora 1.1.1 to 1.2.0
xz 5.6.4 to 5.8.1
```

### 6536
Distributed as rtools45-6536-6492.exe and rtools45-aarch64-6536-6492.exe.

Compared to Rtools44 (release 6459), the core components have been updated:
GCC to version 14.2.0 and binutils to version 2.43.1.  In the aarch64
version of Rtools, LLVM has been updated to version 19.1.7.  MinGW-w64
version 11.0.1 is still used because of numerical differences seen with
version 12.0.0 (MinGW-w64 12.0.0 uses more of the math functions from UCRT
than version 11.0.1).

The build of curl now supports HTTP/2 via a new dependency, nghttp2. 
Therefore, packages linking to curl and not using pkg-config need to update
their make files to explicitly link nghttp2.  Packages using pkg-config for
establishing the linking commands will now link nghttp2 automatically. 
Patches were provided to maintainers of the affected CRAN and Bioconductor
packages.

See [Porting to GCC 14](https://gcc.gnu.org/gcc-14/porting_to.html)  for a
detailed description of common issues encountered when fixing newly reported
compiler errors and warnings.  Note that R 4.5 by default selects the C23
standard, which is newer than the default in GCC 14.

The version of Rtools for 64-bit ARM (aarch64) machines is still
experimental.  It lacks msmpi (not supported on aarch64) and yasm (does not
support aarch64).  The LLVM 19 flang (flang-new) Fortran compiler is
experimental and cannot compile some of the CRAN packages.  A number of CRAN
and Bioconductor packages will have to be updated to support LLVM (or
aarch64).

The Rtools cross-compilers run on Linux (tested/used on 64-bit Intel): one
version targets 64-bit Intel Windows and one targets 64-bit ARM Windows.

In this Rtools release, these packages have been added:

```
aom 3.12.0
libde265 1.0.15
libheif 1.19.5
nghttp2 1.64.0
poppler-data 0.4.12
x265 4.1
```

These packages have been updated:

```
abseil-cpp 20240722.0 to 20250127.0
binutils 2.42 to 2.43.1
binutils-host 2.42 to 2.43.1
blas 3.12.0 to 3.12.1
boost 1.85.0 to 1.87.0
c-ares 1_26_0 to 1.34.4
cblas 3.12.0 to 3.12.1
curl 8.11.1 to 8.12.1
flac 1.4.3 to 1.5.0
fluidsynth 2.4.2 to 2.4.3
gcc 13.3.0 to 14.2.0
gcc-host 13.3.0 to 14.2.0
gdal 3.10.1 to 3.10.2
geos 3.13.0 to 3.13.1
gettext 0.23.1 to 0.24
glib 2.83.2 to 2.83.4
gnutls 3.8.8 to 3.8.9
gpgme 1.24.0 to 1.24.2
grpc 1.68.2 to 1.70.1
harfbuzz 10.2.0 to 10.3.0
hdf4 4.2.13 to 4.2.15
imagemagick 7.1.1-43 to 7.1.1-44
jq 1.6 to 1.7.1
lapack 3.12.0 to 3.12.1
lcms 2.16 to 2.17
libffi 3.4.6 to 3.4.7
libpng 1.6.45 to 1.6.47
libtasn1 4.19.0 to 4.20.0
nlopt 2.8.0 to 2.10.0
openssl 3.4.0 to 3.4.1
pcre2 10.44 to 10.45
poppler 25.01.0 to 25.02.0
sqlite 3480000 to 3490100
tre 0.8.0 to 0.9.0
wavpack 5.7.0 to 5.8.1
x264 a8b68ebf to 373697b4
xz 5.6.3 to 5.6.4
yaml-cpp 0.7.0 to 0.8.0
zstd 1.5.6 to 1.5.7
```

These packages have been removed:

```
atk
gtk2
libv8
```

Package OpenCV is now built with contributed modules.
