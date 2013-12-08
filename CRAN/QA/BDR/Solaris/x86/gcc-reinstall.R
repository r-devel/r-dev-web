chooseBioCmirror(ind = 5)
setRepositories(ind = 2)
Sys.setenv(DISPLAY = ':5', MAKE="gmake")

gcc <- c("RBGL", "Rsamtools", "edgeR", "flowCore", "qpgraph", "survcomp")
install.packages(gcc, Ncpus=10)
