options(available_packages_filters =
     c("R_version", "OS_type", "subarch", "CRAN", "duplicates"))

foo <- row.names(installed.packages(.libPaths()[1]))
if ("ROracle" %in% foo) {
  install.packages("ROracle", INSTALL_opts = "--fake")
  foo <- setdiff(foo, "ROracle")
}

chooseBioCmirror(ind = 3)
setRepositories(ind = c(1:5,7))

Sys.setenv(DISPLAY = ':5',
           RMPI_TYPE = "OPENMPI",
           RMPI_INCLUDE = "/usr/include/openmpi-x86_64",
           RMPI_LIB_PATH = "/usr/lib64/openmpi/lib")

opts <- list(Rserve = "--without-server",
             RNetCDF = "--with-netcdf-include=/usr/include/udunits2",
             udunits2 = "--with-udunits2-include=/usr/include/udunits2")

install.packages(foo, configure.args = opts, Ncpus = 10)

