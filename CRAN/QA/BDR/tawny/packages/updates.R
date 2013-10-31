stoplist <-
c("BRugs", "CARramps", "Causata", "HiPLARM", "PKgraph", 
"RAppArmor", "RDieHarder", "RMySQL", 
"ROracle", "RQuantLib", "RSAP", "RVowpalWabbit", 
"Rcplex", "RcppOctave", "Rpoppler", "TSMySQL", "VBmix", "WideLM",
"cplexAPI", "cudaBayesreg", "dbConnect", "gmatrix", "gputools", 
"magma", "npRmpi", "ora", "permGPU", "qtbase", "qtpaint", 
"qtutils", "rcppbugs", "rLindo", "rpud", "sprint",
"Rmosek", "REBayes", "RProtoBuf", "RPostgreSQL",
"MSeasy", "MSeasyTkGUI", "hypervolume", "npsp",
"ConConPiWiFun", "NeatMap", "Rankcluster", "Rsymphony", "SpatialNP", "bigtabulate", "ccaPP", "cda", "cheddar", "gearman", "maxent", "ngspatial", "pedigree", "planar", "synchronicity", "tmg",
"MNM", "RTextTools")

Sys.setenv(DISPLAY = ':5', NOAWT = "1", RMPI_TYPE = "OPENMPI", RGL_USE_NULL = "true")

setRepositories(ind=1:4)
update.packages(ask=FALSE)
setRepositories(ind=1)
new <- new.packages()
new <- new[! new %in% stoplist]
if(length(new)) install.packages(new)
