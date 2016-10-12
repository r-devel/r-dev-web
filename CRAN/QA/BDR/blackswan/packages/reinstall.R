
options(available_packages_filters =
     c("R_version", "OS_type", "subarch", "CRAN", "duplicates"))

args <- commandArgs()[-(1:3)]
foo <- if(la <- length(args)) {
    if(la == 1L) {
        if(file.exists(args)) readLines(args) else args
    } else args
} else row.names(installed.packages(.libPaths()[1L]))

setRepositories(ind = c(1:5, 7))
options(repos = c(getOption('repos'),
                  INLA = 'https://www.math.ntnu.no/inla/R/stable/'))

Sys.setenv(DISPLAY = ':5',
           RMPI_TYPE = "OPENMPI",
           RMPI_INCLUDE = "/usr/include/openmpi-x86_64",
           RMPI_LIB_PATH = "/usr/lib64/openmpi/lib")

#Sys.setenv(PATH=paste("/data/blackswan/ripley/extras/bin",
#                      Sys.getenv("PATH"), sep = ":"))


opts <- list(Rserve = "--without-server",
             udunits2 = "--with-udunits2-include=/usr/include/udunits2")

opts2 <- list(ROracle = "--fake")

install.packages(foo, configure.args = opts, INSTALL_opts = opts2, Ncpus = 30)
