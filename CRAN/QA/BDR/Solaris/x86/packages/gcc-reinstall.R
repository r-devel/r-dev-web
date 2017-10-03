chooseBioCmirror(ind = 1)
setRepositories(ind = 2)
Sys.setenv(DISPLAY = ':5', MAKE="gmake", GREP = "ggrep")

#gcc <- c("ChemmineR","DESeq2", "GOSemSim", "RBGL", "Rdisop", "Rgraphviz", "Rsamtools", "affxparser", "edgeR", "flowCore",  "flowWorkspace", "fmcsR", "ncdfFlow", "pcaMethods", "qpgraph", "rtracklayer", "survcomp")

gcc <- c("ChemmineR","DESeq2", "DiffBind", "GOSemSim", "RBGL", "Rdisop", "Rgraphviz", "Rsamt
ools", "affxparser", "edgeR", "fmcsR", "pcaMethods", "qpgraph", "rtracklayer", "survcomp")

install.packages(gcc, Ncpus=20)
