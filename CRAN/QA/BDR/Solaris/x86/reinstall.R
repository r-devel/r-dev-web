## parallel will not work as make is involved
foo <- row.names(installed.packages(.libPaths()[1]))

chooseBioCmirror(ind = 5)
setRepositories(ind = 2:6)
foo2 <- row.names(available.packages())
foo <- intersect(foo, foo2)
foo <- setdiff(foo, c("RCurl", "XML")) # Omegahat duplicates

Sys.setenv(DISPLAY = ':5')

gcc <- c("RBGL", "Rgraphviz", "Rsamtools", "edgeR", "flowCore", "qpgraph", "survcomp")
foo <- setdiff(foo, gcc)

install.packages(foo, Ncpus = 1)
