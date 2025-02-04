---
title: "Changes in Rtools44 for Windows"
output: html_document
---
### 6414
Distributed as rtools44-6414-6401.exe and rtools44-aarch64-6414-6401.exe.

Upstream MXE changes have been merged from
b553e1a7d57888fb2ab3d0e635c5fa243ec6e8e9 and some additional packages have
been updated as detailed below.

Package flint has been added (via upstream MXE, thanks to Mikael Jagan). The
build of ffmpeg now supports libmp3lame codec.

These packages have been added:

```
flint 3.1.3-p1
```

These packages have been updated:

```
curl 8.10.1 to 8.11.1
expat 2.6.3 to 2.6.4
file 5.45 to 5.46
fluidsynth 2.3.6 to 2.4.2
fontconfig 2.15.0 to 2.16.0
gdal 3.9.3 to 3.10.1
geos 3.12.2 to 3.13.0
gettext 0.22.5 to 0.23.1
glib 2.82.1 to 2.83.2
gnutls 3.8.6 to 3.8.8
gpgme 1.23.2 to 1.24.0
grpc 1.66.2 to 1.68.2
harfbuzz 10.0.1 to 10.2.0
icu4c 74.2 to 76.1
imagemagick 7.1.1-39 to 7.1.1-43
intel-tbb 2021.13.0 to 2022.0.0
kealib 1.5.3 to 1.6.1
libdeflate 1.22 to 1.23
libgit2 1.8.1 to 1.9.0
libgpg_error 1.50 to 1.51
libiconv 1.17 to 1.18
libltdl 2.4.6 to 2.5.4
libpng 1.6.44 to 1.6.45
libssh2 1.11.0 to 1.11.1
libunistring 1.2 to 1.3
libuv 1.49.1 to 1.50.0
libvpx 1.14.1 to 1.15.0
libwebp 1.4.0 to 1.5.0
libzmq 90b4f41 to 34f7fa2
minizip 4.0.7 to 4.0.8
msmpi fe5f73f to d7d54d1
openblas 0.3.28 to 0.3.29
opencv 4.10.0 to 4.11.0
openjpeg 2.5.2 to 2.5.3
openssl 3.3.2 to 3.4.0
pango 1.54.0 to 1.56.1
pixman 0.43.4 to 0.44.2
poppler 24.10.0 to 25.01.0
postgresql 13.16 to 13.18
proj 9.4.1 to 9.5.1
protobuf 25.5 to 29.3
sdl2 2.30.8 to 2.30.11
speex 1.2.0 to 1.2.1
sqlite 3460100 to 3480000
```

### 6335
Distributed as rtools44-6335-6327.exe and rtools44-aarch64-6335-6327.exe.

GCC has been patched so that one can again use GCC from a mapped network
drive.  This did not work in 6104 due to a GCC change that woke up a bug in
binutils.  To avoid problems, it is still advisable to install all of Rtools
to a local disk and use it from there.

GCC has been patched to avoid a bug in the C++ library causing incorrect
results of complex exponentiation.

HDF5 is now built with Fortran support.

Windows 7 and 8 are no longer supported, because Msys2 no longer supports
them.  To build R or packages on those systems, users might use Rtools44
release 6104 or a standalone installation of an older version of Msys2
with the current Rtools toolchain and libraries (e.g.  installed from a
tarball).

Upstream MXE changes have been merged from
`a31368b037221d56bcfcfd8c546b89adffe9ea04`, with additional updates as
detailed below.

These packages have been updated:

```
abseil-cpp 20240116.1 to 20240722.0
armadillo 12.8.0 to 12.8.4
blosc 1.21.5 to 1.21.6
boost 1.84.0 to 1.85.0
cairo 1.18.0 to 1.18.2
cfitsio 3450 to 4.5.0
cmake-host 3.28.3 to 3.30.4
curl 8.6.0 to 8.10.1
expat 2.6.0 to 2.6.3
ffmpeg 4.2.9 to 7.1
fluidsynth 2.3.4 to 2.3.6
freeglut 3.4.0 to 3.6.0
freetype 2.13.2 to 2.13.3
freetype-bootstrap 2.13.2 to 2.13.3
fribidi 1.0.13 to 1.0.16
gcc 13.2.0 to 13.3.0
gcc-host 13.2.0 to 13.3.0
gdal 3.8.4 to 3.9.3
gdk-pixbuf 2.42.10 to 2.42.12
geos 3.12.1 to 3.12.2
gettext 0.22.4 to 0.22.5
glib 2.78.4 to 2.82.1
gnutls 3.8.3 to 3.8.6
grpc 1.61.1 to 1.66.2
harfbuzz 8.3.0 to 10.0.1
imagemagick 7.1.1-28 to 7.1.1-39
intel-tbb 2021.11.0 to 2021.13.0
jasper 4.2.0 to 4.2.4
json-c 0.17 to 0.18
jsoncpp 1.9.5 to 1.9.6
libarchive 3.7.2 to 3.7.7
libass 0.17.1 to 0.17.3
libassuan 2.5.6 to 2.5.7
libdeflate 1.19 to 1.22
libffi 3.4.3 to 3.4.6
libgcrypt 1.10.3 to 1.11.0
libgit2 1.7.2 to 1.8.1
libgpg_error 1.47 to 1.50
libgsf 1.14.52 to 1.14.53
libidn 1.36 to 1.42
libidn2 2.3.0 to 2.3.7
liblqr-1 0.4.2 to 0.4.3
libpng 1.6.42 to 1.6.44
libraw 0.21.2 to 0.21.3
librtmp f1b83c1 to 6f6bb13
libsbml 5.20.2 to 5.20.4
libsodium 1.0.19 to 1.0.20
libssh 0.10.6 to 0.11.1
libunistring 1.1 to 1.2
libuv 1.48.0 to 1.49.1
libvpx 1.14.0 to 1.14.1
libwebp 1.3.2 to 1.4.0
libxml2 2.12.5 to 2.12.9
libxslt 1.1.39 to 1.1.42
libzmq 3b26401 to 90b4f41
lz4 1.9.4 to 1.10.0
minizip 4.0.4 to 4.0.7
msmpi 72e0ee2 to fe5f73f
nlopt 2.7.1 to 2.8.0
openblas 0.3.26 to 0.3.28
opencv 4.9.0 to 4.10.0
openjpeg 2.5.0 to 2.5.2
openssl 3.2.1 to 3.3.2
pango 1.51.2 to 1.54.0
pcre2 10.43 to 10.44
pixman 0.43.2 to 0.43.4
poppler 24.02.0 to 24.10.0
postgresql 13.14 to 13.16
proj 9.3.1 to 9.4.1
protobuf 25.3 to 25.5
re2 2024-02-01 to 2024-07-02
sdl2 2.28.5 to 2.30.8
sqlite 3450100 to 3460100
tiff 4.6.0 to 4.7.0
wavpack 5.6.0 to 5.7.0
xz 5.4.6 to 5.6.3
zstd 1.5.5 to 1.5.6
```

### 6104
Distributed as rtools44-6104-6039.exe and rtools44-aarch64-6104-6039.exe.

Compared to Rtools43 (release 5958), the core components have been updated:
GCC to version 13.2.0, MinGW-W64 to version 11.0.1 and binutils to version
2.42.

A number of R packages have to be updated to reflect changes in linking:
common new dependencies include libdeflate, lerc, libpsl, brotli. 
Maintainers of affected CRAN and Bioconductor packages have been notified
and provided with patches.  Package authors may use pkg-config for
establishing the linking commands, which should reduce the frequency of
needed updates in packages.

Some CRAN packages require to explicitly include `<cstdint>` with GCC 13.
Package authors have been provided with patches. See [Porting to GCC
13](https://gcc.gnu.org/gcc-13/porting_to.html) for more information.

Upstream MXE changes have been merged from
`a147a77503fc1933ba4196ad21025a99a0ba90b3.`, with additional updates as
detailed below.

This release of Rtools also includes a version for 64-bit ARM (aarch64)
machines, based on LLVM (and libc++).  Compared to the version for 64-bit
Intel, it includes llvm 17.0.6 (and lacks gcc, binutils).  Currently it also
lacks msmpi (not supported on aarch64), yasm (does not support aarch64),
gtk2 and libv8.  The LLVM flang (flang-new) Fortran compiler is still
experimental and cannot compile some of the CRAN packages.  A number of CRAN
and Bioconductor packages will have to be updated to support LLVM (or
aarch64), some package maintainers were provided with patches.

The Rtools cross-compilers run on Linux (tested/used on 64-bit Intel): one
version targets 64-bit Intel Windows and one targets 64-bit ARM Windows.

In this Rtools release, these packages have been added:

```
fluidsynth 2.3.4
lerc 4.0.0
libdeflate 1.19
libidn 1.36
libpsl 0.21.5
portaudio 190700_20210406
```

These packages have been updated:

```
abseil-cpp 20230802.1 to 20240116.1
armadillo 12.6.7 to 12.8.0
binutils 2.40 to 2.42
binutils-host 2.40 to 2.42
cairo 1.16.0 to 1.18.0
c-ares 1_25_0 to 1_26_0
cmake-host 3.28.1 to 3.28.3
curl 8.5.0 to 8.6.0
expat 2.5.0 to 2.6.0
ffmpeg 4.2.8 to 4.2.9
gcc 12.3.0 to 13.2.0
gcc-host 12.3.0 to 13.2.0
gdal 3.8.2 to 3.8.4
geos 3.11.2 to 3.12.1
gettext 0.21.1 to 0.22.4
glib 2.76.5 to 2.78.4
gnutls 3.8.0 to 3.8.3
grpc 1.60.0 to 1.61.1
icu4c 74.1 to 74.2
imagemagick 7.1.1-25 to 7.1.1-28
jasper 4.1.1 to 4.2.0
jpeg 9e to 9f
libgit2 1.7.1 to 1.7.2
libgsf 1.14.51 to 1.14.52
libpng 1.6.40 to 1.6.42
libsodium 1.0.18 to 1.0.19
libuv 1.47.0 to 1.48.0
libvpx 1.13.1 to 1.14.0
libxml2 2.12.3 to 2.12.5
libzmq 959a133 to 3b26401
mingw-w64 10.0.0 to 11.0.1
openssl 3.1.4 to 3.2.1
pango 1.51.0 to 1.51.2
pcre2 10.42 to 10.43
pixman 0.42.2 to 0.43.2
poppler 23.09.0 to 24.02.0
postgresql 13.13 to 13.14
protobuf 25.2 to 25.3
re2 2023-11-01 to 2024-02-01
sqlite 3440200 to 3450100
xz 5.4.5 to 5.4.6
```
