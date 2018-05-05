ref <- "../tests-devel"
this <- "gcc8"
op <- file.path("/data/ftp/pub/bdr", this)
source("../pkgdiff2.R")
report(op, readLines('arma_extras'))
