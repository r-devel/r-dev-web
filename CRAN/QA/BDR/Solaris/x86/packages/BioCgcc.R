gcc <- c("BiocParallel", "DESeq2", "DiffBind", "EBImage", "GOSemSim", "RBGL", "Rdisop", "Rgraphviz", "Rsamtools", "affxparser", "apeglm", "destiny", "edgeR", "pcaMethods", "qpgraph", "rtracklayer", "survcomp", "RProtoBufLib", "ncdfFlow", "flowWorkspace","Rhtslib", "csaw")

## For gmake
gcc <- c(gcc, "VariantAnnotation")

if (getRversion() >= "4.0.0")
  gcc <- setdiff(gcc, c('RProtoBufLib','ncdfFlow', 'flowWorkspace'))
## mzR?
