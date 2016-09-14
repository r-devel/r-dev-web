## parallel will not work as make is involved
foo <- row.names(installed.packages(.libPaths()[1]))

#chooseBioCmirror(ind = 6)
setRepositories(ind = c(2:5, 7))
foo2 <- row.names(available.packages())
foo <- intersect(foo, foo2)
foo <- setdiff(foo, c("RCurl", "RJSONIO", "XML", "muscle")) # Omegahat duplicates

Sys.setenv(DISPLAY = ':5', MAKE = 'gmake')

gcc <- c("ChemmineR", "DESeq2", "GOSemSim", "RBGL", "Rdisop", "Rgraphviz", "Rhtslib", "Rsamtools", "affxparser", "edgeR", "flowCore", "flowWorkspace", "ncdfFlow", "mzR", "pcaMethods", "qpgraph", "rtracklayer", "survcomp", "gdsfmt")
gcc <- c(gcc, "Rcpp") # BioC extras has an old copy

foo <- setdiff(foo, gcc)

install.packages(foo, Ncpus = 1)
