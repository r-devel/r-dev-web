Check results using R-devel on an arm64 ('M1 Pro') Mac running macOS
14.4.1 'Sonoma' with Xcode/CLT 15.3 (which selects SDK 14.4) and the
build of gfortran (a fork of 12.2) from
https://github.com/R-macos/gcc-12-branch/releases/tag/12.2-darwin-r0.1

Timezone Europe/London
Locale en_GB.UTF-8, LC_COLLATE=C

Details as in the R-admin manual, with config.site containing

CC="clang -mmacos-version-min=14.3"
OBJC=$CC
FC="/opt/gfortran/bin/gfortran -mtune=native"
CXX="clang++ -mmacos-version-min=14.3"
CFLAGS="-falign-functions=8 -g -O2 -Wall -pedantic -Wconversion -Wno-sign-conversion -Wstrict-prototypes"
C17FLAGS="-falign-functions=8 -g -O2 -Wall -pedantic -Wconversion -Wno-sign-conversion -Wno-strict-prototypes"
C90FLAGS="-falign-functions=8 -g -O2 -Wall -pedantic -Wconversion -Wno-sign-conversion -Wno-strict-prototypes"
C99FLAGS="-falign-functions=8 -g -O2 -Wall -pedantic -Wconversion -Wno-sign-conversion -Wno-strict-prototypes"
CXXFLAGS="-g -O2 -Wall -pedantic -Wconversion -Wno-sign-conversion"
CPPFLAGS='-isystem /opt/R/arm64/include'
FFLAGS="-g -O2"
LDFLAGS=-L/opt/R/arm64/lib
R_LD_LIBRARY_PATH=/opt/R/arm64/lib

External libraries are where possible installed via minor
modifications to Simon Urbanek's 'recipes' at
https://github.com/R-macos/recipes .  The main exceptions are those
which need to use dynamic libraries (such as openmpi).

Currently this uses PROJ 9.4.0, GEOS 3.12.1, GDAL 3.8.4.
(GDAL needs manual patching of gdal-config.)

pandoc is the arm64 Mac version, currently 3.1.13 (and updated often).

Java is 21.0.2 from https://adoptium.net

JAGS is a binary install from 
https://sourceforge.net/projects/mcmc-jags/files/JAGS/4.x/Mac%20OS%20X/

ghoatscript is 10.03.0 from MacTeX 2024.

There is a testing service for the CRAN M1mac setup at
https://mac.r-project.org/macbuilder/submit.html .  Some ways in which
this may differ from the CRAN checks:

- Using R-devel not R 4.[234].x
- timezone is Europe/London not Pacific/Auckland
- OS and Command Line Tools are kept up-to-date (at present the CRAN
    check service is running macOS 11, and Xcode/CLT 14.0.3 with the
    macOS11 SDK.  But R was built with CLT 14.0.0).
- Later C/C++ compilers, different flags.
  Apple clang 14.0.3 it seems was a major update from 14.0.0, with
    many aspects of LLVM clang 15/16 having been ported.
    Versions 15.0.0 seem a minor update from 14.0.3.
- External software is (mainly) kept up-to-date -- see above.
    This includes using Java 21 and cmake, currently 3.29.0.
    OpenMPI is installed for Rmpi, bigGP and pbdMPI, currently 5.0.1.
- Package INLA is installed -- requires a binary install on Macs.

Packages with non-default installs:

sf: --configure-args='--with-data-copy --with-proj-data=/opt/R/arm64/share/proj'

Several BioC packages have needed patching, currently EBImage Rdisop

Options used for 'R CMD check':

limit stacksize 20M
setenv _R_CHECK_FORCE_SUGGESTS_ FALSE
setenv LC_CTYPE en_GB.UTF-8
setenv RMPI_TYPE OPENMPI
setenv R_BROWSER false
setenv R_PDFVIEWER false
setenv _R_CHECK_INSTALL_DEPENDS_ true
#setenv _R_CHECK_SUGGESTS_ONLY_ true
setenv _R_CHECK_NO_RECOMMENDED_ true
setenv _R_CHECK_TIMINGS_ 10
setenv _R_CHECK_DEPRECATED_DEFUNCT_ true
setenv _R_CHECK_CODE_ASSIGN_TO_GLOBALENV_ true
setenv _R_CHECK_CODE_DATA_INTO_GLOBALENV_ true
setenv _R_CHECK_SCREEN_DEVICE_ warn
setenv _R_CHECK_S3_METHODS_NOT_REGISTERED_ true
setenv _R_CHECK_OVERWRITE_REGISTERED_S3_METHODS_ true
setenv _R_CHECK_NATIVE_ROUTINE_REGISTRATION_ true
setenv _R_CHECK_FF_CALLS_ registration
setenv _R_CHECK_PRAGMAS_ true
setenv _R_CHECK_COMPILATION_FLAGS_ true
setenv _R_CHECK_COMPILATION_FLAGS_KNOWN_ "-Wconversion -Wno-sign-conversion"
setenv _R_CHECK_THINGS_IN_TEMP_DIR_ true
setenv _R_CHECK_THINGS_IN_TEMP_DIR_EXCLUDE_ "^(ompi|dsymutil)"
setenv _R_CHECK_MATRIX_DATA_ TRUE
setenv _R_CHECK_ORPHANED_ true
setenv _R_CHECK_BROWSER_NONINTERACTIVE_ true
setenv _R_CHECK_MBCS_CONVERSION_FAILURE_ true

setenv _R_CHECK_RD_VALIDATE_RD2HTML_ true
setenv _R_CHECK_RD_MATH_RENDERING_ true
setenv _R_CHECK_VALIDATE_UTF8_ true
(needed for macOS 14.1 to avoid the check process segfaulting)
setenv _R_DEPRECATED_IS_R_ error

setenv R_DEFAULT_INTERNET_TIMEOUT 600
setenv NOAWT 1
setenv RGL_USE_NULL true
setenv WNHOME /usr/local/wordnet-3.1

setenv _R_CHECK_XREFS_USE_ALIASES_FROM_CRAN_ TRUE

setenv _R_CHECK_RD_VALIDATE_RD2HTML_ true
setenv _R_CHECK_RD_MATH_RENDERING_ true

and cosmetically

setenv _R_CHECK_VIGNETTES_SKIP_RUN_MAYBE_ true
setenv _R_CHECK_TESTS_NLINES_ 0
setenv _R_CHECK_VIGNETTES_NLINES_ 0

A parallel make is used and packages are checked in parallel --
installing or checking a single package may use up to 8 CPUs.
