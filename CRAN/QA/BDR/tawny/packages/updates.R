source("common.R")

stoplist <- c(stoplist, "npRmpi", "SWATmodel")

Sys.setenv(DISPLAY = ':5', NOAWT = "1", RMPI_TYPE = "OPENMPI",
          RGL_USE_NULL = "true", PG_INCDIR = "libpq")


if(getRversion() >= "3.1.0") {
setRepositories(ind = c(1:5,7))
} else {
setRepositories(ind = 1:6)
}
update.packages(ask=FALSE)
setRepositories(ind=1)
new <- new.packages()
new <- new[! new %in% stoplist]
if(length(new)) install.packages(new)
