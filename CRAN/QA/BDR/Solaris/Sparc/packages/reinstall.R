## parallel will not work as make is involved
foo <- row.names(installed.packages(.libPaths()[1]))

chooseBioCmirror(ind = 5)
setRepositories(ind = c(2:5, ifelse(getRversion() >= "3.1.0", 7,6)))
foo2 <- row.names(available.packages())
foo <- intersect(foo, foo2)
foo <- setdiff(foo, c("RCurl", "RJSONIO", "XML")) # Omegahat duplicates

Sys.setenv(DISPLAY = ':5', MAKE = 'gmake')

gcc <- c("ChemmineR", "DESeq2", "GOSemSim", "RBGL", "Rgraphviz", "Rsamtools", "affxparser", "edgeR", "flowCore",  "pcaMethods", "qpgraph", "survcomp")
foo <- setdiff(foo, gcc)

install.packages(foo, Ncpus = 1)
