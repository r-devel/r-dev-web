chooseBioCmirror(ind = 3)
setRepositories(ind = 2)
Sys.setenv(DISPLAY = ':5', MAKE="gmake", GREP = "ggrep")

gcc <- c("DESeq2", "GOSemSim", "RBGL", "Rgraphviz", "Rsamtools", "affxparser", "edgeR", "flowCore",  "pcaMethods", "qpgraph", "rtracklayer", "survcomp")
install.packages(gcc, Ncpus=20)
