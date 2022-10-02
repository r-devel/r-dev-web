---
title: "Changes in Rtools42 for Windows"
output: html_document
---

### 5355

Distributed as rtools42-5355-5357.exe.

The biggest changes are in geospatial libraries.  Gdal is now built with
support for kea and blosc.  Spatialite is no longer built with support for
rttopo.  Hdf5 is now built with szip support (using aec library).  Proj
major version has been upgraded to 8, which comes with datum ensembles and
no longer supports PROJ.4.  Gdal minor version has been upgraded to 3.5. 
These changes require adaptations in linking orders in R packages
(Makevars.ucrt files), including ncdf4, rgdal, sf and terra.

Upstream MXE changes have been merged from
`b11aaa7123c59cde7bb5e9ff794c672f54b706c3`.  In addition to numerous package
updates, including GCC (update to 10.4), `qt6-qtbase` has been added and
`llvm` has been removed.  R packages linking to glib-2.0 now also need to
link uuid (R package RcppCWB).

These packages have been added:

```
aec 1.0.6
blosc 1.21.1
kealib 1.4.15
qt6-qtbase 6.3.2
```

These packages have been updated:

```
blas 3.10.0 to 3.10.1
boost 1.78.0 to 1.80.0
cblas 3.10.0 to 3.10.1
cmake-host 3.22.2 to 3.24.1
curl 7.83.0 to 7.83.1
file 5.40 to 5.42
flac 1.3.3 to 1.4.0
freetds 1.3.10 to 1.3.12
freetype 2.12.0 to 2.12.1
freetype-bootstrap 2.12.0 to 2.12.1
gcc 10.3.0 to 10.4.0
gcc-host 10.3.0 to 10.4.0
gdal 3.4.3 to 3.5.2
geos 3.9.1 to 3.9.3
harfbuzz 4.2.0 to 5.1.0
jasper 3.0.3 to 3.0.6
lapack 3.10.0 to 3.10.1
libiconv 1.16 to 1.17
libmariadbclient 3.2.3 to 3.2.7
libtasn1 4.18.0 to 4.19.0
lz4 1.9.3 to 1.9.4
mesa 22.0.2 to 22.1.4
minizip 3.0.3 to 2aa369c
nettle 3.7.3 to 3.8.1
openblas 0.3.6 to 0.3.20
openjpeg 2.4.0 to 2.5.0
openssl 1.1.1o to 1.1.1q
pcre2 10.37 to 10.40
poppler 22.04.0 to 22.09.0
proj 7.2.1 to 8.2.1
qtbase 5.15.3 to 5.15.6
sqlite 3380200 to 3390300
tiff 4.3.0 to 4.4.0
wavpack 5.3.0 to 5.5.0
xz 5.2.5 to 5.2.6
```

These packages have been removed:

```
llvm
rttopo
```

### 5253

Distributed as rtools42-5253-5107.exe (the original unsigned version) and
rtools42-5253-5107-signed.exe (digitally signed, but otherwise the same
file) before R 4.2.1 was released.

HTACG HTML Tidy `5.8.0` has been added and is used for packages checks via
`_R_CHECK_RD_VALIDATE_RD2HTML_` or `--as-cran`.

Upstream MXE changes have been merged from
`b11aaa7123c59cde7bb5e9ff794c672f54b706c3`, and consequently these additional
packages have been added: `llvm 10.0.0, meson-wrapper 1`, and these packages have
been removed: `pe-parse, pe-util` (only needed at build time).

These packages have been updated:

```
atk 2.16.0 to 2.36.0
cmake-host 3.22.1 to 3.22.2
curl 7.81.0 to 7.83.0
dbus 1.13.20 to 1.13.22
expat 2.4.3 to 2.4.8
fontconfig 2.13.1 to 2.14.0
freetds 1.3.6 to 1.3.10
freetype 2.11.1 to 2.12.0
freetype-bootstrap 2.11.1 to 2.12.0
fribidi 1.0.8 to 1.0.11
gdal 3.3.2 to 3.4.3
gdk-pixbuf 2.32.3 to 2.42.6
glib 2.53.7 to 2.70.2
gmp 6.2.0 to 6.2.1
harfbuzz 3.2.0 to 4.2.0
hiredis 1.0.0 to 1.0.2
icu4c 70.1 to 71.1
jasper 2.0.33 to 3.0.3
lcms 2.12 to 2.13
libcroco 0.6.2 to 0.6.13
libgcrypt 1.9.4 to 1.10.1
libgpg_error 1.43 to 1.45
librsvg 2.40.5 to 2.40.21
libxslt 1.1.34 to 1.1.35
mesa 20.3.0 to 22.0.2
mpc 1.1.0 to 1.2.1
mpfr 4.0.2 to 4.1.0
openssl 1.1.1m to 1.1.1o
pango 1.37.4 to 1.50.0
poppler 22.01.0 to 22.04.0
postgresql 13.4 to 13.6
qtbase 5.15.2 to 5.15.3
sdl2 2.0.14 to 2.0.20
sqlite 3370200 to 3380200
zlib 1.2.11 to 1.2.12
```

Building MXE packages for Rtools now requires also these Ubuntu/Debian
packages: python3, python3-mako, python3-setuptools.  See [MXE
documentation](https://mxe.cc/) for the corresponding packages for other
Linux distributions.

Rtools toolchain+libraries bundle now contains also the list of version of
the Rtools MXE packages installed in file installed.list.

MinGW-W64 has been kept at version 9.0.0.  A number of Rtools-specific fixes
has been contributed upstream to MXE.

### 5168

Distibuted as rtools42-5168-5107.exe when R 4.2.0 was released.

The C++ library is built with precise timers (--enable-libstdcxx-time). This
fixes issues with packages such as benchr that depend on these.

The distribution of the cross toolchain has been improved wrt to handling
ccache.  The documentation on building R and packages
([R-4.2.x](https://cran.r-project.org/bin/windows/base/howto-R-4.2.html) and 
[R-devel](https://cran.r-project.org/bin/windows/base/howto-R-devel.html))
has been updated with examples on how to use the cross toolchain.  The
documentation also describes how to set up a build tree of MXE packages
using the cross toolchain bundle, instead of building all needed Rtools MXE
packages from source. 

### 5111 and older

Changes between any two Rtools42 releases can be found in the versioning
system using a subversion client.  To list differences between 5111 and
5168:

```
svn log -r 5111:5168 https://svn.r-project.org/R-dev-web/trunk/WindowsBuilds/winutf8/ucrt3/toolchain_libs
```

And to see the detailed diff:

```
svn diff -r 5111:5168 https://svn.r-project.org/R-dev-web/trunk/WindowsBuilds/winutf8/ucrt3/toolchain_libs
```

The corresponding changes in the Tcl/Tk bundle and Rtools42 installer can be
found the same way in these subversion repositories:

```
https://svn.r-project.org/R-dev-web/trunk/WindowsBuilds/winutf8/ucrt3/tcl_bundle
https://svn.r-project.org/R-dev-web/trunk/WindowsBuilds/winutf8/ucrt3/rtools
```

Please only refer to changes between subversion revisions of Rtools42 distributed at 
[https://cran.r-project.org/bin/windows/Rtools/rtools42/files/](https://cran.r-project.org/bin/windows/Rtools/rtools42/files/).
Intermediate and newer revisions are work in progress and may not be functional.
