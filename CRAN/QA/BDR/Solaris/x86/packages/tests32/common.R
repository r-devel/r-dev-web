stoplist <- c("rggobi", "PKgraph", "beadarrayMSV", "clusterfly", "SeqGrapheR",
      "Rcell", "RockFab", "gitter", # EBImage
      "MSeasy", "MSeasyTkGUI",
      "RMySQL", "TSMySQL", "dbConnect", "Causata",  "compendiumdb",
      "BRugs","CARramps", "CARrampsOcl", "GridR", "OpenCL",
      "RBerkeley", "RDieHarder", "RMark", "RMongo", "ROracle",
      "RProtoBuf", "RQuantLib", "RVowpalWabbit", "RcppRedis", "Rcplex", "Rhpc",
      "Rmosek", "VBmix", "WideLM", "cmprskContin",
      "cplexAPI", "cudaBayesreg", "gputools", "gmatrix", "magma", "permGPU",
      "qtbase", "qtpaint", "qtutils", "rJavax", "rmongodb",
      "rpud", "rpvm", "rscproxy", "rzmq", "twitteR",
      "Rpoppler", "Rsymphony", "ROI.plugin.symphony", "fPortfolio", "BLCOP",
      "RcppOctave", "HiPLARM", "RAppArmor", "RSAP", "REBayes", "ora",
      "rLindo", "localsolver", "Boom", "BoomSpikeSlab", "bsts",
       "iFes", "rSPACE", "RcppAPT",
       "V8", "minimist", "js", "nFCA", "rjade", "daff")


WindowsOnly <- c("BiplotGUI", "MDSGUI", "R2MLwiN", "R2PPT", "R2wd", "RPyGeo", "RWinEdt", "TinnR", "blatr", "excel.link", "installr")

stoplist <- c(stoplist, WindowsOnly, "BayesXsrc", "R2BayesX")


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
      "Ratings", "STARSEQ", "TDA", "bayesSurv", "biganalytics", "bigmemory", 
      "bigtabulate", "chords", "cldr", "dpmixsim", "fbati", "fts", "glasso", 
      "glmnet", "gnmf", "gof", "intervals", "mRm", "medSTC", "mixcat", 
      "phreeqc", "phcfM", "rbamtools", "rcppbugs", "smoothSurv", "sparsenet", "tgp")

## compiler ICEs
gcc <- c(gcc, "basicspace", "oc")

## deSolve needs not to use f95 for geiger and others
gcc <- c(gcc, "deSolve")

gcc <- c(gcc, "Rcpp", "RcppArmadillo", "RcppEigen")
gcc <- c(gcc, "RMessenger", "Rmixmod", "dplyr", "gdsfmt", "httpuv", "mirt", "phylobase", "scrypt", "repfdr", "RJSONIO", "SKAT", "HDPenReg", "FunChisq")

Sys.setenv("OPENSSL_INCLUDES" = "/opt/csw/include", CURL_INCLUDES = "/opt/csw/include")

