stoplist <-
c("CARramps", "HiPLARM", "RAppArmor", "RDieHarder", "RMark", "ROracle", "RQuantLib", "RSAP", "RScaLAPACK", "Rcplex", "Rmosek", "WideLM", "cplexAPI", "cudaBayesreg", "gputools", "magma", "permGPU", "rJavax", "rpud", "rscproxy", "sprint", "rLindo", "rcppbugs", "Rmosek", "REBayes", "ROracle", "ora")

Sys.setenv(DISPLAY = ':5',
           RMPI_TYPE = "OPENMPI",
           RMPI_INCLUDE = "/usr/include/openmpi-x86_64",
           RMPI_LIB_PATH = "/usr/lib64/openmpi/lib")


chooseBioCmirror(ind=3)
setRepositories(ind=1:4)
update.packages(ask=FALSE)
setRepositories(ind=1)
new <- new.packages()
new <- new[! new %in% stoplist]
if(length(new)) install.packages(new)
