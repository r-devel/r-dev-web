Check results using R-devel on an arm64 ('M1') Mac running macOS 12 'Monterey'
with Xcode/CLT 13.1 and an experimental build of gfortran (a fork of 11.0).

Details as in the R-admin manual, with config.site containing

CC=clang
OBJC=$CC
FC="/opt/R/arm64/gfortran/bin/gfortran -mtune=native"
CXX=clang++
CFLAGS="-falign-functions=8 -g -O2 -Wall -pedantic -Wconversion -Wno-sign-conversion"
CXXFLAGS="-g -O2 -Wall -pedantic -Wconversion -Wno-sign-conversion"
CPPFLAGS=-I/opt/R/arm64/include
LDFLAGS=-L/opt/R/arm64/lib
R_LD_LIBRARY_PATH=/opt/R/arm64/lib

External libraries were where possible installed via minor
modifications to Simon Urbanek's 'recipes' at
https://github.com/R-macos/recipes .  The exceptions are those which
need to use dynamic libraries (JAGS and openmpi).

Currently this uses PROJ 8.1.1, GEOS 3.10.1, GDAL 3.4.0 and gsl 2.7.

pandoc is the Intel Mac version, currently 2.16.2 (and updated often).
(There is a self-contained M1 build available from Homebrew, 
another of 2.14.2 from https://mac.r-project.org/libs-arm64/.)

Java is 17 from https://adoptium.net

JAGS was built from its sources: the script and a tarball are at
https://www.stats.ox.ac.uk/pub/bdr/JAGS-arm64/

There is a testing service for the CRAN M1mac setup at
https://mac.r-project.org/macbuilder/submit.html

Some ways in which this may differ from the CRAN checks:

- Using R-devel not R 4.1.x.
- timezone is Europe/London not Pacific/Auckland
- OS and Command Line Tools are kept up-to-date (at present the CRAN
  check service is running macOS 11 and Xcode/CLT 12, but there are
  plans to update it to macOS 12 and Xcode/CLT 13).
- Later C/C++ compilers, different flags.
- External software is (mainly) kept up-to-date -- see above.
  This includes using Java 17 -- I believe the CRAN checks use a
  patched (by Zulu) Java 11.
  BWidget is installed for HierO
  OpenMPI is installed for Rmpi pbdfMPI
  cargo is installed for baseflow
- 'R' is not on the path -- checking is by 'Rdev'.

Packages with non-default installs:

RVowpalWabbit: --configure-args='--with-boost=/opt/R/arm64'
rgdal: --configure-args='--with-data-copy --with-proj-data=/opt/R/arm64/share/proj'
sf: --configure-args='--with-data-copy --with-proj-data=/opt/R/arm64/share/proj'
udunits2: --configure-args='--with-udunits2-lib=/opt/R/arm64/lib'

Options used for 'R CMD check':

setenv _R_CHECK_FORCE_SUGGESTS_ FALSE
setenv LC_CTYPE en_GB.UTF-8
setenv RMPI_TYPE OPENMPI
setenv R_BROWSER false
setenv R_PDFVIEWER false
setenv OMP_NUM_THREADS 2
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
setenv _R_CHECK_THINGS_IN_TEMP_DIR_EXCLUDE_ "^ompi"
setenv _R_CHECK_MATRIX_DATA_ TRUE

setenv OMP_THREAD_LIMIT 2
setenv R_DEFAULT_INTERNET_TIMEOUT 600
setenv NOAWT 1
setenv RGL_USE_NULL true
setenv WNHOME /usr/local/wordnet-3.1
