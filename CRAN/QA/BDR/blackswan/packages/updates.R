options(available_packages_filters =
     c("R_version", "OS_type", "subarch", "CRAN", "duplicates"))

source('common.R')
stoplist <- c(stoplist, noinstall)

chooseBioCmirror(ind=1)
opts <- list(Rserve = "--without-server",
             udunits2 = "--with-udunits2-include=/usr/include/udunits2")
update.packages(ask=FALSE, configure.args = opts)
setRepositories(ind = 1)
new <- new.packages()
new <- new[! new %in% stoplist]
if(length(new)) {
    setRepositories(ind = c(1:4))
    install.packages(new, configure.args = opts)
}
