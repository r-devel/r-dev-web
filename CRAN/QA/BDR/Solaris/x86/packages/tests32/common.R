source("../stoplist.R")

## gfortran
gcc <- c("glasso", "glmnet")

## C++ linkage: but first 3 use Rcpp
gcc <- c(gcc, "RProtoBuf", "V8", "magick", "rgdal", "sf")

## nimble and rbamtools are C++11, so use g++ anyway
gcc <-
    c(gcc, "BayesXsrc", "MCMCpack", "SKAT", "climdex.pcic", "dpmixsim", "fbati",
      "fts", "phreeqc", "phcfM", "tgp")

gcc <- c(gcc, "Rcpp", "RcppArmadillo", "RcppEigen")
gcc <- c(gcc, "SKAT", "funcy", "nimble")

## compile stan models
gcc <- c(gcc, "BANOVA", "prophet")

## Next bunch need C++11 for CC
gcc <- c(gcc, "RandomFields", "RandomFieldsUtils", "crs", "RSiena")
gcc <- c(gcc,
         "PhyloMeasures", # CC gives compilation error
         "RGtk2", # OpenCSW headers
         "RJSONIO", # uses snprintf
         "RcppParallel", # stated requirement
         "Rrdrand", # segfaults
	 "bayesSurv", "smoothSurv", # Scythe issues
         "bigalgebra", # munmap declaration in BH
         "deSolve", # installs with CC but changes results
         "freetypeharfbuzz", # Error: Narrowing conversion
         "jqr", # syntax error in libjq C header
         "mapfit", # uses sqrt not std::sqrt
         "rgeos", # compiles with CC but does not work
         "rzmq", # configure fails, no explanation
         "subprocess", # does not compile with CC: but is C++11
         "tuneR" # inline gcc-style asm in C
         )


Sys.setenv("OPENSSL_INCLUDES" = "/opt/csw/include", CURL_INCLUDES = "/opt/csw/include", "V8_INCLUDES" = "/opt/csw/include")

av <- function()
{
    ## setRepositories(ind = 1) # CRAN
    options(available_packages_filters =
            c("R_version", "OS_type", "CRAN", "duplicates"))
    av <- available.packages(contriburl = CRAN)[, c("Package", "Version", "Repository")]
    av <- as.data.frame(av, stringsAsFactors = FALSE)
    path <- with(av, paste0(Repository, "/", Package, "_", Version, ".tar.gz"))
    av$Repository <- NULL
    av$Path <- sub(".*contrib/", "../contrib/", path)
    av$mtime <- file.info(av$Path)$mtime
    names(av) <- c("name", "Version", "path", "mtime")
    av[order(av$name), ]
}
