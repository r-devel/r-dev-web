stoplist <-
c("CARramps", "HiPLARM", "DeducerMMR", "RAppArmor", "RDF", "RDieHarder", "RMark", "RMongo", "ROracle", "ROracleUI", "RQuantLib", "RSAP", "RScaLAPACK", "Rcplex", "Rmosek", "WideLM", "cplexAPI", "cudaBayesreg", "gputools", "magma", "permGPU", "rJavax", "rpud", "rscproxy", "sprint", "RcppOctave", "npRmpi")

setRepositories(ind=1:4)
update.packages(ask=FALSE)
setRepositories(ind=1)
new <- new.packages()
new <- new[! new %in% stoplist]
if(length(new)) install.packages(new)
