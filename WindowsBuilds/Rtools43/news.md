---
title: "Changes in Rtools43 for Windows"
output: html_document
---

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

There packages have been updated:

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