clang <- grepl("R-[cf]lang", R.home())

options(available_packages_filters =
     c("R_version", "OS_type", "subarch", "CRAN", "duplicates"))
options(timeout = 300)

source('common.R')

stoplist <- c(stoplist, CUDA, noinstall)
if(getRversion() < "4.2.0") stoplist <- c(stoplist, noinstall_pat)

opts <- list(Rserve = "--without-server")
#             udunits2 = "--with-udunits2-include=/usr/include/udunits2")

Sys.setenv(DISPLAY = ':5',
           RMPI_TYPE = "OPENMPI",
           RMPI_INCLUDE = "/usr/include/openmpi-x86_64",
           RMPI_LIB_PATH = "/usr/lib64/openmpi/lib")

#noupdate <- c()
if(clang) {
    Sys.setenv(PKG_CONFIG_PATH = '/usr/local/clang/lib64/pkgconfig:/usr/local/lib64/pkgconfig:/usr/lib64/pkgconfig',
               JAGS_LIB = '/usr/local/clang/lib64',
               PATH = paste("/usr/local/clang/bin", Sys.getenv("PATH"), sep=":"))
    stoplist <- c(stoplist, noinstall_clang, noclang)
    noupdate <- c("V8", "Rdisop", "mzR", noupdate)
} 

if(R.version$status != "Under development (unstable)")
	stoplist <- c(stoplist, noinstall_pat)

## NB: only CRAN and BioC
## also do INLA
#chooseBioCmirror(ind=1)
setRepositories(ind=c(1:4))
options(repos = c(getOption('repos'),
                  INLA = 'https://inla.r-inla-download.org/R/stable/'))

old <- old.packages()
.libPaths(c(.libPaths(), "~/R/test-BioCdata"))

if(!is.null(old)) {
    old <- setdiff(rownames(old), noupdate)
    install.packages(old, configure.args = opts, dependencies=NA)
}
setRepositories(ind=1)
new <- new.packages()
new <- new[! new %in% stoplist]
if(length(new)) {
    setRepositories(ind = c(1:4))
    install.packages(new, configure.args = opts , dependencies=NA)
}
