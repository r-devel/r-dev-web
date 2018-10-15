options(available_packages_filters =
     c("R_version", "OS_type", "subarch", "CRAN", "duplicates"))

source('common.R')
stoplist <- c(stoplist, noinstall)
if(getRversion() < "3.6.0") stoplist <- c(stoplist, noinstall_pat)

Sys.setenv(DISPLAY = ':5',
           RMPI_TYPE = "OPENMPI",
           RMPI_INCLUDE = "/usr/include/openmpi-x86_64",
           RMPI_LIB_PATH = "/usr/lib64/openmpi/lib",
 	   R_MAX_NUM_DLLS = "150")

chooseBioCmirror(ind=1)
opts <- list(Rserve = "--without-server",
             udunits2 = "--with-udunits2-include=/usr/include/udunits2")
update.packages(ask=FALSE, configure.args = opts)
setRepositories(ind = c(1:4))
setRepositories(ind = 1)
new <- new.packages()
new <- new[! new %in% stoplist]
if(length(new)) {
    setRepositories(ind = c(1:4))
    install.packages(new, configure.args = opts)
}
