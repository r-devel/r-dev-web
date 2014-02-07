stoplist <- c("rggobi", "PKgraph", "beadarrayMSV", "SeqGrapheR",
              "demi", # oligo
              "rggobi", "PKgraph", "beadarrayMSV", "SeqGrapheR",
      "Rcell", "RockFab", "gitter", # EBImage
      "MSeasy", "MSeasyTkGUI",
      "RMySQL", "TSMySQL", "dbConnect", "Causata",
      "BRugs", "CARramps", "CARrampsOcl", "GridR", "OpenCL",
      "RBerkeley", "RDieHarder", "RMark", "RMongo", "ROAuth", "ROracle",
      "RProtoBuf", "RQuantLib", "RScaLAPACK", "Rcplex", "Rhpc", "RiDMC",
      "Rmosek", "VBmix", "WideLM", "cmprskContin",
      "cplexAPI", "cudaBayesreg", "gputools", "gmatrix", "magma", "permGPU",
      "qtbase", "qtpaint", "qtutils", "rJavax", "rmongodb",
      "rpud", "rpvm", "rscproxy", "rzmq", "twitteR",
      "Rpoppler",
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
    c("AdaptiveSparsity", "Amelia", "BayesComm", "BayesXsrc", "ConConPiWiFun", 
      "ElectroGraph", "FBFsearch", "FastPCS", "FastRCS", "Funclustering",
      "GMCM", "GPvam", "GSE", "GWAtoolbox", "GeneticTools", "HLMdiag", "LDExplorer",
      "MCMCpack", "MPTinR", "MVB", "MasterBayes", "Morpho",
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

## avoid issues with __F95_sign
gcc <- c(gcc, "quadprog", "robustbase")

Sys.setenv("OPENSSL_INCLUDES" = "/opt/csw/include")

