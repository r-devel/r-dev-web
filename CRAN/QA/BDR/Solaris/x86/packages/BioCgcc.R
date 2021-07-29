gcc <- c("BiocParallel", "DESeq2", "DiffBind", "EBImage", "GOSemSim", "RBGL", "Rdisop", "Rgraphviz", "Rsamtools", "affxparser", "apeglm", "dada2", "destiny", "edgeR", "pcaMethods", "qpgraph", "rtracklayer", "survcomp", "RProtoBufLib", "ncdfFlow", "flowWorkspace","Rhtslib", "csaw", "BiocNeighbors")

## For gmake
gcc <- c(gcc, "VariantAnnotation", "rhdf5filters")

gcc <- setdiff(gcc, c('DiffBind', 'RProtoBufLib','ncdfFlow', 'flowWorkspace'))
## mzR?
