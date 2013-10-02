stoplist <-
c("BRugs", "BTSPAS", "CARramps", "CARrampsOcl", "Causata", "HiPLARM", "PKgraph", 
"RAppArmor", "RDieHarder", "RMessenger", "RMySQL", 
"ROracle", "RQuantLib", "RSAP", "RVowpalWabbit", 
"Rcplex", "RcppOctave", "Rpoppler", "TSMySQL", "VBmix", "WideLM",
"cplexAPI", "cudaBayesreg", "dbConnect", "gputools", 
"magma", "mmeta", "npRmpi", "ora", "permGPU", "qtbase", "qtpaint", 
"qtutils", "rcppbugs", "rLindo", "rpud", "rriskBayes", "sprint",
"Rmosek", "REBayes", "SpeciesMix")


setRepositories(ind=1:4)
update.packages(ask=FALSE)
setRepositories(ind=1)
new <- new.packages()
new <- new[! new %in% stoplist]
if(length(new)) install.packages(new)
