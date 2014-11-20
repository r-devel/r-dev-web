#chooseBioCmirror(ind = 5)
setRepositories(ind = 2)
Sys.setenv(DISPLAY = ':5', MAKE="gmake", GREP = "ggrep")

gcc <- c("ChemmineR", "DESeq2", "GOSemSim", "RBGL", "Rgraphviz", "Rsamtools", "affxparser", "edgeR", "flowCore",  "pcaMethods", "qpgraph", "rtracklayer", "survcomp")
install.packages(gcc, Ncpus=10)
