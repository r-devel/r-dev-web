options(available_packages_filters =
     c("R_version", "OS_type", "subarch", "CRAN", "duplicates"))

source('common.R')

stoplist <- c(stoplist, CUDA, noclang, noinstall)
if(getRversion() < "3.7.0") stoplist <- c(stoplist, noinstall_pat)

opts <- list(Rserve = "--without-server",
             udunits2 = "--with-udunits2-include=/usr/include/udunits2")

Sys.setenv(DISPLAY = ':5',
           RMPI_TYPE = "OPENMPI",
           RMPI_INCLUDE = "/usr/include/openmpi-x86_64",
           RMPI_LIB_PATH = "/usr/lib64/openmpi/lib",
 	   R_MAX_NUM_DLLS = "150"
 	   )


if(grepl("R-[cf]lang", R.home())) {
    Sys.setenv(PKG_CONFIG_PATH = '/usr/local/clang/lib64/pkgconfig:/usr/local/lib64/pkgconfig:/usr/lib64/pkgconfig',
               JAGS_LIB = '/usr/local/clang/lib64',
               PATH = paste("/usr/local/clang/bin", Sys.getenv("PATH"), sep=":"))
    stoplist <- c(stoplist, noinstall_clang)
}

## NB: only CRAN and BioC
#chooseBioCmirror(ind=1)
setRepositories(ind=c(1:4))
update.packages(ask=FALSE, configure.args = opts)
setRepositories(ind=1)
new <- new.packages()
new <- new[! new %in% stoplist]
if(length(new)) {
    setRepositories(ind = c(1:4))
    install.packages(new, configure.args = opts)
}
