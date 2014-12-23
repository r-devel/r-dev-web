stoplist <- c("rggobi", "PKgraph", "beadarrayMSV", "clusterfly", "SeqGrapheR",
      "Rcell", "RockFab", "gitter", # EBImage
      "MSeasy", "MSeasyTkGUI",
      "MetaSKAT", # little-endian only 
      "RMySQL", "TSMySQL", "dbConnect", "Causata", "compendiumdb",
      "BRugs", "CARramps", "CARrampsOcl", "GridR", "OpenCL",
      "RBerkeley", "RDieHarder", "RMark", "RMongo", "ROracle",
      "RProtoBuf", "RQuantLib", "RVowpalWabbit", 
      "RcppRedis", "Rcplex", "Rhpc", "RiDMC",
      "Rmosek", "VBmix", "WideLM", "cmprskContin",
      "cplexAPI", "cudaBayesreg", "gputools", "gmatrix", "magma", "permGPU",
      "qtbase", "qtpaint", "qtutils", "rJavax", "rmongodb",
      "rpud", "rpvm", "rscproxy", "rzmq", "twitteR",
      "Rpoppler", "Rsymphony", "ROI.plugin.symphony", "fPortfolio",
      "RcppOctave", "HiPLARM", "RAppArmor", "RSAP", "REBayes", "ora", 
      "rLindo", "Rrdrand", "localsolver", "Boom", "BoomSpikeSlab",
      "bsts", "cqrReg", "V8", "iFes", "rSPACE")

WindowsOnly <- c("BiplotGUI", "MDSGUI", "R2MLwiN", "R2PPT", "R2wd", "RPyGeo", "RWinEdt", "TinnR", "excel.link", "installr")

stoplist <- c(stoplist, WindowsOnly, "microbenchmark", "timeit", "BayesXsrc", "R2BayesX")


fakes <- "ROracle"

recommended <-
    c("KernSmooth", "MASS", "Matrix", "boot", "class", "cluster",
      "codetools", "foreign", "lattice", "mgcv", "nlme", "nnet",
      "rpart", "spatial", "survival")

gcc <- 
    c("BayesXsrc", "ElectroGraph", "GWAtoolbox", "LDExplorer", "MCMCpack", 
      "MasterBayes", "PKI", "PReMiuM", "RGtk2", "RJSONIO", "RSclient", 
      "Ratings", "Rcpp", "STARSEQ", "TDA", "bayesSurv", "biganalytics", "bigmemory", 
      "bigtabulate", "chords", "cldr", "dpmixsim", "fbati", "fts", "gdsfmt", "glasso", 
      "glmnet", "gnmf", "gof", "intervals", "mRm", "medSTC", "mixcat", 
      "phcfM", "phreeqc", "rbamtools", "rcppbugs", "repfdr", "rpf",
      "smoothSurv", "sparsenet", "tgp", "RJSONIO", "protViz", "SKAT",
      "climdex.pcic")

## avoid issues with __F95_sign
gcc <- c(gcc, "deSolve", "fGarch", "quadprog", "quantreg", "robustbase", "svd")

Sys.setenv("OPENSSL_INCLUDES" = "/opt/csw/include", CURL_INCLUDES = "/opt/csw/include")


