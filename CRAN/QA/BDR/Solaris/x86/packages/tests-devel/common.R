stoplist <-
  c(
#      "RMySQL", "TSMySQL", "dbConnect", "Causata", "compendiumdb", "wordbankr", "gmDatabase", "MetaIntegrator", "toxboot", "mdsr", "BETS", "taxizedb", "nowcasting", "GetITRData",
#      "RMariaDB",
      "Boom", "BoomSpikeSlab", "bsts", "CausalImpact", "TSstudio", "cbar",
      "MSeasy", "MSeasyTkGUI", "specmine", "CorrectOverloadedPeaks", "LipidMS",  # mzR
      "MonetDBLite", 'restez', # installation failure
      "RDocumentation", # wiped out ~/.Rprofile
      "RProtoBuf", # seems to need version 3 but does not say so
      "Rsymphony", "ROI.plugin.symphony",
      "dartR", # SNPRelate and gdsfmt, latter fails to install
      "diffMeanVar", "maGUI", # have a ridiculous number of BioC dependencies
      "iptools", # C++11?
      "md.log", # naming
      "multipanelfigure", # crashes on magick
      ## external libs
      "BRugs", "REBayes", 'RQuantLib',
      "RVowpalWabbit", # Boost::Program_Options
      "Rblpapi", "RcppRedis", "Rmosek", "gpg",
      "h5", # C++ interface
      "keyring", "togglr",
      "nmaINLA", # Suggests: INLA
      "qtbase", "qtpaint", "qtutils",
      "redland", "rdflib", "datapack", "dataone",
      "redux", # hiredis
      "sodium", "homomorpheR", "safer",
      "ssh", "sybilSBML", "tesseract",
      ## external tools
      "IRATER", # R2admb for anything useful
      "PythonInR", "WebGestaltR", "rlo",
      "RAppArmor", "RcppAPT", "Rgretl", "RmecabKo",
      "RMark", "R2ucare", "multimark",
      "RMongo", "ROracle",
      "av", # FFmpeg
      "caRpools", # MAGeCK
      "msgtools",
      "nFCA", # ruby
      "rggobi", "PKgraph", "SeqGrapheR", "beadarrayMSV", "clusterfly",
      "rsvg", "ChemmineR", "colorfindr", "netSEM", "uCAREChemSuiteCLI", "vtree",
      "tmuxr"
       )

## Java version >= 8
Java <- c("ChoR", "CrypticIBDcheck", "RKEEL", "RKEELdata", "RKEELjars",
          "RxnSim", "SimuChemPC", "corehunter", "deisotoper", "helixvis",
          "jdx", "jsr223", "qCBA", "rCBA", "rJPSGCS", "rcdk",
          "enviGCMS", # rcdk
          'rscala', 'bamboo', 'sdols', 'shallot',
          'RWeka', 'RWekajars', "AntAngioCOOL", "BASiNET", "Biocomb",
          "DecorateR", "FSelector", "HybridFS", "LLM", "MSIseq",
          "NoiseFiltersR", "RtutoR", "aslib", "lilikoi", "smartdata")

CUDA <- # etc
c("RDieHarder", "ROI.plugin.cplex", "ROracle","ora", "Rcplex", "Rhpc", "cplexAPI",  "cudaBayesreg", "kmcudaR", "permGPU", "localsolver", "OpenCL", "CARrampsOcl", "littler", "ora", "gpuR", "bayesCL", "gpda", "rLindo")


WindowsOnly <- c("BiplotGUI", "MDSGUI", "R2MLwiN", "R2PPT", "R2wd", "RInno", "RPyGeo", "RWinEdt", "TinnR", "blatr", "excel.link", "installr", "spectrino", "taskscheduleR")

stoplist <- c(stoplist, Java, CUDA,  WindowsOnly)


fakes <- "ROracle"

ll <- c("## Fake installs",
        paste(fakes, "-OPTS = --install=fake", sep=""))
writeLines(ll, "Makefile.fakes")

recommended <-
    c("KernSmooth", "MASS", "Matrix", "boot", "class", "cluster",
      "codetools", "foreign", "lattice", "mgcv", "nlme", "nnet",
      "rpart", "spatial", "survival")

gcc <-
    c("BayesXsrc", "ElectroGraph", "GWAtoolbox", "LCMCR", "LDExplorer",
      "MasterBayes", "OpenMx", "PKI", "PReMiuM", "RGtk2", "RJSONIO",
      "RProtoBuf","RSclient", "Ratings", "STARSEQ", "TDA", "bayesSurv",
      "bigalgebra", "biganalytics", "bigmemory", "bigtabulate",
      "chords", "climdex.pcic", "cldr", "dpmixsim", "fbati", "fts", "glasso",
      "glmnet", "gnmf", "gof", "intervals", "mRm", "medSTC", "mixcat",
      "phreeqc", "phcfM", "rbamtools", "rcppbugs", "smoothSurv", "sparsenet", "tgp")

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
