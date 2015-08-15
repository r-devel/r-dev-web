options(available_packages_filters =
     c("R_version", "OS_type", "subarch", "CRAN", "duplicates"))

foo <- row.names(installed.packages(.libPaths()[1]))

chooseBioCmirror(ind = 8)
setRepositories(ind = c(1:4,7))
options(repos = c(getOption('repos'),
        INLA = 'http://www.math.ntnu.no/inla/R/stable/'))

Sys.setenv(DISPLAY = ':5', NOAWT = "1", RMPI_TYPE = "OPENMPI",
          RGL_USE_NULL = "true", PG_INCDIR = "libpq")

Sys.setenv(PKG_CONFIG_PATH = "/usr/local/lib/pkgconfig:/usr/lib/pkgconfig:/usr/local/ggobi/lib/pkgconfig:/Library/Frameworks/GTK+.framework/Resources/lib/pkgconfig")

## fail if done in parallel
ex <- c('rJava', 'nloptr', 'iplots')
install.packages(ex, Ncpus = 1)
foo <- setdiff(foo, c(ex, "ROracle"))
install.packages(foo, Ncpus = 10)
