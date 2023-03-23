---
title: "Changes in Rtools43 for Windows"
output: html_document
---

### 5550

Distributed as rtools43-5550-5548.exe.

The default `_WIN32_WINNT` has been set to Windows 7 (0x0601, which is also
the MXE default). Windows Vista is no longer supported by R-devel (to become R
4.3). Previously, `_WIN32_WINNT` has been set to the MinGW-W64 default
(Windows 10 in MinGW-W64 10.0.0). The change is to reduce the risks that
unconditional dependency on Windows newer than 7 would be accidentally
introduced. Most existing code will be unaffected by this.

Upstream MXE changes have been merged from
`e560bd25a53b15f4899f290e1fc8193a4aa7a2a6`, with additional updates
to binutils, curl, openssl and other libraries.

The new version of curl requires also linking of `-lbcrypt`.  This can be
done unconditionally also for packages meant to work with Rtools42/R 4.2,
because the library existed there as well. Packages linking to curl may
have to be updated to build.

The new version of libwebp requires also linking of `-lsharpyuv`.  Rtools42
did not have that library, so packages meant to work also with R 4.2 should
link it conditionally.  Packages linking to libwebp may have to be updated. 
One possible way to do it in GNU make files (e.g.  `Makevars.ucrt`) is

```
LIBSHARPYUV = $(or $(and $(wildcard $(R_TOOLS_SOFT)/lib/libsharpyuv.a),-lsharpyuv),)
PKG_LIBS = ... -lwebp $(LIBSHARPYUV) ... 
```

The Rtools installer meta-data have been extended to use 3-column product
version, where the last element is the svn revision (now 4.3.5550).  Hence,
the svn revision of Rtools43 is displayed in the `Add/Remove Programs` list
in Windows.  The change may impact and should help improve behavior of
third-party tools for installing external software on Windows, such as
`winget`.  The file version in the meta-data is now 4-column
(4.3.5555.5548).  The original installer file name is now included in the
meta-data.

These packages have been updated:

```
armadillo 11.4.3 to 12.0.1
binutils 2.39 to 2.40
binutils-host 2.39 to 2.40
curl 7.84.0 to 7.88.1
dbus 1.15.2 to 1.15.4
file 5.43 to 5.44
fontconfig 2.14.1 to 2.14.2
freetds 1.3.16 to 1.3.17
freetype 2.12.1 to 2.13.0
freetype-bootstrap 2.12.1 to 2.13.0
freexl 1.0.5 to 1.0.6
geos 3.11.1 to 3.11.2
glib 2.75.1 to 2.76.0
harfbuzz 6.0.0 to 7.1.0
imagemagick 7.1.0-57 to 7.1.1-3
lcms 2.14 to 2.15
libarchive 3.6.1 to 3.6.2
libass 0.17.0 to 0.17.1
libgit2 1.5.0 to 1.6.2
libraw 0.20.2 to 0.21.1
libvpx 1.12.0 to 1.13.0
libwebp 1.2.4 to 1.3.0
mesa 22.3.0 to 23.0.0
mpfr 4.1.1 to 4.2.0
netcdf 4.9.0 to 4.9.1
opencv 4.6.0 to 4.7.0
openssl 3.0.7 to 3.0.8
pango 1.50.12 to 1.50.14
poppler 22.11.0 to 23.03.0
postgresql 13.9 to 13.10
proj 9.1.1 to 9.2.0
protobuf 21.10 to 21.12
qt6-qtbase 6.4.1 to 6.4.2
qtbase 5.15.7 to 5.15.8
sdl2 2.26.2 to 2.26.4
sqlite 3400000 to 3410100
vidstab 1.1.0 to 1.1.1
xz 5.4.0 to 5.4.1
zstd 1.5.2 to 1.5.4
```

### 5493

Distributed as rtools43-5493-5475.exe.

This minor update is important for users of gdal, which has been upgraded
from version 3.6.0 to 3.6.2.  Gdal 3.6.0 has been officially retracted,
because of a regression which could cause data corruption.  Users who need
to build from source any of the following CRAN packages should upgrade
Rtools43: gdalcubes, rgdal, sf, terra, vapour.

Geos has been updated from 3.9.4 to 3.11.1.

A minor bug in MinGW-W64 causing compiler warnings with `string_s.h`
(`-Wpedantic`) has been fixed.

These packages have been updated:

```
armadillo 11.4.2 to 11.4.3
blosc 1.21.1 to 1.21.2
boost 1.80.0 to 1.81.0
gdal 3.6.0 to 3.6.2
geos 3.9.4 to 3.11.1
glib 2.75.0 to 2.75.1
harfbuzz 5.3.1 to 6.0.0
imagemagick 7.1.0-52 to 7.1.0-57
libsndfile 1.1.0 to 1.2.0
minizip 3.0.7 to 3.0.8
mpc 1.2.1 to 1.3.1
pcre2 10.41 to 10.42
sdl2 2.26.0 to 2.26.2
tiff 4.4.0 to 4.5.0
xz 5.2.8 to 5.4.0
```

### 5448

Distributed as rtools43-5448-5475.exe.

Compared to rtools42 (release 5355), the core components have been updated:
GCC 12.2, MinGW-W64 10.0, binutils 2.39.  In addition to that, libraries
were updated to their current versions as detailed below.

Upstream MXE changes have been merged from
`b11aaa7123c59cde7bb5e9ff794c672f54b706c3`, with additional updates
to geospatial and other libraries.

These packages have been updated:

```
armadillo 8.200.2 to 11.4.2
binutils 2.37 to 2.39
binutils-host 2.37 to 2.39
blas 3.10.1 to 3.11.0
cblas 3.10.1 to 3.11.0
cfitsio 3410 to 3450
cmake-host 3.24.1 to 3.24.3
curl 7.83.1 to 7.84.0
dbus 1.13.22 to 1.15.2
dlfcn-win32 1.3.0 to 1.3.1
expat 2.4.8 to 2.5.0
ffmpeg 4.2.3 to 4.2.8
fftw 3.3.8 to 3.3.10
file 5.42 to 5.43
flac 1.4.0 to 1.4.2
fontconfig 2.14.0 to 2.14.1
freeglut 3.2.1 to 3.4.0
freetds 1.3.12 to 1.3.16
fribidi 1.0.11 to 1.0.12
gcc 10.4.0 to 12.2.0
gcc-host 10.4.0 to 12.2.0
gdal 3.5.2 to 3.6.0
gdk-pixbuf 2.42.6 to 2.42.10
geos 3.9.3 to 3.9.4
gettext 0.21 to 0.21.1
giflib 5.1.4 to 5.1.9
glib 2.70.2 to 2.75.0
glpk 4.65 to 5.0
gpgme 1.14.0 to 1.18.0
gsl 2.6 to 2.7.1
harfbuzz 5.1.0 to 5.3.1
hdf4 4.2.10 to 4.2.13
hiredis 1.0.2 to 1.1.0
icu4c 71.1 to 72.1
imagemagick 7.0.8-63 to 7.1.0-52
intel-tbb c28c8be to 9e219e2
jasper 3.0.6 to 4.0.0
json-c 0.13.1 to 0.16
jsoncpp 1.9.1 to 1.9.5
kealib 1.4.15 to 1.5.0
lapack 3.10.1 to 3.11.0
lcms 2.13 to 2.14
libarchive 3.3.3 to 3.6.1
libass 0.14.0 to 0.17.0
libassuan 2.5.3 to 2.5.5
libbluray 0.9.2 to 1.3.4
libffi 3.3 to 3.4.3
libgeotiff 1.5.1 to 1.6.0
libgit2 1.3.0 to 1.5.0
libgpg_error 1.45 to 1.46
libgsf 1.14.47 to 1.14.50
libpng 1.6.37 to 1.6.39
libraw 0.19.5 to 0.20.2
librtmp fa8646d to f1b83c1
libsndfile 1.0.30 to 1.1.0
libssh 0.9.1 to 0.10.4
libunistring 0.9.10 to 1.1
libuv 1.30.1 to 1.44.2
libvpx 1.8.2 to 1.12.0
libwebp 1.2.2 to 1.2.4
libxml2 2.9.12 to 2.10.3
libxslt 1.1.35 to 1.1.37
libzmq c89390f to c59104a
mesa 22.1.4 to 22.3.0
mingw-w64 9.0.0 to 10.0.0
minizip 2aa369c to 3.0.7
mpfr 4.1.0 to 4.1.1
msmpi 91080f2 to 72e0ee2
netcdf 4.8.1 to 4.9.0
openblas 0.3.20 to 0.3.21
opencore-amr 0.1.3 to 0.1.6
opencv 4.5.1 to 4.6.0
openssl 1.1.1q to 3.0.7
pango 1.50.0 to 1.50.12
pcre2 10.40 to 10.41
poppler 22.09.0 to 22.11.0
postgresql 13.6 to 13.9
proj 8.2.1 to 9.1.1
protobuf 3.9.0 to 21.10
qt6-qtbase 6.3.2 to 6.4.1
qtbase 5.15.6 to 5.15.7
readline 8.1 to 8.2
sdl2 2.0.20 to 2.26.0
sqlite 3390300 to 3400000
tidy-html5 5.8.0 to 5.9.14-next
wavpack 5.5.0 to 5.6.0
xvidcore 1.3.4 to 1.3.7
xz 5.2.6 to 5.2.8
yaml-cpp 0.6.2 to 0.7.0
zlib 1.2.12 to 1.2.13
```