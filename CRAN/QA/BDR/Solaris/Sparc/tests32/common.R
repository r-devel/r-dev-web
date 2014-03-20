stoplist <- c("rggobi", "PKgraph", "beadarrayMSV", "SeqGrapheR",
      "Rcell", "RockFab", "gitter", # EBImage
      "MSeasy", "MSeasyTkGUI",
      "MetaSKAT", # little-endian only 
      "RMySQL", "TSMySQL", "dbConnect", "Causata",
      "BRugs", "CARramps", "CARrampsOcl", "GridR", "OpenCL",
      "RBerkeley", "RDieHarder", "RMark", "RMongo", "ROAuth", "ROracle",
      "RProtoBuf", "RQuantLib", "RVowpalWabbit", "Rcplex", "Rhpc", "RiDMC",
      "Rmosek", "VBmix", "WideLM", "cmprskContin",
      "cplexAPI", "cudaBayesreg", "gputools", "gmatrix", "magma", "permGPU",
      "qtbase", "qtpaint", "qtutils", "rJavax", "rmongodb",
      "rpud", "rpvm", "rscproxy", "rzmq", "twitteR",
      "Rpoppler", "Rsymphony", "ROI.plugin.symphony",
      "RcppOctave", "HiPLARM", "RAppArmor", "RSAP", "REBayes", "ora", "rLindo")

fakes <- "ROracle"

ll <- c("## Fake installs",
        paste(fakes, "-OPTS = --install=fake", sep=""))
writeLines(ll, "Makefile.fakes")

recommended <-
    c("KernSmooth", "MASS", "Matrix", "boot", "class", "cluster",
      "codetools", "foreign", "lattice", "mgcv", "nlme", "nnet",
      "rpart", "spatial", "survival")

gcc <- 
    c("BayesXsrc", "ElectroGraph", "GWAtoolbox", "LDExplorer", "MCMCpack", 
      "MasterBayes", "PKI", "PReMiuM", "RGtk2", "RJSONIO", "RSclient", 
      "Ratings", "Rcpp", "STARSEQ", "bayesSurv", "biganalytics", "bigmemory", 
      "bigtabulate", "chords", "cldr", "dpmixsim", "fts", "glasso", 
      "glmnet", "gnmf", "gof", "intervals", "mRm", "medSTC", "mixcat", 
      "phcfM", "rbamtools", "rcppbugs", "smoothSurv", "sparsenet", "tgp")

## avoid issues with __F95_sign
gcc <- c(gcc, "deSolve", "fGarch", "quadprog", "quantreg", "robustbase")

Sys.setenv("OPENSSL_INCLUDES" = "/opt/csw/include")

