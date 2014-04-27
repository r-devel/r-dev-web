options(available_packages_filter =
     c("R_version", "OS_type", "subarch", "CRAN", "duplicates"))

foo <- row.names(installed.packages(.libPaths()[1]))

chooseBioCmirror(ind = 3)
setRepositories(ind = c(1:5,7))

Sys.setenv(DISPLAY = ':5', NOAWT = "1", RMPI_TYPE = "OPENMPI",
          RGL_USE_NULL = "true", PG_INCDIR = "libpq")

## fails if done in parallel
ex <- c('rJava', 'nloptr','clusterCrit','excursions', 'iplots')
install.packages(ex, Ncpus = 1)
foo <- setdiff(foo, c(ex, "ROracle"))
install.packages(foo, Ncpus = 10)
install.packages('frailtypack')
