clang <- grepl("R-[cf]lang", R.home())
options(available_packages_filters =
     c("R_version", "OS_type", "subarch", "CRAN", "duplicates"))

args <- commandArgs()[-(1:3)]
foo <- if(la <- length(args)) {
    if(la == 1L) {
        if(file.exists(args)) readLines(args) else args
    } else args
} else {
   row.names(installed.packages(.libPaths()[1L]))
}

noupdate <- character()
## also in common.R
#noupdate <- c('MSnbase')

foo <- setdiff(foo, noupdate)

chooseBioCmirror(ind=1)
setRepositories(ind = c(1:4))
options(repos = c(getOption('repos'),
		  CRANextra = "https://www.stats.ox.ac.uk/pub/RWin",
                  INLA = 'https://inla.r-inla-download.org/R/stable/'))

options(timeout = 300)

Sys.setenv(DISPLAY = ':5',
           RMPI_TYPE = "OPENMPI",
           RMPI_INCLUDE = "/usr/include/openmpi-x86_64",
           RMPI_LIB_PATH = "/usr/lib64/openmpi/lib"
	   )

if(clang) {
#    options(repos = c("file:///data/gannet/ripley/R/myrepo", getOption('repos')))
    Sys.setenv(PKG_CONFIG_PATH = '/usr/local/clang/lib64/pkgconfig:/usr/local/lib64/pkgconfig:/usr/lib64/pkgconfig',
               JAGS_LIB = '/usr/local/clang/lib64',
               PATH=paste("/usr/local/clang/bin", Sys.getenv("PATH"), sep=":"))
    ex <- c('V8', 'Rdisop', 'mzR', 'EBImage', "x13binary")
    foo <- setdiff(foo, ex)
}

opts <- list(Rserve = "--without-server")

install.packages(foo, configure.args = opts, Ncpus = 25)
