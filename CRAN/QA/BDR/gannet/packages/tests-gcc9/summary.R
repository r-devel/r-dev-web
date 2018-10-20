ref <- "../tests-devel"
this <- "gcc9"
op <- file.path("/data/ftp/pub/bdr", this)
source("../pkgdiff2.R")
report(op)
