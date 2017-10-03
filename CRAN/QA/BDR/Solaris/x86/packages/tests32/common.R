stoplist <- c("rggobi", "PKgraph", "beadarrayMSV", "clusterfly", "SeqGrapheR",
      "Rcell", "RockFab", "gitter", "metagear", "bioimagetools", "nucim", "ggimage", "autothresholdr", "hexSticker", "nandb", # EBImage
      "MSeasy", "MSeasyTkGUI", "specmine", "CorrectOverloadedPeaks",
      "RMySQL", "TSMySQL", "dbConnect", "Causata", "compendiumdb", "wordbankr", "gmDatabase", "MetaIntegrator", "toxboot", "mdsr", "BETS", "taxizedb", "nowcasting", "GetITRData",
      "BRugs", "CARrampsOcl", "GridR", "OpenCL", "gpuR", "bayesCL", "kmcudaR",
      "RBerkeley", "RDieHarder", "RMark", "RMongo", "ROracle", "R2ucare",
      "RProtoBuf", "RQuantLib", "RVowpalWabbit", "RcppRedis", "Rcplex",
      "ROI.plugin.cplex", "Rhpc",
      "Rmosek", "VBmix", "WideLM", "cmprskContin",
      "cplexAPI", "cudaBayesreg", "gputools", "gmatrix", "magma",
      "qtbase", "qtpaint", "qtutils",
      "Rpoppler", "Rsymphony", "ROI.plugin.symphony", "fPortfolio", "BLCOP",
      "RcppOctave", "HiPLARM", "RAppArmor", "RSAP", "REBayes", "ora",
      "permGPU", "rLindo", "localsolver",
      "Boom", "BoomSpikeSlab", "bsts", "CausalImpact", "iptools", "cbar",
      "rSPACE", "RcppAPT", "nFCA", "multimark", "h5", "caRpools",
      "Rblpapi", "PythonInR", "microbenchmark", "timeit", "sodium", "safer", "maGUI",
      "Goslate",  "homomorpheR", "littler", "rsvg", 'deconstructSigs', "GiNA",
      "multipanelfigure", "gkmSVM", "gpg", "tesseract", "rlo", "enviGCMS",
      "ionicons", "nmaINLA",
      "miscF", "agRee", "PottsUtils",
      "Sky", "remoter", "redland", "pdftools", "pdfsearch", "textreadr", "crminer", "readtext", "rcoreoa",
      "MonetDBLite", "IRATER", "textTinyR", "sybilSBML", "dartR",
      "corehunter", "helixvis", # JRE 8
      "msgtools", "ForestTools", "WebGestaltR", "rpq", "kerasR", "md.log",
      "datapack", "dataone", "recordr", "tcpl", "toxplot", "magick", 'texPreview', "PharmacoGx","rbi", "redux", "splashr", "keyring", "mathpix")


WindowsOnly <- c("BiplotGUI", "MDSGUI", "R2MLwiN", "R2PPT", "R2wd", "RInno", "RPyGeo", "RWinEdt", "TinnR", "blatr", "excel.link", "installr", "spectrino", "taskscheduleR")

stoplist <- c(stoplist, WindowsOnly, "BayesXsrc", "R2BayesX", "sptemExp")


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
gcc <- c(gcc, "RMessenger", "Rmixmod", "dplyr", "gdsfmt", "httpuv", "mirt", "phylobase", "scrypt", "repfdr", "RJSONIO", "SKAT", "HDPenReg", "FunChisq", "mapfit", "rgdal", "sf", "V8", "readxl", "icenReg", "stream", "FCNN4R", "TMB", "funcy", "brms", "nimble", "protViz", "jqr")

## rstan
gcc <- c(gcc, "BANOVA", "prophet")

gcc <- c(gcc, "rgeos", "tuneR", "Rrdrand", "RandomFields", "RandomFieldsUtils")


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


