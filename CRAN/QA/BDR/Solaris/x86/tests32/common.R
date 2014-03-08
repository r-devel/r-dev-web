stoplist <- c("rggobi", "PKgraph", "beadarrayMSV", "SeqGrapheR",
              "demi", # oligo
      "Rcell", "RockFab", "gitter", # EBImage
      "MSeasy", "MSeasyTkGUI",
      "RMySQL", "TSMySQL", "dbConnect", "Causata", 
      "BRugs","CARramps", "CARrampsOcl", "GridR", "OpenCL",
      "RBerkeley", "RDieHarder", "RMark", "RMongo",  "ROAuth", "ROracle",
      "RProtoBuf", "RQuantLib", "RScaLAPACK", "RVowpalWabbit", "Rcplex", "Rhpc",
      "Rmosek", "VBmix", "WideLM", "cmprskContin",
      "cplexAPI", "cudaBayesreg", "gputools", "gmatrix", "magma", "permGPU",
      "qtbase", "qtpaint", "qtutils", "rJavax", "rmongodb",
      "rpud", "rpvm", "rscproxy", "rzmq", "twitteR",
      "Rpoppler", "Rsymphony", "ROI.plugin.symphony",
      "RcppOctave", "HiPLARM", "RAppArmor", "RSAP", "REBayes", "ora", "rLindo")

#stoplist <- c(stoplist, "Rcpp")


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

## deSolve needs not to use f95 for geiger and others
gcc <- c(gcc, "climdex.pcic", "deSolve", "geiger", "mvabund", "protViz")

gcc0 <- 
    c("AdaptiveSparsity", "Amelia", "BayesComm", "BayesXsrc", "ConConPiWiFun", 
      "ElectroGraph", "FBFsearch", "FastPCS", "FastRCS", "Funclustering",
      "GMCM", "GPvam", "GSE", "GWAtoolbox", "GeneticTools", "HLMdiag", "LDExplorer",
      "MCMCpack", "MPTinR", "MVB", "MasterBayes", 
      "NetSim", "PKI", "PReMiuM", "PedCNV", "RGtk2", "RJSONIO", "RMessenger", 
      "RSclient", "Rankcluster", "Ratings", "Rclusterpp", "RcppArmadillo", 
      "RcppDE", "RcppEigen", "RcppRoll", "Rmixmod", "Rvcg", "SBSA", "STARSEQ", 
      "SpatialTools", "TAM", "bayesSurv", "bfa", "biganalytics", "bigmemory", 
      "bigtabulate", "blockcluster", "ccaPP", "cda", "chords", "cladoRcpp", "cldr", 
      "coneproj", "dpmixsim", "fdaMixed", "forecast", "fts", "gMWT", 
      "gRbase", "gRim", "geoCount", "glasso", "glmnet", "gnmf", "gof",
      "growcurves", "hawkes", "hsphase", 
      "httpuv", "intervals", "lme4", "mRm", "medSTC", "mets", "miscF", "mixcat", 
      "msgl", "ngspatial", "oem", "phcfM", "phylobase", "planar", "prospectr", 
      "psgp", "quadrupen", "rARPACK", "rbamtools", "rcppbugs", "rgam", 
      "rmgarch", "robustHD", "robustgam", "rotations", "rugarch",
      "sglOptim", "sirt", 
      "smoothSurv", "sparseHessianFD", "sparseLTSEigen", "sparsenet", 
      "strum", "tgp", "trustOptim", "unmarked", "zic")

Sys.setenv("OPENSSL_INCLUDES" = "/opt/csw/include")

