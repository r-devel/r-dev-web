options(available_packages_filters =
     c("R_version", "OS_type", "subarch", "CRAN", "duplicates"))

#foo <- row.names(installed.packages(.libPaths()[1]))

args <- commandArgs()[-(1:3)]
foo <- if(la <- length(args)) {
    if(la == 1L) {
        if(file.exists(args)) readLines(args) else args
    } else args
} else row.names(installed.packages(.libPaths()[1L]))


## memory issues
foo2 <- c('RNiftyReg', 'rstan', 'rstanarm', 'mzR', "beanz", "eggCounts", "dfpk")
foo2 <- intersect(foo, foo2)
foo <- setdiff(foo, foo2)

options(BioC_mirror="http://bioconductor.statistik.tu-dortmund.de")
setRepositories(ind = c(1:4))
options(repos = c(getOption('repos'),
                  INLA = 'https://www.math.ntnu.no/inla/R/stable/'))

Sys.setenv(DISPLAY = ':5',
           RMPI_TYPE = "OPENMPI",
           RMPI_INCLUDE = "/usr/include/openmpi-x86_64",
           RMPI_LIB_PATH = "/usr/lib64/openmpi/lib")

opts <- list(Rserve = "--without-server",
             udunits2 = "--with-udunits2-include=/usr/include/udunits2")

#opts2 <- list(ROracle = "--fake")

install.packages(foo, configure.args = opts, Ncpus = 10L)
if(length(foo2)) install.packages(foo2, Ncpus = 1L)
