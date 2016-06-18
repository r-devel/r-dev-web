stoplist <- c("rggobi", "PKgraph", "beadarrayMSV", "clusterfly", "SeqGrapheR",
      "Rcell", "RockFab", "gitter", "metagear", # EBImage
      "MSeasy", "MSeasyTkGUI", "specmine",
      "RMySQL", "TSMySQL", "dbConnect", "Causata", "compendiumdb", "wordbankr", "gmDatabase",
      "BRugs", "CARrampsOcl", "GridR", "OpenCL", "gpuR",
      "RBerkeley", "RDieHarder", "RMark", "RMongo", "ROracle",
      "RProtoBuf", "RQuantLib", "RVowpalWabbit", "RcppRedis", "Rcplex", "Rhpc",
      "Rmosek", "VBmix", "WideLM", "cmprskContin",
      "cplexAPI", "cudaBayesreg", "gputools", "gmatrix", "magma",
      "qtbase", "qtpaint", "qtutils", "rmongodb",
      "Rpoppler", "Rsymphony", "ROI.plugin.symphony", "fPortfolio", "BLCOP",
      "RcppOctave", "HiPLARM", "RAppArmor", "RSAP", "REBayes", "ora",
      "permGPU", "rLindo", "localsolver",
      "Boom", "BoomSpikeSlab", "bsts", "iptools",
      "rSPACE", "RcppAPT", "nFCA", "multimark", "h5", "caRpools",
      "Rblpapi", "PythonInR", "microbenchmark", "timeit", "sodium", "maGUI",
      "Goslate",  "homomorpheR", "littler", "rsvg", 'deconstructSigs', "GiNA",
      "multipanelfigure",
      "Sky", "remoter", "redland", "pdftools", "hunspell", "MonetDBLite",
      "datapack", "dataone", "tcpl")


WindowsOnly <- c("BiplotGUI", "MDSGUI", "R2MLwiN", "R2PPT", "R2wd", "RPyGeo", "RWinEdt", "TinnR", "blatr", "excel.link", "installr", "spectrino")

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
    c("BayesXsrc", "ElectroGraph", "GWAtoolbox", "LCMCR", "LDExplorer", "MCMCpack", 
      "MasterBayes", "OpenMx", "PKI", "PReMiuM", "RGtk2", "RJSONIO",
      "RSclient", "Ratings", "STARSEQ", "TDA", "bayesSurv", 
      "bigalgebra", "biganalytics", "bigmemory", "bigtabulate",
      "chords", "cldr", "dpmixsim", "fbati", "fts", "glasso", 
      "glmnet", "gnmf", "gof", "intervals", "mRm", "medSTC", "mixcat", 
      "phreeqc", "phcfM", "rbamtools", "rcppbugs", "smoothSurv", "sparsenet", "tgp")

## compiler ICEs
gcc <- c(gcc, "basicspace", "oc")

## deSolve needs not to use f95 for geiger and others
gcc <- c(gcc, "deSolve")

## RcppParallel linkage
gcc <- c(gcc, 'RcppParallel', 'StMoSim', 'markovchain', 'rPref')

gcc <- c(gcc, "Rcpp", "RcppArmadillo", "RcppEigen")
gcc <- c(gcc, "RMessenger", "Rmixmod", "dplyr", "gdsfmt", "httpuv", "mirt", "phylobase", "scrypt", "repfdr", "RJSONIO", "SKAT", "HDPenReg", "FunChisq", "mapfit", "rgdal", "V8", "readxl", "icenReg", "stream", "FCNN4R", "TMB", "funcy", "brms")

Sys.setenv("OPENSSL_INCLUDES" = "/opt/csw/include", CURL_INCLUDES = "/opt/csw/include", "V8_INCLUDES" = "/opt/csw/include")

