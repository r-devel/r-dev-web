options(available_packages_filters =
     c("R_version", "OS_type", "subarch", "CRAN", "duplicates"))

#foo <- row.names(installed.packages(.libPaths()[1]))

args <- commandArgs()[-(1:3)]
foo <- if(la <- length(args)) {
    if(la == 1L) {
        if(file.exists(args)) readLines(args) else args
    } else args
} else row.names(installed.packages(.libPaths()[1L]))

#options(BioC_mirror="http://mirrors.ebi.ac.uk/bioconductor/")
#options(BioC_mirror="http://bioconductor.statistik.tu-dortmund.de")
options(BioC_mirror = "https://bioconductor.org")

#Sys.setenv(R_BIOC_VERSION = "3.4")

setRepositories(ind = c(1:5, 7))
options(repos = c(getOption('repos'),
        INLA = 'https://www.math.ntnu.no/inla/R/stable/'))

Sys.setenv(DISPLAY = ':5', NOAWT = "1", RMPI_TYPE = "OPENMPI",
          RGL_USE_NULL = "true", PG_INCDIR = "libpq",
	  ODBC_INCLUDE = "/Users/ripley/Sources/iodbc/include")

mosek <- "/opt/mosek/6"
Sys.setenv(MOSEKLM_LICENSE_FILE = "/opt/mosek/6/licenses/mosek.lic",
           PKG_MOSEKHOME = "/opt/mosek/6/tools/platform/osx64x86",
           PKG_MOSEKLIB = "mosek64")

tmp <- "PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/usr/lib/pkgconfig:/Library/Frameworks/GTK+.framework/Resources/lib/pkgconfig"
tmp2 <- "PKG_CONFIG_PATH=/opt/X11/lib/pkgconfig:/usr/local/lib/pkgconfig:/usr/lib/pkgconfig"
opts <- list(RGtk2 = tmp, cairoDevice = tmp, rcqp = tmp, Cairo = tmp2, gdtools = tmp2)
opts2 <- list(ROracle = "--fake")

foo <- setdiff(foo, "rtracklayer")

## fail if done with parallel make
ex <- c('nloptr', 'iplots', 'geoBayes', 'RxODE', 'ECOSolveR', "git2r", 'MonetDBLite')
ex0 <- intersect(ex, foo)
if(length(ex0)) install.packages(ex0, Ncpus = 1)
foo <- setdiff(foo, ex)
install.packages(foo, Ncpus = 10, configure.vars = opts, INSTALL_opts = opts2)
