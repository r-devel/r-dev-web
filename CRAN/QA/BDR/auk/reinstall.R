foo <- row.names(installed.packages(.libPaths()[1]))
if ("ROracle" %in% foo) {
  install.packages("ROracle", INSTALL_opts = "--fake")
  foo <- setdiff(foo, "ROracle")
}

chooseBioCmirror(ind = 5)
setRepositories(ind = 1:6)

Sys.setenv(DISPLAY = ':5',
           RMPI_TYPE = "OPENMPI",
           RMPI_INCLUDE = "/usr/include/openmpi-x86_64",
           RMPI_LIB_PATH = "/usr/lib64/openmpi/lib")

mosek <- path.expand("~/Sources/mosek/6")
Sys.setenv(MOSEKLM_LICENSE_FILE = file.path(mosek, "licenses/mosek.lic"),
           PKG_MOSEKHOME = file.path(mosek, "tools/platform/linux64x86"),
           PKG_MOSEKLIB = "mosek64",
           LD_LIBRARY_PATH = file.path(mosek, "tools/platform/linux64x86/bin"))

opts <- list(Rserve = "--without-server",
             RNetCDF = "--with-netcdf-include=/usr/include/udunits2",
             udunits2 = "--with-udunits2-include=/usr/include/udunits2")

install.packages(foo, configure.args = opts, Ncpus = 10)

