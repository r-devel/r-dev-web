stoplist <-
    c(# recommended
      "KernSmooth", "MASS", "Matrix", "boot", "class", "cluster",
      "codetools", "foreign", "lattice",  "mgcv", "nlme", "nnet",
      "rpart", "spatial", "survival",
# Missing external software
      "CARrampsOcl", "OpenCL", "RcppOctave", "RDieHarder", "RMongo",
      "ROAuth", "ROracle", "RSAP", "Rcplex", "RcppRedis", "cplexAPI", "gpuR",
      "localsolver", "ora", "rLindo", "rmongodb", "rzmq",
      # "ncdf4", "M3", "cmsaf", "magclass", "ncdf4.helpers", "ocean", "qat", # ncdf4
      "s2dverification", # ncdf4, big.memory
      "CARramps", "HiPLARM", "WideLM", "cudaBayesreg", "gmatrix", "gputools",
      "iFes", "magma", "permGPU", "rpud", # cuda
      "qtbase", "qtpaint", "qtutils", "ProgGUIinR",
      "bcool", "doRNG", "simsalapar", # mpi
      "Rmosek", "REBayes", "cqrReg",
      "pbdBASE", "pbdDEMO", "pbdDMAT",
      "nFCA", # Ruby
      "rchallenge", # pandoc
      "maGUI", # too many BioC deps
# Unix-only
      "OmicKriging", "PopGenome", "R4dfp", "RProtoBuf", "Rdsm",
      "SGP", "VBmix", "cit", "doMC", "fdasrvf", "gcbd" , "gemmR", "gpmap",
      "multic", "nice", "sprint", "synchronicity",
      "bigmemory", "bigalgebra", "biganalytics", "bigmemory.sri", "bigrf", "bigtabulate", "sgd",
      "GWLelast", "QuantifQuantile",
      "JAGUAR", "PAGWAS", "dcGOR", "ptycho", # doMC
# don't work
      "excel.link", # RDCOMClient
      "RWinEdt", # needs Rgui
      "rJavax", # horrible Java things
      "SACORBA", "Storm", # runs forever
      "caRpools", "nbconvertR", "Rblpapi", "switchr", "switchrGist", "rcrypt",
      "parallelize.dynamic", "translate", "RCMIP5"
      )

biarch <- c("PKI", "RSclient", "R2SWF", "compLasso", "icd9")

multi <- c("BayesXsrc", "C50", "Cairo", "Cubist", "FastRWeb", "GWAtoolbox",
           "JavaGD", "RCA", "RCurl", "RInside", "RJSONIO", "RMySQL",
           "RPostgreSQL", "Rserve", "Rssa", "RxODE", "SWATmodel", "dbarts",
           "excursions", "gaselect", "jsonlite", "maps", "ore",
           "rJava", "rgl", "tth")

extras <- c("XMLRPC", "yags", "INLA")
