options(available_packages_filters =
     c("R_version", "OS_type", "subarch", "CRAN", "duplicates"))

foo <- row.names(installed.packages(.libPaths()[1]))

options(BioC_mirror="http://mirrors.ebi.ac.uk/bioconductor/")
setRepositories(ind = c(1:4,7))
options(repos = c(getOption('repos'),
        INLA = 'http://www.math.ntnu.no/inla/R/stable/'))

Sys.setenv(DISPLAY = ':5', NOAWT = "1", RMPI_TYPE = "OPENMPI",
          RGL_USE_NULL = "true", PG_INCDIR = "libpq")

#Sys.setenv(PKG_CONFIG_PATH = "/usr/local/lib/pkgconfig:/usr/lib/pkgconfig:/Library/Frameworks/GTK+.framework/Resources/lib/pkgconfig")

tmp <- "PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/usr/lib/pkgconfig:/Library/Frameworks/GTK+.framework/Resources/lib/pkgconfig"
tmp2 <- "PKG_CONFIG_PATH=/opt/X11/lib/pkgconfig:/usr/local/lib/pkgconfig:/usr/lib/pkgconfig"
opts <- list(RGtk2 = tmp, cairoDevice = tmp, Cairo = tmp2)

## fail if done in parallel
ex <- c('rJava', 'nloptr', 'iplots', 'tmvtnorm')
install.packages(ex, Ncpus = 1)
foo <- setdiff(foo, c(ex, "ROracle"))
install.packages(foo, Ncpus = 10, configure.vars = opts)
