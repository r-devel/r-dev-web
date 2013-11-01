source("common.R")

stoplist <- c(stoplist, "npRmpi",
"ConConPiWiFun", "Rankcluster", "Rsymphony", "bigtabulate", "ccaPP", "cda", "cheddar", "gearman", "maxent", "pedigree", "planar", "synchronicity", "tmg")

Sys.setenv(DISPLAY = ':5', NOAWT = "1", RMPI_TYPE = "OPENMPI", RGL_USE_NULL = "true")

setRepositories(ind=1:4)
update.packages(ask=FALSE)
setRepositories(ind=1)
new <- new.packages()
new <- new[! new %in% stoplist]
if(length(new)) install.packages(new)
