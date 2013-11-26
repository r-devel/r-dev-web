foo <- row.names(installed.packages(.libPaths()[1]))

chooseBioCmirror(ind = 5)
if(getRversion() >= "3.1.0") {
setRepositories(ind = c(1:5,7))
} else {
setRepositories(ind = 1:6)
}

Sys.setenv(DISPLAY = ':5', NOAWT = "1", RMPI_TYPE = "OPENMPI",
          RGL_USE_NULL = "true", PG_INCDIR = "libpq")

## fails if done in parallel
ex <- c('rJava', 'nloptr','clusterCrit','excursions', 'iplots','frailtypack')
install.packages(ex, Ncpus = 1)
foo <- setdiff(foo, c(ex, "ROracle", "Rsymphony", "maxent", "ncdf4"))
install.packages(foo, Ncpus = 10)
