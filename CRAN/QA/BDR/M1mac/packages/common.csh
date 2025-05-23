#!/bin/csh
setenv DISPLAY :5
set path = (. /Users/ripley/bin /Library/TeX/texbin /opt/R/arm64/bin /usr/local/bin /usr/bin /bin)

limit cputime 30m
setenv OMP_THREAD_LIMIT 2
setenv R_DEFAULT_INTERNET_TIMEOUT 600

setenv _R_CHECK_FORCE_SUGGESTS_ FALSE
setenv LC_CTYPE en_GB.UTF-8
setenv RMPI_TYPE OPENMPI
setenv R_BROWSER false
setenv R_PDFVIEWER false
setenv OMP_NUM_THREADS 2
setenv _R_CHECK_INSTALL_DEPENDS_ true
#setenv _R_CHECK_SUGGESTS_ONLY_ true
setenv _R_CHECK_NO_RECOMMENDED_ true
#setenv _R_CHECK_DOC_SIZES2_ true
setenv _R_CHECK_TIMINGS_ 10
setenv _R_CHECK_DEPRECATED_DEFUNCT_ true
setenv _R_CHECK_CODE_ASSIGN_TO_GLOBALENV_ true
setenv _R_CHECK_CODE_DATA_INTO_GLOBALENV_ true
setenv _R_CHECK_SCREEN_DEVICE_ warn
setenv _R_CHECK_S3_METHODS_NOT_REGISTERED_ true
setenv _R_CHECK_OVERWRITE_REGISTERED_S3_METHODS_ true
#setenv _R_CHECK_CODE_USAGE_WITH_ONLY_BASE_ATTACHED_ TRUE
setenv _R_CHECK_NATIVE_ROUTINE_REGISTRATION_ true
setenv _R_CHECK_FF_CALLS_ registration
setenv _R_CHECK_PRAGMAS_ true
setenv _R_CHECK_COMPILATION_FLAGS_ true
setenv _R_CHECK_COMPILATION_FLAGS_KNOWN_ "-Wconversion -Wno-sign-conversion -Wstrict-prototypes"
setenv _R_CHECK_THINGS_IN_TEMP_DIR_ true
setenv _R_CHECK_THINGS_IN_TEMP_DIR_EXCLUDE_ "^(ompi|dsymutil)"
setenv _R_CHECK_MATRIX_DATA_ TRUE
setenv _R_CHECK_ORPHANED_ true
setenv _R_CHECK_BASHISMS_ true

setenv _R_CHECK_LIMIT_CORES_ true

setenv _R_CHECK_VIGNETTES_SKIP_RUN_MAYBE_ true
setenv _R_CHECK_TESTS_NLINES_ 0
setenv _R_CHECK_VIGNETTES_NLINES_ 0

setenv _R_CHECK_ELAPSED_TIMEOUT_ 30m
setenv _R_CHECK_INSTALL_ELAPSED_TIMEOUT_ 120m
setenv _R_CHECK_TESTS_ELAPSED_TIMEOUT_ 90m
setenv _R_CHECK_BUILD_VIGNETTES_ELAPSED_TIMEOUT_ 90m
setenv _R_CHECK_ONE_VIGNETTE_ELAPSED_TIMEOUT_ 60m

#setenv R_CRAN_WEB https://cran.r-project.org
setenv R_CRAN_WEB file:///Users/ripley/R

setenv NOAWT 1
setenv RGL_USE_NULL true
setenv WNHOME /usr/local/wordnet-3.1

setenv _R_CHECK_XREFS_USE_ALIASES_FROM_CRAN_ TRUE

setenv _R_CHECK_RD_VALIDATE_RD2HTML_ true
setenv _R_CHECK_RD_MATH_RENDERING_ true
