options(available_packages_filters =
     c("R_version", "OS_type", "subarch", "CRAN", "duplicates"))

source("common.R")

noinstall <- c('mbest', 'PythonInR', 'iptools', 'RBerkeley', 'StatMethRank', 'EPGLM', 'mp', "R2STATS")
stoplist <- c(stoplist, noinstall)

Sys.setenv(DISPLAY = ':5', NOAWT = "1", RMPI_TYPE = "OPENMPI",
          RGL_USE_NULL = "true", PG_INCDIR = "libpq")

#Sys.setenv(PKG_CONFIG_PATH = "/usr/local/lib/pkgconfig:/usr/lib/pkgconfig:/usr/local/ggobi/lib/pkgconfig:/Library/Frameworks/GTK+.framework/Resources/lib/pkgconfig")

tmp <- "PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/usr/lib/pkgconfig:/Library/Frameworks/GTK+.framework/Resources/lib/pkgconfig"
opts <- list(RGtk2 = tmp, cairoDevice = tmp,
             Cairo ="PKG_CONFIG_PATH=/opt/X11/lib/pkgconfig:/usr/local/lib/pkgconfig:/usr/lib/pkgconfig")


chooseBioCmirror(ind=1)
setRepositories(ind = c(1:5))
update.packages(ask=FALSE)
setRepositories(ind=1)
new <- new.packages()
new <- new[! new %in% stoplist]
if(length(new)) {
    setRepositories(ind = c(1:5,7))
    install.packages(new, configure.vars = opts)
}
