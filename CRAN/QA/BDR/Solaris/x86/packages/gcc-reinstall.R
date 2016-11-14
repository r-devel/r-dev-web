#chooseBioCmirror(ind = 6)
setRepositories(ind = 2)
Sys.setenv(DISPLAY = ':5', MAKE="gmake", GREP = "ggrep")

gcc <- c("ChemmineR","DESeq2", "GOSemSim", "RBGL", "Rdisop", "Rgraphviz", "Rsamtools", "affxparser", "edgeR", "flowCore",  "flowWorkspace", "ncdfFlow", "pcaMethods", "qpgraph", "rtracklayer", "survcomp")

install.packages(gcc, Ncpus=20)
