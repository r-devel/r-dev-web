options(available_packages_filters =
     c("R_version", "OS_type", "subarch", "CRAN", "duplicates"))

args <- commandArgs()[-(1:3)]
foo <- if(la <- length(args)) {
    if(la == 1L) {
        if(file.exists(args)) readLines(args) else args
    } else args
} else row.names(installed.packages(.libPaths()[1L]))

#foo <- setdiff(foo, 'S4Vectors')

chooseBioCmirror(ind=1)
if(getRversion() < "3.5.0") {
  options(BioC_mirror="http://mirrors.ebi.ac.uk/bioconductor")
  setRepositories(ind = c(1:4))
}
options(repos = c(getOption('repos'),
		  Omegahat = "http://www.omegahat.net/R",
                  INLA = 'https://www.math.ntnu.no/inla/R/stable/'))

Sys.setenv(DISPLAY = ':5',
           RMPI_TYPE = "OPENMPI",
           RMPI_INCLUDE = "/usr/include/openmpi-x86_64",
           RMPI_LIB_PATH = "/usr/lib64/openmpi/lib",
	   R_MAX_NUM_DLLS = "150"
	   )

if(grepl("R-[cf]lang", R.home()))
    Sys.setenv(PKG_CONFIG_PATH = '/usr/local/clang/lib64/pkgconfig:/usr/local/lib64/pkgconfig:/usr/lib64/pkgconfig',
               JAGS_LIB = '/usr/local/clang/lib64',
               PATH=paste("/usr/local/clang/bin", Sys.getenv("PATH"), sep=":"))



#mosek <- path.expand("~/Sources/mosek/6")
#Sys.setenv(MOSEKLM_LICENSE_FILE = file.path(mosek, "licenses/mosek.lic"),
#           PKG_MOSEKHOME = file.path(mosek, "tools/platform/linux64x86"),
#           PKG_MOSEKLIB = "mosek64",
#           LD_LIBRARY_PATH = file.path(mosek, "tools/platform/linux64x86/bin"))

opts <- list(Rserve = "--without-server",
             udunits2 = "--with-udunits2-include=/usr/include/udunits2")

install.packages(foo, configure.args = opts, Ncpus = 25)
