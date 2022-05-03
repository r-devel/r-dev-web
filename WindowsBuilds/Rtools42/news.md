---
title: "Changes in Rtools42 for Windows"
output: html_document
---

### 5227

Distributed as rtools42-5227-5107.exe.

HTACG HTML Tidy `5.8.0` has been added and is used for packages checks via
`_R_CHECK_RD_VALIDATE_RD2HTML_` or `--as-cran`.

Hiredis has been updated from version `1.0.0` to version `1.0.2`.

Upstream MXE changes have been merged from
`b11aaa7123c59cde7bb5e9ff794c672f54b706c3`, and consequently these additional
packages have been added: `llvm 10.0.0, meson-wrapper 1`. These packages have
been removed: `pe-parse, pe-util` (only needed at build time). These packages
have been updated:

```
atk 2.16.0 to 2.36.0
cmake-host 3.22.1 to 3.22.2
curl 7.81.0 to 7.82.0
dbus 1.13.20 to 1.13.22
expat 2.4.3 to 2.4.8
fontconfig 2.13.1 to 2.14.0
freetds 1.3.6 to 1.3.10
freetype 2.11.1 to 2.12.0
freetype-bootstrap 2.11.1 to 2.12.0
fribidi 1.0.8 to 1.0.11
gdk-pixbuf 2.32.3 to 2.42.6
glib 2.53.7 to 2.70.2
gmp 6.2.0 to 6.2.1
harfbuzz 3.2.0 to 4.2.0
hiredis 1.0.0 to 1.0.2
jasper 2.0.33 to 3.0.3
lcms 2.12 to 2.13
libcroco 0.6.2 to 0.6.13
libgcrypt 1.9.4 to 1.10.1
libgpg_error 1.43 to 1.45
librsvg 2.40.5 to 2.40.21
libxslt 1.1.34 to 1.1.35
mesa 20.3.0 to 22.0.2
mingw-w64 9.0.0 to 10.0.0
mpc 1.1.0 to 1.2.1
mpfr 4.0.2 to 4.1.0
pango 1.37.4 to 1.50.0
poppler 22.01.0 to 22.04.0
postgresql 13.4 to 13.6
qtbase 5.15.2 to 5.15.3
sdl2 2.0.14 to 2.0.20
sqlite 3370200 to 3380200
zlib 1.2.11 to 1.2.12
```

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
