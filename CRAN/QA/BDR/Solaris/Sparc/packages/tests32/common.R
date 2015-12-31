stoplist <- c("rggobi", "PKgraph", "beadarrayMSV", "clusterfly", "SeqGrapheR",
      "Rcell", "RockFab", "gitter", "metagear", # EBImage
      "MSeasy", "MSeasyTkGUI", "specmine",
      "MetaSKAT", # little-endian only 
      "RMySQL", "TSMySQL", "dbConnect", "Causata", "compendiumdb", "wordbankr",
      "BRugs", "CARrampsOcl", "GridR", "OpenCL", "gpuR",
      "RBerkeley", "RDieHarder", "RMark", "RMongo", "ROracle",
      "RProtoBuf", "RQuantLib", "RVowpalWabbit", 
      "RcppRedis", "Rcplex", "Rhpc", "RiDMC",
      "Rmosek", "VBmix", "cmprskContin",
      "cplexAPI", "cudaBayesreg", "gputools", "gmatrix", "magma", "permGPU",
      "qtbase", "qtpaint", "qtutils", "rmongodb", "rpvm",
      "Rpoppler", "Rsymphony", "ROI.plugin.symphony", "fPortfolio", "BLCOP",
      "RcppOctave", "HiPLARM", "RAppArmor", "RSAP", "REBayes", "ora", 
      "rLindo", "Rrdrand", "localsolver", "Boom", "BoomSpikeSlab",
      "bsts", "iFes", "rSPACE",  "nFCA", "RcppAPT", "multimark", "h5",
      "iptools", "caRpools", "Rblpapi", "PythonInR", "Goslate",
      "sodium", "maGUI", "flowDiv", "BEDMatrix", "homomorpheR", "littler",
      "V8", "minimist", "js", "rjade", "daff", "muir", "lawn", "geojsonio", "repijson", "rgbif", "spocc", "spoccutils", "rchess")

WindowsOnly <- c("BiplotGUI", "MDSGUI", "R2MLwiN", "R2PPT", "R2wd", "RPyGeo", "RWinEdt", "TinnR", "blatr", "excel.link", "installr", "spectrino")

stoplist <- c(stoplist, WindowsOnly, "microbenchmark", "timeit", "BayesXsrc", "R2BayesX")


fakes <- "ROracle"

recommended <-
    c("KernSmooth", "MASS", "Matrix", "boot", "class", "cluster",
      "codetools", "foreign", "lattice", "mgcv", "nlme", "nnet",
      "rpart", "spatial", "survival")

gcc <- 
    c("BayesXsrc", "ElectroGraph", "GWAtoolbox", "LDExplorer", "MCMCpack", 
      "MasterBayes", "OpenMx", "PKI", "PReMiuM", "RGtk2", "RJSONIO", "RSclient", 
      "Ratings", "Rcpp", "STARSEQ", "TDA", "bayesSurv", "bigalgebra", "biganalytics", "bigmemory", 
      "bigtabulate", "chords", "cldr", "dpmixsim", "fbati", "fts", "gdsfmt", "glasso", 
      "glmnet", "gnmf", "gof", "intervals", "mRm", "medSTC", "mixcat", 
      "phcfM", "phreeqc", "rbamtools", "rcppbugs", "repfdr", "rpf",
      "smoothSurv", "sparsenet", "tgp", "RJSONIO", "protViz", "SKAT",
      "climdex.pcic", "HDPenReg", "FunChisq", "DPpackage", "mapfit", "rgdal",
      "readxl", "icenReg", "mvabund", "stream", "FCNN4R", "Rsomoclu", "TMB",
      "funcy", "brms")

## avoid issues with __F95_sign
gcc <- c(gcc, "deSolve", "fGarch", "quadprog", "quantreg", "robustbase", "svd",
"limSolve", "nleqslv")

Sys.setenv("OPENSSL_INCLUDES" = "/opt/csw/include", CURL_INCLUDES = "/opt/csw/include", "V8_INCLUDES" = "/opt/csw/include")


