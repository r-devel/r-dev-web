stoplist <-
c("BRugs", "BTSPAS", "CARramps", "HiPLARM", "PKgraph", 
"RAppArmor", "RDieHarder", "REBayes", "RMessenger", "RMySQL", 
"ROracle", "RProtoBuf", "RQuantLib", "RSAP", "RVowpalWabbit", 
"Rcplex", "RcppOctave", "Rgnuplot", "RiDMC", "Rmosek", "SeqGrapheR", 
"TSMySQL", "VBmix", "WideLM", "beadarrayMSV",
"cplexAPI", "cudaBayesreg", "dbConnect", "gputools", 
"magma", "mmeta", "npRmpi", "permGPU", "qtbase", "qtpaint", 
"qtutils", "rcppbugs", "rggobi", "rpud", "rriskBayes",
"sprint", "tdm")


setRepositories(ind=1:4)
update.packages(ask=FALSE)
setRepositories(ind=1)
new <- new.packages()
new <- new[! new %in% stoplist]
if(length(new)) install.packages(new)
