
options(available_packages_filters =
     c("R_version", "OS_type", "subarch", "CRAN", "duplicates"))

foo <- row.names(installed.packages(.libPaths()[1]))

#foo <- setdiff(foo, "ROracle")

if(getRversion() >= '3.2.0') {
  chooseBioCmirror(ind = 3)
} else chooseBioCmirror(ind = 3)

setRepositories(ind = c(1:4,7))
options(repos = c(getOption('repos'),
                  INLA = 'http://www.math.ntnu.no/inla/R/stable/'))

Sys.setenv(DISPLAY = ':5',
           RMPI_TYPE = "OPENMPI",
           RMPI_INCLUDE = "/usr/include/openmpi-x86_64",
           RMPI_LIB_PATH = "/usr/lib64/openmpi/lib")

mosek <- path.expand("~/extras/mosek/6")
Sys.setenv(MOSEKLM_LICENSE_FILE = file.path(mosek, "licenses/mosek.lic"),
           PKG_MOSEKHOME = file.path(mosek, "tools/platform/linux64x86"),
           PKG_MOSEKLIB = "mosek64",
           LD_LIBRARY_PATH = file.path(mosek, "tools/platform/linux64x86/bin"))

#Sys.setenv(PATH=paste("/data/blackswan/ripley/extras/bin",
#                      Sys.getenv("PATH"), sep = ":"))


opts <- list(Rserve = "--without-server",
             RNetCDF = "--with-netcdf-include=/usr/include/udunits2",
             udunits2 = "--with-udunits2-include=/usr/include/udunits2")

opts2 <- list(ROracle = "--fake")

install.packages(foo, configure.args = opts, INSTALL_opts = opts2, Ncpus = 30)
