ref <- "../tests-devel"
this <- "OpenBLAS"
op <- file.path("/vols/ftp/pub/bdr/Rblas", this)
source("../pkgdiff2.R")
report(op)
