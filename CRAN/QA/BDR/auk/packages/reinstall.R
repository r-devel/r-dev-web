options(available_packages_filters =
     c("R_version", "OS_type", "subarch", "CRAN", "duplicates"))

foo <- row.names(installed.packages(.libPaths()[1]))

#chooseBioCmirror(ind = 3)
setRepositories(ind = c(1:4,7))

Sys.setenv(DISPLAY = ':5',
           RMPI_TYPE = "OPENMPI",
           RMPI_INCLUDE = "/usr/include/openmpi-x86_64",
           RMPI_LIB_PATH = "/usr/lib64/openmpi/lib")

opts <- list(Rserve = "--without-server",
             RNetCDF = "--with-netcdf-include=/usr/include/udunits2",
             udunits2 = "--with-udunits2-include=/usr/include/udunits2")

opts2 <- list(ROracle = "--fake")

install.packages(foo, configure.args = opts, INSTALL_opts = opts2, Ncpus = 10)
