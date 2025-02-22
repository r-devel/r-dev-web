---
title: "Howto: UCRT3 and testing new Rtools for Windows"
author: Tomas Kalibera
output: html_document
---

The download locations for Rtools are available from
[cran.r-project.org](https://cran.r-project.org/bin/windows/Rtools/) as
usual.

This document is (now) only about a system for testing updates to Rtools on
Windows.  It is intended for Rtools maintainers, could be of interest to
people automating R package checks or R enthusiasts at large, but is not
of general interest to R users nor R package authors.

## Evolution of ucrt3 and this document

This document was once named "Howto: UTF-8 as native encoding in R on
Windows with UCRT".

The ucrt3 system was created to enable the transition to UTF-8 as the native
encoding in R on Windows, which required switching to UCRT as the C runtime,
a new toolchain, and updates to R and R packages.  This document provided
instructions on how to build the experimental versions of R and R packages,
how to update R packages to be compatible, how to build the new toolchain
and how to contribute to it.

From March, 2021, the system implemented automated builds and testing. 
Usually several times a week it would provide builds of the new toolchain, a
patched version of R-devel, patched versions of CRAN and required
Bioconductor packages, and checks of CRAN packages.  The check results were
integrated into CRAN website, so available for each CRAN package.  Later
this involved also regular builds of the Rtools installer.

From December 13, 2021, R-devel has been switched to UCRT on Windows.  The
ucrt3 patches for R were merged into R-devel and the CRAN checks of R-devel
were switched to the new toolchain, Rtools42.  From this time, this document
was used by package authors who needed to change their R packages to work on
Windows and the ucrt3 system was still running as an alternative to the main
CRAN checks.  It has been still used to build new versions of Rtools42 and
R-devel snapshots and it served R (CRAN and Bioconductor) package patches
that were installed automatically at package installation time by R-devel.

In March, 2022, the automated patching of R packages in R-devel was
disabled.  This document was transformed into [Howto: Building R 4.2 and
packages on
Windows](https://cran.r-project.org/bin/windows/base/howto-R-4.2.html),
which is an external documentation linked to the R 4.2 release and a similar
document was started for
[R-devel](https://cran.r-project.org/bin/windows/base/howto-R-devel.html)
(the link points to the current version), to eventually include specifics of
the new development version of R.  A new document is always created for a
new version of R, e.g.  R 4.3, 4.4, 4.5, even though the amount of changes
is not always large.  The CRAN/R-project website from that point contained R
builds (R 4.2, R-devel) using Rtools42.  The automated checks ran by ucrt3
system were removed from the CRAN website.  The ucrt3 system may again
diverge from R-devel and may patch CRAN and Bioconductor packages when
needed for testing new versions of Rtools and at this point package authors
don't have to worry about such differences. The automated checks and
automated builds are no longer ran regularly, but manually around the times
when working on new Rtools versions.


This document is available in subversion as

```
https://svn.r-project.org/R-dev-web/trunk/WindowsBuilds/winutf8/ucrt3/howto.html
```

One can use a subversion client to retrieve an older version. 

The history of the transition is also covered by blog posts:

* [Upcoming Changes in R 4.2 on Windows](https://developer.r-project.org/Blog/public/2021/12/07/upcoming-changes-in-r-4.2-on-windows/index.html)
* [Virtual Windows machine for checking R packages](https://developer.r-project.org/Blog/public/2021/03/18/virtual-windows-machine-for-checking-r-packages/index.html)
* [Windows/UTF-8 Toolchain and CRAN Package Checks](https://developer.r-project.org/Blog/public/2021/03/12/windows/utf-8-toolchain-and-cran-package-checks/index.html)
* [Windows/UTF-8 Build of R and CRAN Packages](https://developer.r-project.org/Blog/public/2020/07/30/windows/utf-8-build-of-r-and-cran-packages/index.html)
* [UTF-8 Support on Windows](https://developer.r-project.org/Blog/public/2020/05/02/utf-8-support-on-windows/index.html)

## Why the system was created

For UTF-8 as native encoding on Windows, we needed a new compiler toolchain
and we needed to rebuild all source code with it linked to R and to R
packages (at least code linked to it statically, even though sometimes even
code linked dynamically).

It was clear that a lot of code patching for this will be necessary (R and R
packages use fixed Make files to link, R packaged used to download
pre-compiled static libraries, major upgrades of GCC and MinGW-W64 were
needed and it turn required patching).

Such changes had to be tested by CRAN package checks, and it was clear that
those checks would have to be ran repeatedly as the toolchain would grow and
evolve. There was not a suitable system ready for re-use on Windows.

## Key features

The system automates all steps from sources to package check results:
building the toolchain and libraries, building the Tcl/Tk bundle, building
an Rtools installer, building R and R installer, building binary versions of
CRAN and needed Bioconductor R packages, running checks for those packages.
The automation includes installation of external software on all systems,
including software needed to run packages on Windows.

The system does not depend on external services. The sources are in
[subversion](https://svn.r-project.org/R-dev-web/trunk/WindowsBuilds/winutf8/ucrt3)
run by the R project. It is implemented in shell scripts, PowerShell, and R.
Shell scripts are used for automation even on Windows (used with Msys2).
Parts of it run on Linux and parts on Windows, using interactive docker
containers for isolation and reproducibility. It is designed to run on a
server with many cores (rather than parallizing across machines).

The system differs from "traditional" CRAN package checks in several ways.

It only runs full checks from scratch and tests binary builds of R and R
packages.  Every iteration builds the toolchain and libraries from sources,
using it builds the Tcl/Tk bundle, using those it builds the R installer and
Rtools installer. It installs R via the R installer and builds binary
versions of R packages. It installs R packages from those binary versions
and checks them.

As all the components are versioned in subversion, it flags the individual
builds by the revisions used.  From the name of a tarball/exe/zip file of an
individual component, such as the R installer, one sees which revision
number of the toolchain, of R, and of the automation scripts was used, so
one can find the corresponding sources.

The system is optimized for checking toolchains.  Instead of building all
CRAN packages, it only builds those than need compilation (of C/Fortran/C++
code), so only those than need the toolchain.  For other packages, it uses
the official CRAN builds.  This saves time and disk space.  To allow easy
testing of the built version of R, the system patches R so that the default
contrib URLs for package installation starts with a URL for a special
package repository with only the binary packages built by this system.  So,
R will use these in preference.  To prevent accidental installation of
possibly newer packages from the official CRAN repository, the system had a
safeguard and could have again if needed (R packages built by the system got
a special field into DESCRIPTION, and only packages with that field were
allowed for installation).  The system only builds and installs Bioconductor
packages needed by any of the CRAN packages.

The system uses installation-time patching of packages, which is now part of
R, but not enabled in the released versions (nor in R-devel at the time of
writing).  There is a web repository, synced from subversion, which contains
patches for R packages, indexed simply by package name, and split for CRAN
and Bioconductor.  These patches are automatically applied when the binary
packages are built and the patches are added to the builds for transparency. 
The patches are synced to the web together with the binary builds.  The
patching allows to experiment with changes to the toolchain that would
otherwise require package changes (but then it would no longer really be an
experiment).  Also, with a change that requires re-building of all packages,
it would be impossible to wait for individual package authors to do the
updates (with transition to UCRT, over 100 packages had to be patched, but
many thousands of packages depended on them).  The patching mechanism is
still used by the ucrt3 system when testing new versions of Rtools: it is
not possible to wait for individual package maintainers to update changes,
and sometimes it is better to experiment with the changes and tune them
before providing them to package maintainers.

## Implementation

See [subversion](https://svn.r-project.org/R-dev-web/trunk/WindowsBuilds/winutf8/ucrt3)
for the source code of the system and see comments in the files.

[toolchain_libs](https://svn.r-project.org/R-dev-web/trunk/WindowsBuilds/winutf8/ucrt3/toolchain_libs)
is to build the toolchain and libraries. It is to be run on a Linux machine
or on any machine that can run Linux docker containers. As in the following,
there is a `build_in_docker.sh` script which runs a build iteration in a
docker container. If the container doesn't exist, it is created and all
software needed there is installed, but if it already exists, it is re-used
including partially re-using the build. The container is stopped by the
script at exit and it can be explored later from the command line (but the
main log files are copied out of the container automatically). The toolchain
and libraries are built using MXE (with some updates), which is included in
the source tree.

[tcl_bundle](https://svn.r-project.org/R-dev-web/trunk/WindowsBuilds/winutf8/ucrt3/toolchain_libs)
builds the Tcl/Tk bundle using the toolchain. It is to be run on a Linux
machine or on any machine that can run Linux containers.

[rtools](https://svn.r-project.org/R-dev-web/trunk/WindowsBuilds/winutf8/ucrt3/rtools)
builds the Rtools installer from the toolchain and libraries provided above,
adding Msys2 as build tools. This and all other components built on
Windows requires Msys2 (as it is implemented in Unix shell). The rtools
installer is build in a docker container, which has its own installation of
Msys2 (docker here is used to separate two possibly incompatible Cygwin
runtimes, in addition to reproducibility). This has to be run on Windows
because only Windows can run Windows docker containers.

[r](https://svn.r-project.org/R-dev-web/trunk/WindowsBuilds/winutf8/ucrt3/r)
builds R and R installer. This is run on Windows in a Windows docker
container. There are `.ps1` scripts to install external software needed to
build R. These scripts re-use installers of such software if already
available to prevent excessive downloads on every new run (but as other
containers used in the system, repeated runs normally re-use the containers;
the containers only need to be dropped manually when the set of software to
be installed there changes). 

[r_packages](https://svn.r-project.org/R-dev-web/trunk/WindowsBuilds/winutf8/ucrt3/r_packages)
has scripts to build binary versions of R packages (in a Windows docker
container) and to check all packages (in another Windows docker container).
There are also scripts for checking a single package (in yet another docker
container) with prepared support for on-demand checking, but that is not
regularly used. There is a `.ps1` script to install external software needed
for checking (installed inside the container). 

## Web repository

There is a web [repository](https://www.r-project.org/nosvn/winutf8/ucrt3/)
of builds produced by runs of this system, including builds of Rtools, the
Tcl/Tk bundle, R-devel snapshots, R-patched snapshots, Rtools installer,
CRAN and Bioconductor binary packages (subsets of), patches of the packages
and check results for CRAN packages.  These files are created by these
scripts with more details in the scripts.

***Please note these are not official builds for use, they are only for experimentation.***

These are experimental builds and may differ from R-devel, may have the
patched packages, may have not yet well tested Rtools, may use different
version of Rtools from the one officially for that release of R, may be very
unstable.  The names of the components are slightly different and are
expected to change over time, but are similar to those in Rtools releases
(Rtools >= 42) and are documented in the individual scripts.

## Aarch64

Support for aarch64 architecture via an alternative LLVM toolchain has been
added to "ucrt3" and became part of Rtools 44 release. The scripts were
modified to support both targets, so one can typically build for one of the
target or for both. That the system is based on cross-compilation has been a
key advantage, because powerful machines to build the toolchain and
libraries has not been available when work on the aarch64 support started.

The addition of aarch64 support has been covered by blog posts:

* [R on 64-bit ARM Windows](https://blog.r-project.org/2024/04/23/r-on-64-bit-arm-windows)
* [Will R Work on 64-bit ARM Windows?](https://blog.r-project.org/2023/08/23/will-r-work-on-64-bit-arm-windows)
