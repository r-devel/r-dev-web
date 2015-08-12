options(available_packages_filters =
     c("R_version", "OS_type", "subarch", "CRAN", "duplicates"))

source("common.R")

noinstall <- c('mbest', 'PythonInR', 'iptools', 'RBerkeley', 'StatMethRank', 'EPGLM')
stoplist <- c(stoplist, noinstall)

Sys.setenv(DISPLAY = ':5', NOAWT = "1", RMPI_TYPE = "OPENMPI",
          RGL_USE_NULL = "true", PG_INCDIR = "libpq")


chooseBioCmirror(ind=1)
setRepositories(ind = c(1:5))
update.packages(ask=FALSE)
setRepositories(ind=1)
new <- new.packages()
new <- new[! new %in% stoplist]
if(length(new)) {
    setRepositories(ind = c(1:5,7))
    install.packages(new)
}
