stoplist <-
    c(# recommended
      "KernSmooth", "MASS", "Matrix", "boot", "class", "cluster",
      "codetools", "foreign", "lattice",  "mgcv", "nlme", "nnet",
      "rpart", "spatial", "survival",
# Missing external software
      "CARrampsOcl", "OpenCL", "RcppOctave", "RDieHarder", "RMongo",
      "ROAuth", "ROracle", "RSAP", "Rcplex", "RcppRedis", "cplexAPI",
      "localsolver", "ora", "rLindo", "rmongodb", "rzmq",
      "ncdf4", "M3", "ncdf4.helpers", "ocean", "qat", # ncdf4
      "CARramps", "HiPLARM", "WideLM", "cudaBayesreg", "gmatrix", "gputools",
      "iFes", "magma", "permGPU", "rpud", # cuda
      "qtbase", "qtpaint", "qtutils", "ProgGUIinR",
      "bcool", "doRNG", "simsalapar", # mpi
      "Rmosek", "REBayes", "cqrReg",
      "pbdBASE", "pbdDEMO", "pbdDMAT",
      "nFCA", # Ruby
# Unix-only
      "OmicKriging", "PAGWAS", "PopGenome", "R4dfp", "RProtoBuf", "Rdsm",
      "SGP", "VBmix", "cit", "doMC", "fdasrvf", "gcbd" , "gemmR", "gpmap",
      "multic", "nice", "sprint", "synchronicity",
      "bigmemory", "bigalgebra", "biganalytics", "bigmemory.sri", "bigrf", "bigtabulate",
      "GWLelast", "QuantifQuantile",
# don't work
      "JAGUAR", "dcGOR", # doMC
      "excel.link", # RDCOMClient
      "RWinEdt", # needs Rgui
      "rJavax", # horrible Java things
      "Storm", # runs forever
      "parallelize.dynamic", "translate", "RCMIP5"
      )

biarch <- c("PKI", "RSclient", "R2SWF", "compLasso", "icd9")

multi <- c("BayesXsrc", "C50", "Cairo", "Cubist", "FastRWeb", "GWAtoolbox",
           "JavaGD", "RCA", "RCurl", "RInside", "RJSONIO", "RMySQL",
           "RPostgreSQL", "Rserve", "Rssa", "SWATmodel", "dbarts",
           "excursions", "gaselect", "jsonlite", "maps", "ore",
           "rJava", "rgl", "tth")

extras <- c("XMLRPC", "yags", "INLA")
