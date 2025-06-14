clang <- grepl("R-[cf]lang", R.home())
clang <- grepl("clang", R.home())

options(available_packages_filters =
     c("R_version", "OS_type", "subarch", "CRAN", "duplicates"))
options(timeout = 300)

source('~/R/packages/common.R')

stoplist <- c(stoplist, CUDA, noinstall)
if(getRversion() < "4.5.0") stoplist <- c(stoplist, noinstall_pat)

opts <- list(Rserve = "--without-server")
#             udunits2 = "--with-udunits2-include=/usr/include/udunits2")

Sys.setenv(DISPLAY = ':5',
           RMPI_TYPE = "OPENMPI",
           RMPI_INCLUDE = "/usr/include/openmpi-x86_64",
           RMPI_LIB_PATH = "/usr/lib64/openmpi/lib")

## set library path the way it is done in the test Makefiles
this <- normalizePath(.Library.site)
new <-
    if(any(grep("MKL", this))) {
        c(this, "~/R/test-dev", "~/R/test-BioCdata")
    } else c(this, "~/R/test-BioCdata")
Sys.setenv("R_LIBS" = paste(new,collapse = ":"))


if(clang) {
    Sys.setenv(PKG_CONFIG_PATH = '/usr/local/clang/lib64/pkgconfig:/usr/local/lib64/pkgconfig:/usr/lib64/pkgconfig',
	       DOWNLOAD_STATIC_LIBV8 = "1",
               JAGS_LIB = '/usr/local/clang/lib64',
               PATH = paste("/usr/local/clang/bin", Sys.getenv("PATH"), sep=":"))
    stoplist <- c(stoplist, noinstall_clang, noclang)
    #noupdate <- c("mlpack",  noupdate)
}

if(R.version$status != "Under development (unstable)")
	stoplist <- c(stoplist, noinstall_pat)

## NB: only CRAN and BioC
## also do INLA
#chooseBioCmirror(ind=1)
setRepositories(ind=c(1:4))
options(repos = c(getOption('repos'),
                  INLA = 'https://inla.r-inla-download.org/R/stable/'))

old <- old.packages(.libPaths()[1])
.libPaths(c(.libPaths(), "~/R/test-BioCdata"))

if(!is.null(old)) {
	if(any(grep("MKL", this))) 
	    .libPaths(c("~/R/test-MKL", "~/R/test-dev", "~/R/test-BioCdata"))
    old <- setdiff(rownames(old), noupdate)
    install.packages(old, configure.args = opts, dependencies=NA)
}

setRepositories(ind=1)
if(any(grep("MKL", this))) {
    ## for MKL we want to install only the ones not in
    ## c("~/R/test-dev", "~/R/test-BioCdata", .Library)
    ## with compiled code, and not revdeps.
    options(available_packages_filters =
            c("R_version", "OS_type", "CRAN", "duplicates"))
    av <- available.packages()
    nc <- row.names(av)[av[, "NeedsCompilation"] == "yes"]
    new <- new.packages(c(this, .Library), available = av)
    new <- new[! new %in% stoplist]
    new <- new[new %in% nc]
    if(length(new)) {
        setRepositories(ind = c(1:4))
        .libPaths(c("~/R/test-MKL", "~/R/test-dev", "~/R/test-BioCdata"))
        install.packages(new, configure.args = opts, dependencies=FALSE)
    }
} else {
     new <- new.packages()
     new <- new[! new %in% stoplist]
     if(length(new)) {
         setRepositories(ind = c(1:4))
         install.packages(new, configure.args = opts, dependencies=NA)
     }
 }

