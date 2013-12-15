chooseBioCmirror(ind = 5)
setRepositories(ind = 2)
Sys.setenv(DISPLAY = ':5', MAKE="gmake", GREP = "ggrep")

gcc <- c("RBGL", "Rgraphviz", "Rsamtools", "affxparser", "edgeR", "flowCore", "qpgraph", "survcomp")
install.packages(gcc, Ncpus=10)
