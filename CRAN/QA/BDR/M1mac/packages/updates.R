options(available_packages_filters =
     c("R_version", "OS_type", "subarch", "CRAN", "duplicates"))
options(timeout = 300)

source("common.R")
stoplist <- c(stoplist, noinstall)

Sys.setenv(DISPLAY = ':5', NOAWT = "1", RMPI_TYPE = "OPENMPI",
          RGL_USE_NULL = "true", PG_INCDIR = "libpq",
	  ODBC_INCLUDE = "/Users/ripley/Sources/iodbc/include")

opts <- list(ROracle = "--fake",
       udunits2 = "--configure-args='--with-udunits2-lib=/opt/R/arm64/lib'",
       RVowpalWabbit = "--configure-args='--with-boost=/opt/R/arm64'")

ex <- c('textshaping') # things not to be updated
ex <- c()

chooseBioCmirror(ind=1)
setRepositories(ind = c(1:4))
old <- old.packages()
if(!is.null(old)) {
    old <- setdiff(rownames(old), ex)
    install.packages(old, type = "source", INSTALL_opts = opts)
}
#update.packages(ask=FALSE, configure.vars = opts)

setRepositories(ind=1)
new <- new.packages()
new <- setdiff(new, stoplist)
if(length(new)) {
    setRepositories(ind = c(1:4))
    install.packages(new, type = "source", INSTALL_opts = opts)
}
