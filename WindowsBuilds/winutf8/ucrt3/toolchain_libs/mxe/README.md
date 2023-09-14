This is a "fork" of https://github.com/mxe/mxe (with website at
https://mxe.cc/). This fork adds several MXE packages, patches some existing
MXE packages and updates other, as needed by R CRAN packages and Rtools.

All the changes should be mergeable and be merged upstream after some
necessary cleanups and testing with MXE packages not used with R.  Some
of the changes may be specific to UCRT, static compilation and 64-bit
builds.  Also, this "fork" has a custom settings.mk for Rtools with a
pre-defined subset of MXE packages to build.

Non-R MXE users may use this as an inspiration when fixing issues in
selected MXE packages.

New users of MXE from the R community are invited to read 

for R-devel: https://cran.r-project.org/bin/windows/base/howto-R-devel.html
for R 4.3: https://cran.r-project.org/bin/windows/base/howto-R-4.3.html

to get started and to learn how this connects to Rtools. The rest of this is
original MXE documentation.

As this is not the official MXE, it cannot be used with the APT repository
of pre-build cross-compilers and libraries (they would be of different
versions and at the time of writing not UCRT).

# MXE (M cross environment)

[![License][license-badge]][license-page]

[license-page]: LICENSE.md
[license-badge]: https://img.shields.io/badge/License-MIT-brightgreen.svg

[![Async Chat (Trial))](https://img.shields.io/badge/zulip-join_chat-brightgreen.svg)](https://mxe.zulipchat.com/)

MXE (M cross environment) is a GNU Makefile that compiles a cross
compiler and cross compiles many free libraries such as SDL and
Qt. Thus, it provides a nice cross compiling environment for
various target platforms, which:

  * is designed to run on any Unix system
  * is easy to adapt and to extend
  * builds many free libraries in addition to the cross compiler
  * can also build just a subset of the packages, and automatically builds their dependencies
  * downloads all needed packages and verifies them by their checksums
  * is able to update the version numbers of all packages automatically
  * directly uses source packages, thus ensuring the whole build mechanism is transparent
  * allows inter-package and intra-package parallel builds whenever possible
  * bundles [ccache](https://ccache.samba.org) to speed up repeated builds
  * integrates well with autotools, cmake, qmake, and hand-written makefiles.
  * has been in continuous development since 2007 and is used by several projects

## Supported Toolchains

  * Runtime: MinGW-w64
  * Host Triplets:
    - `i686-w64-mingw32`
    - `x86_64-w64-mingw32`
  * Packages:
    - static
    - shared
  * GCC Threading Libraries (`winpthreads` is always available):
    - [posix](https://github.com/mxe/mxe/pull/958) [(default)](https://github.com/mxe/mxe/issues/2258)
    - win32 (supported by limited amount packages)
  * GCC Exception Handling:
    - Default
      - i686: sjlj
      - x86_64: seh
    - [Alternatives (experimental)](https://github.com/mxe/mxe/pull/1664)
      - i686: dw2
      - x86_64: sjlj

Please see [mxe.cc](https://mxe.cc/) for further information and package support matrix.

## Build Dependencies

For some packages additional dependencies are required to be installed in order to build:

* Python 3

## Usage

You can use the `make` command to start the build.  

Below *an example* of cross-compiling the GTK3 project to one statically linked Windows 64-bit library:

```sh
make gtk3 -j 8 MXE_TARGETS='x86_64-w64-mingw32.static'
```

Please see [mxe.cc](https://mxe.cc/) for more information about how-to build the MXE project.

## Packages

Within the [MXE makefiles](src) we either define `$(PKG)_GH_CONF` or `$(PKG)_URL`, which will be used to download the package.  
Next the checksum will be validated of the downloaded archive file (sha256 checksum).

Updating a package or updating checksum is all possible using the make commands, see [usage for more info](https://mxe.cc/#usage).

## Shared Library Notes
There are several approaches to recursively finding DLL dependencies (alphabetical list):
  * [go script](https://github.com/desertbit/gml/blob/master/cmd/gml-copy-dlls/main.go)
  * [pe-util](https://github.com/gsauthof/pe-util) packaged with [mxe](https://github.com/mxe/mxe/blob/master/src/pe-util.mk)
  * [python script](https://github.com/mxe/mxe/blob/master/tools/copydlldeps.py)
  * [shell script](https://github.com/mxe/mxe/blob/master/tools/copydlldeps.md)
