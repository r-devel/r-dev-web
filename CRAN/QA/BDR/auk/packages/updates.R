stoplist <-
c("CARramps", "HiPLARM", "RAppArmor", "RDieHarder", "RMark", "ROracle", "RQuantLib", "RSAP", "RScaLAPACK", "Rcplex", "Rhpc", "Rmosek", "WideLM", "cplexAPI", "cudaBayesreg", "gmatrix", "gputools", "magma", "ora", "permGPU", "rJavax", "rpud", "rscproxy", "rLindo", "REBayes", "localsolver")

stoplist <- c(stoplist, "CAGExploreR", "simPopulation")

Sys.setenv(DISPLAY = ':5',
           RMPI_TYPE = "OPENMPI",
           RMPI_INCLUDE = "/usr/include/openmpi-x86_64",
           RMPI_LIB_PATH = "/usr/lib64/openmpi/lib")

options(available_packages_filters =
     c("R_version", "OS_type", "subarch", "CRAN", "duplicates"))

chooseBioCmirror(ind=3)
setRepositories(ind=c(1:5,7))

opts <- list(Rserve = "--without-server",
             RNetCDF = "--with-netcdf-include=/usr/include/udunits2",
             udunits2 = "--with-udunits2-include=/usr/include/udunits2")

update.packages(ask=FALSE, configure.args = opts)
setRepositories(ind=1)
new <- new.packages()
new <- new[! new %in% stoplist]
setRepositories(ind=c(1:5,7))
if(length(new)) install.packages(new)
