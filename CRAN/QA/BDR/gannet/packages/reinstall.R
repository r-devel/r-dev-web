options(available_packages_filters =
     c("R_version", "OS_type", "subarch", "CRAN", "duplicates"))

args <- commandArgs()[-(1:3)]
foo <- if(la <- length(args)) {
    if(la == 1L) {
        if(file.exists(args)) readLines(args) else args
    } else args
} else row.names(installed.packages(.libPaths()[1L]))

except <- c('MatrixModel', 'splusTimeSeries', 'dynamicGraph', 'datamart',
	    'panelr', 'quanteda',  'memisc', 'DelayedArray')
#foo <- setdiff(foo, except)
#foo <- setdiff(foo, "Rcpp")


chooseBioCmirror(ind=1)
## we get Sxslt XMLRPC from omegahat
setRepositories(ind = c(1:4))
options(repos = c(getOption('repos'),
		  #Omegahat = "http://www.omegahat.net/R",
                  INLA = 'https://inla.r-inla-download.org/R/stable/'))

Sys.setenv(DISPLAY = ':5',
           RMPI_TYPE = "OPENMPI",
           RMPI_INCLUDE = "/usr/include/openmpi-x86_64",
           RMPI_LIB_PATH = "/usr/lib64/openmpi/lib"
	   )

if(grepl("R-[cf]lang", R.home()))
    Sys.setenv(PKG_CONFIG_PATH = '/usr/local/clang/lib64/pkgconfig:/usr/local/lib64/pkgconfig:/usr/lib64/pkgconfig',
               JAGS_LIB = '/usr/local/clang/lib64',
               PATH=paste("/usr/local/clang/bin", Sys.getenv("PATH"), sep=":"))

opts <- list(Rserve = "--without-server",
             udunits2 = "--with-udunits2-include=/usr/include/udunits2")

install.packages(foo, configure.args = opts, Ncpus = 25)
