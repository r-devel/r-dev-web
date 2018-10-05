stoplist <- c("rggobi", "PKgraph", "beadarrayMSV", "clusterfly", "SeqGrapheR",
      "MSeasy", "MSeasyTkGUI", "specmine", "CorrectOverloadedPeaks", # mzR
#      "RMySQL", "TSMySQL", "dbConnect", "Causata", "compendiumdb", "wordbankr", "gmDatabase", "MetaIntegrator", "toxboot", "mdsr", "BETS", "taxizedb", "nowcasting", "GetITRData",
#      "RMariaDB",
      "BRugs", "CARrampsOcl", "GridR", "OpenCL", "gpuR", "bayesCL", "kmcudaR",
      "RBerkeley", "RDieHarder", "RMark", "RMongo", "ROracle", "R2ucare",
      "RProtoBuf", "RQuantLib", "RVowpalWabbit", "RcppRedis", "Rcplex",
      "ROI.plugin.cplex", "Rhpc",
      "Rmosek", "VBmix", "WideLM", "cmprskContin",
      "cplexAPI", "cudaBayesreg", "gputools", "gmatrix", "magma", "gpda",
      "qtbase", "qtpaint", "qtutils",
      "Rsymphony", "ROI.plugin.symphony", "fPortfolio", "BLCOP", "JFE",
      "RcppOctave", "HiPLARM", "RAppArmor", "RSAP", "REBayes", "ora",
      "permGPU", "rLindo", "localsolver",
      "Boom", "BoomSpikeSlab", "bsts", "CausalImpact", "iptools", "cbar",
      "rSPACE", "RcppAPT", "multimark", "h5", "caRpools",
      "Rblpapi", "PythonInR", "IGR", "sodium", "safer", "maGUI",
      "Goslate",  "homomorpheR", "littler", "rsvg", 'deconstructSigs', "GiNA", "colorfindr",
      "multipanelfigure", "gpg", "rlo", "enviGCMS", 'netSEM',
      "ionicons", "nmaINLA",
      "Sky",  "redland", "rdflib",
      "MonetDBLite",  "textTinyR", "sybilSBML", "dartR",
      "RDocumentation", # wipes out ~/.Rprofile
      "diffMeanVar", # has a ridiculous number of BioC dependencies
      "WebGestaltR", "tesseract", "rpq", "md.log",
      'rscala', 'shallot', 'bamboo', 'sdols', # need Scala (>= 2.11)
      "corehunter", "helixvis",'qCBA', 'deisotoper', 'jdx','rJPSGCS', "CrypticIBDcheck", "jsr223", "ChoR", "rCBA",  # Java >= 8
      'RWeka', 'RWekajars', 'ANLP', 'AntAngioCOOL', 'MSIseq', 'aslib', "LLM", "NoiseFiltersR",
      'BASiNET', 'Biocomb', 'DecorateR', 'dendroTools', 'FSelector',
      'NoiseFilters', 'petro.One',
      'openCR', # RMark via R2ucare
      'GREP2', # excessive BioC dependencies
      ## external tools
      "IRATER", "nFCA", "rbi", "msgtools", "RmecabKo", "tmuxr",
      "datapack", "dataone", "recordr", "PharmacoGx", "redux", "ipc",
      "keyring", "togglr", "Rgretl", "metacoder", "ssh",
      "LipidMS",
	"av", 
      "rcdk", "RxnSim", "SimuChemPC", 
"RKEEL", "RKEELdata", "RKEELjars" # Java version >= 8
       )


WindowsOnly <- c("BiplotGUI", "MDSGUI", "R2MLwiN", "R2PPT", "R2wd", "RInno", "RPyGeo", "RWinEdt", "TinnR", "blatr", "excel.link", "installr", "spectrino", "taskscheduleR")

stoplist <- c(stoplist, WindowsOnly) #, "BayesXsrc", "R2BayesX", "sptemExp")


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
      "chords", "climdex.pcic", "cldr", "dpmixsim", "fbati", "fts", "glasso", 
      "glmnet", "gnmf", "gof", "intervals", "mRm", "medSTC", "mixcat", 
      "phreeqc", "phcfM", "rbamtools", "rcppbugs", "smoothSurv", "sparsenet", "tgp")

## compiler ICEs
gcc <- c(gcc, "basicspace", "oc")

## deSolve needs not to use f95 for geiger and others
gcc <- c(gcc, "deSolve")

## RcppParallel linkage
gcc <- c(gcc, 'RcppParallel', 'StMoSim', 'markovchain', 'rPref')

gcc <- c(gcc, "Rcpp", "RcppArmadillo", "RcppEigen")
gcc <- c(gcc, "RMessenger", "Rmixmod", "dplyr", "gdsfmt", "httpuv", "mirt", "phylobase", "scrypt", "repfdr", "RJSONIO", "SKAT", "HDPenReg", "FunChisq", "mapfit", "rgdal", "sf", "V8", "readxl", "icenReg", "stream", "FCNN4R", "TMB", "funcy", "brms", "nimble", "protViz", "jqr", "magick", "rzmq", "clpAPI", "pcaL1")

## rstan
gcc <- c(gcc, "BANOVA", "prophet")

gcc <- c(gcc, "rgeos", "tuneR", "Rrdrand", "RandomFields", "RandomFieldsUtils", "crs", "fs", "RSiena", "freetypeharfbuzz")


Sys.setenv("OPENSSL_INCLUDES" = "/opt/csw/include", CURL_INCLUDES = "/opt/csw/include", "V8_INCLUDES" = "/opt/csw/include")

av <- function()
{
    ## setRepositories(ind = 1) # CRAN
    options(available_packages_filters =
            c("R_version", "OS_type", "CRAN", "duplicates"))
    av <- available.packages(contriburl = CRAN)[, c("Package", "Version", "Repository")]
    av <- as.data.frame(av, stringsAsFactors = FALSE)
    path <- with(av, paste0(Repository, "/", Package, "_", Version, ".tar.gz"))
    av$Repository <- NULL
    av$Path <- sub(".*contrib/", "../contrib/", path)
    av$mtime <- file.info(av$Path)$mtime
    names(av) <- c("name", "Version", "path", "mtime")
    av[order(av$name), ]
}


