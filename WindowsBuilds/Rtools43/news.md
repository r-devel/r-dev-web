---
title: "Changes in Rtools43 for Windows"
output: html_document
---

### 5958
Distributed as rtools43-5958-5975.exe.

This is a correction release which fixes a problem in the build of the Msys2
part of release 5948.

A typical symptom of the problem in 5948 is that Msys2 packages
cannot be installed or upgraded using pacman.

Users who have already upgraded to 5948 and wish to avoid another upgrade
may choose to fix the problem by running `update-ca-trust` in the Rtools
(Msys2) shell, this will allow installation/upgrading of packages.

A more complete fixup is to run:
```
for F in /var/lib/pacman/local/*/install ; do
  bash -c  "cd / ; . $F ; [[ \$(type -t post_install)  == function ]] && post_install"
done
```

At the time of this correction release, the corresponding experimental build
for [aarch64](https://www.r-project.org/nosvn/winutf8/rtools43-aarch64/) has
been updated.  It has several improvements allowing more of CRAN packages to
be built for aarch64 than with 5948.

### 5948
Distributed as rtools43-5948-5818.exe.

A problem was found in this release, see the description of 5958 above.

gRPC and dependencies re2, abseil and c-ares have been added.  Protobuf has
been updated to 25.2.  Rtools now include also the native protocol buffer
compiler (protoc).

A batch-file wrapper has been created for pkg-config to simplify use in some
github action runners.  See the documentation for more details ([for R
4.3](https://cran.r-project.org/bin/windows/base/howto-R-4.3.html), [for
R-devel](https://cran.r-project.org/bin/windows/base/howto-R-devel.html)).

The pkg-config configuration has been fixed to allow detection of expanded
absolute paths, which improves output for some libraries (MXE packages).

Packages linking httpuv now also need to link dbghelp, uuid and ole32. This
affects one CRAN package, httpuv.

Packages linking protobuf now also need to link the abseil libraries.  The
number of abseil libraries is large, but one may avoid the need for
specifying them individually by using pkg-config.

Code using xml2 may have to be updated to follow changes in the API.  This
required changes in one CRAN package, XML.

Upstream MXE changes have been merged from
`fca881fdf19405f80252967c97590976f2c2b570`, with numerous additional updates
to selected MXE packages as detailed below.

GCC has been patched to avoid a size limit for pre-compiled headers (PCH),
back-porting a change from a later version.  This change does not make
static libraries incompatible.

An experimental build of this version of Rtools43 for aarch64 is
available from
[here](https://www.r-project.org/nosvn/winutf8/rtools43-aarch64/) and
unstable experimental snapshots from
[here](https://www.r-project.org/nosvn/winutf8/ucrt3/).  See [this blog
post](https://blog.r-project.org/2023/08/23/will-r-work-on-64-bit-arm-windows/)
for initial information on the R on Windows/aarch64 (ARM64) efforts. No
assumptions should be made on that the aarch64 Rtools (or R support) will
stay in the current form.  The links for the builds should be considered as
temporary and currently the content replaces that from previous version of
Rtools.  The aarch64 support is only part of R-devel (not R 4.3).

These packages have been updated:

```
armadillo 12.0.1 to 12.6.7
blas 3.11.0 to 3.12.0
boost 1.81.0 to 1.84.0
brotli 1.0.9 to 1.1.0
cblas 3.11.0 to 3.12.0
cmake-host 3.24.3 to 3.28.1
curl 7.88.1 to 8.5.0
fontconfig 2.14.2 to 2.15.0
gdal 3.7.2 to 3.8.2
gpgme 1.22.0 to 1.23.2
harfbuzz 8.2.0 to 8.3.0
icu4c 73.2 to 74.1
imagemagick 7.1.1-15 to 7.1.1-25
intel-tbb 2021.10.0 to 2021.11.0
isl 0.16.1 to 0.24
jasper 4.0.0 to 4.1.1
kealib 1.5.1 to 1.5.3
lapack 3.11.0 to 3.12.0
lcms 2.15 to 2.16
libarchive 3.6.2 to 3.7.2
libgcrypt 1.10.2 to 1.10.3
libgsf 1.14.50 to 1.14.51
libraw 0.21.1 to 0.21.2
libsndfile 1.2.0 to 1.2.2
libssh 0.10.5 to 0.10.6
libssh2 1.10.0 to 1.11.0
libuv 1.44.2 to 1.47.0
libvpx 1.13.0 to 1.13.1
libxml2 2.10.4 to 2.12.3
libxslt 1.1.38 to 1.1.39
libzmq de5ee18 to 959a133
minizip 4.0.1 to 4.0.4
openblas 0.3.24 to 0.3.26
opencv 4.8.0 to 4.9.0
openssl 3.1.2 to 3.1.4
pango 1.50.14 to 1.51.0
postgresql 13.12 to 13.13
proj 9.3.0 to 9.3.1
protobuf 21.12 to 25.2
sdl2 2.28.3 to 2.28.5
sqlite 3430100 to 3440200
tiff 4.5.1 to 4.6.0
xz 5.4.4 to 5.4.5
zlib 1.3 to 1.3.1
```

These packages have been added:

```
abseil-cpp 20230802.1
c-ares 1_25_0
grpc 1.60.0
re2 2023-11-01
```

### 5863
Distributed as rtools43-5863-5818.exe.

R packages able to read files using libwebp should be rebuilt and
reinstalled due to a security vulnerability (CVE-2023-2863): this could also
be indirect via libtiff, proj or gdal.  These Rtools libraries use libwebp:
av\*, gdal, Magick\*, mfuuid, opencv\*, sharpyuv, spatialite, tiff, urlmon,
uuid and vpx.

Gdal now supports LERC compression.  R packages linking to gdal need to be
rebuilt/reinstalled to use the feature.

GCC has been updated from 12.2.0 to 12.3.0.  This update only includes
bug-fixes, but does not make static libraries incompatible. The update
allowed e.g. to build latest version of openTBB, building of which crashed
with the previous version.

A fix to bug PR30079 has been back-ported to binutils.  Due to the bug,
linking against an import library could fail with an error, but import
libraries are normally not used with R.

Pkg-config has been added and allows R packages to specify the libraries to
link (linking orders) via MXE packages names, instead of listing them
individually.  This can be useful for packages where recent Rtools updates
required changes in linking orders (even though patches for those changes
were provided to package maintainers by the Rtools maintainer).  For
example, tiff Makevars file can now do:

```
ifeq (,$(shell pkg-config --version 2>/dev/null))
   LIBSHARPYUV = $(or $(and $(wildcard $(R_TOOLS_SOFT)/lib/libsharpyuv.a),-lsharpyuv),)
   PKG_LIBS = -ltiff -ljpeg -lz -lzstd -lwebp $(LIBSHARPYUV) -llzma
else
   PKG_LIBS = $(shell pkg-config --libs libtiff-4)
endif
```

assuming that there is no pkg-config on PATH other than in Rtools (that
is not always the case for github actions).  See the documentation for more
details ([for R 4.3](https://cran.r-project.org/bin/windows/base/howto-R-4.3.html),
[for R-devel](https://cran.r-project.org/bin/windows/base/howto-R-devel.html)).
The documentation includes hints on the issue with github actions.

Pkg-config files have been improved and added in Rtools to make this
possible.  Testing of these included building CRAN packages that are still
downloading pre-compiled static libraries, even when they are in Rtools
(which is in violation of CRAN repository policy, and although patches had
been provided already with Rtools42 for most of these).  These packages can
use pkg-config files for libraries and C flags (headers) as follows:

apcf (geos), av (libavfilter), clustermq (libzmq), curl (curl), eaf (gsl),
gdtools (cairo, freetype2), gert (libgit2), ggiraph (libpng), gpg (gpgme),
gslnls (gsl), hdf5r (hdf5_hl, WRAP = 1_12_0, -DH5_USE_110_API), ijtiff
(libtiff-4), image.textlinedetector (opencv4), jqr (jq), magick (Magick++),
opencv (opencv4), openssl (libssh2), pdftools (poppler-cpp), QF (gsl), ragg
(freetype2, libtiff-4, libjpeg), rcontroll (gsl), redland (redland), redux
(hiredis), RMariaDB (libmariadbclient), RMySQL (libmariadbclient), RPostgres
(libpq), rsvg (librsvg-2.0), rvg (libpng), rzmq (libzmq), sodium
(libsodium), ssh (libssh), strawr (libcurl), surveyvoi (mpfr), svglite
(libpng), systemfonts (freetype2), textshaping (freetype2, harfbuzz,
fribidi), V8 (libv8), vdiffr (libpng), webp (libwebp), websocket (openssl),
xml2 (libxml-2.0), xslt (libexslt).  With some, it is necessary to also set
`PKG_CPPFLAGS` using pkg-config, not just `PKG_LIBS`.

This Rtools update does not require any changes in linking orders of CRAN
packages, but it can be expected that some of the future releases will
require some. While it may be easier for package authors to use pkg-config
rather than specify the linking orders directly, there is no need to switch
at the moment (for packages using libraries from Rtools).

The cross-compilers are now built on Ubuntu 22.04 (previously Ubuntu 20.04)
and link to some libraries available in that distribution.  Users of the
cross-compilers may hence have to update their systems.

Upstream MXE changes have been merged from
`6b9e861453bc81fde71810336a064e418cf4eac0`, with numerous additional updates
to selected MXE packages as detailed below.

An experimental build of Rtools43 for aarch64 has been created and is
supported by the same Rtools code base.  A number of package updates in
Rtools was triggered by these efforts: in some cases, newer versions build
with LLVM (for aarch64) while the older do not.  The experimental builds are
now available from
[here](https://www.r-project.org/nosvn/winutf8/rtools43-aarch64/) and
unstable experimental snapshots from
[here](https://www.r-project.org/nosvn/winutf8/ucrt3/).  See [this blog
post](https://blog.r-project.org/2023/08/23/will-r-work-on-64-bit-arm-windows/)
for initial information on the R on Windows/aarch64 (ARM64) efforts.  No
assumptions should be made on that the aarch64 Rtools (or R support) will
stay in the current form.  The links for the builds should be considered as
temporary.  The aarch64 support is only part of R-devel (not R 4.3).  R
packages downloading pre-compiled static libraries are a significant source
of pain and additional effort for Rtools developments, including the
LLVM/aarch64 support.

These packages have been updated:

```
blosc 1.21.2 to 1.21.5
dbus 1.15.4 to 1.15.8
dlfcn-win32 1.3.1 to 1.4.1
file 5.44 to 5.45
flac 1.4.2 to 1.4.3
freetype 2.13.0 to 2.13.2
freetype-bootstrap 2.13.0 to 2.13.2
freexl 1.0.6 to 2.0.0
fribidi 1.0.12 to 1.0.13
gcc 12.2.0 to 12.3.0
gcc-host 12.2.0 to 12.3.0
gdal 3.6.2 to 3.7.2
glib 2.76.0 to 2.76.5
gmp 6.2.1 to 6.3.0
gnutls 3.6.16 to 3.8.0
gpgme 1.18.0 to 1.22.0
harfbuzz 7.1.0 to 8.2.0
hdf5 1.12.0 to 1.12.1
hiredis 1.1.0 to 1.2.0
icu4c 72.1 to 73.2
ilmbase 2.2.0 to 2.2.1
imagemagick 7.1.1-3 to 7.1.1-15
intel-tbb 9e219e2 to 2021.10.0
json-c 0.16 to 0.17
kealib 1.5.0 to 1.5.1
libassuan 2.5.5 to 2.5.6
libgcrypt 1.10.1 to 1.10.2
libgit2 1.6.2 to 1.7.1
libgpg_error 1.46 to 1.47
libpng 1.6.39 to 1.6.40
libsbml 5.19.0 to 5.20.2
libssh 0.10.4 to 0.10.5
libwebp 1.3.0 to 1.3.2
libxml2 2.10.3 to 2.10.4
libxslt 1.1.37 to 1.1.38
libzmq c59104a to de5ee18
minizip 3.0.8 to 4.0.1
mpfr 4.2.0 to 4.2.1
netcdf 4.9.1 to 4.9.2
nettle 3.8.1 to 3.9.1
openblas 0.3.21 to 0.3.24
opencv 4.7.0 to 4.8.0
openssl 3.0.8 to 3.1.2
pixman 0.33.6 to 0.42.2
poppler 23.03.0 to 23.09.0
postgresql 13.10 to 13.12
proj 9.2.0 to 9.3.0
raptor2 2.0.15 to 2.0.16
sdl2 2.26.4 to 2.28.3
spatialite 5.0.1 to 5.1.0
sqlite 3410100 to 3430100
tiff 4.5.0 to 4.5.1
x264 20180806-2245 to a8b68ebf
xz 5.4.1 to 5.4.4
zlib 1.2.13 to 1.3
zstd 1.5.4 to 1.5.5
```

These packages have been added:

```
brotli 1.0.9
pkgconf-host 1.8.0
```

These packages have been removed:

```
freetds
mesa
qt6-qtbase
qtbase
```

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