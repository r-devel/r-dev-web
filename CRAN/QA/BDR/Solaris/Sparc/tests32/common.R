stoplist <- c("ExomeDepth",
              "aroma.apd", "aroma.cn", "aroma.core", "aroma.affymetrix", "calmate",
              "ACNE", "MAMA", "NSA",
              "rggobi", "PKgraph", "beadarrayMSV", "SeqGrapheR",
              "StochaTR", "SNPMaP", "SRMA", "demi",
      "Rcell", "RockFab", "gitter", # EBImage
      "MSeasy", "MSeasyTkGUI",
      "RMySQL", "TSMySQL", "dbConnect", "Causata",
      "BRugs", "CARramps", "CARrampsOcl", "GridR", "OpenCL",
      "RBerkeley", "RDieHarder", "RMark", "RMongo", "ROAuth", "ROracle",
      "RQuantLib", "RScaLAPACK", "Rcplex", "Rhpc", "RiDMC",
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
      "ElectroGraph", "FBFsearch", "FastPCS", "FastRCS", "GSE", "GSE", 
      "GeneticTools", "HLMdiag", "MCMCpack", "MPTinR", "MVB", "MasterBayes", 
      "NetSim", "PKI", "PReMiuM", "PedCNV", "RGtk2", "RJSONIO", "RMessenger", 
      "RSclient", "Rankcluster", "Ratings", "Rclusterpp", "RcppArmadillo", 
      "RcppDE", "RcppEigen", "RcppRoll", "Rmixmod", "SBSA", "STARSEQ", 
      "SpatialTools", "TAM", "bayesSurv", "bfa", "biganalytics", "bigmemory", 
      "bigtabulate", "ccaPP", "cda", "chords", "cladoRcpp", "cldr", 
      "coneproj", "dpmixsim", "fdaMixed", "forecast", "fts", "gMWT", 
      "gRbase", "gRim", "geoCount", "glasso", "glmnet", "gof", "growcurves", "hsphase", 
      "httpuv", "intervals", "lme4", "mRm", "mets", "miscF", "mixcat", 
      "msgl", "ngspatial", "oem", "phcfM", "phylobase", "planar", "prospectr", 
      "psgp", "quadrupen", "quadrupen", "rbamtools", "rcppbugs", "rgam", 
      "rmgarch", "robustHD", "robustgam", "rotations", "rugarch",
      "sglOptim", "sirt", 
      "smoothSurv", "sparseHessianFD", "sparseLTSEigen", "sparsenet", 
      "strum", "tgp", "trustOptim", "unmarked", "zic")

## avoid issues with __F95_sign
gcc <- c(gcc, "quadprog", "robustbase")

Sys.setenv("OPENSSL_INCLUDES" = "/opt/csw/include")

