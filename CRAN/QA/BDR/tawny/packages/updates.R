source("common.R")

stoplist <- c(stoplist, "npRmpi",
"ConConPiWiFun", "Rsymphony", "bigtabulate", "cda", "cheddar", "gearman", "maxent", "planar", "synchronicity", "tmg")

Sys.setenv(DISPLAY = ':5', NOAWT = "1", RMPI_TYPE = "OPENMPI",
          RGL_USE_NULL = "true", PG_INCDIR = "libpq")


setRepositories(ind=1:4)
update.packages(ask=FALSE)
setRepositories(ind=1)
new <- new.packages()
new <- new[! new %in% stoplist]
if(length(new)) install.packages(new)
