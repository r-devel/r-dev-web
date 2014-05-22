stoplist <-
    c(# recommended
      "KernSmooth", "MASS", "Matrix", "boot", "class", "cluster",
      "codetools", "foreign", "lattice",  "mgcv", "nlme", "nnet",
      "rpart", "spatial", "survival",
# Missing external software
      "CARrampsOcl", "OpenCL", "RcppOctave", "RDieHarder", "REBayes", "RMongo",
      "ROAuth", "ROracle", "RSAP", "Rcplex", "RcppRedis", "Rmosek",
      "cplexAPI", "mvgraph", "ora", "rLindo", "rmongodb", "rzmq",
      "ncdf4", "M3", "ncdf4.helpers", "ocean", "phenology", "qat", # ncdf4
      "CARramps", "WideLM", "cudaBayesreg", "gmatrix", "gputools", "magma", "permGPU", "rpud", # cuda
      "qtbase", "qtpaint", "qtutils", "ProgGUIinR",
      "npRmpi", "bcool", "simsalapar", # mpi
#      "pbdBASE", "pbdDEMO", "pbdDMAT",
      "RMySQL", "Causata", "TSMySQL", "dbConnect",
# Unix-only
      "HiPLARM", "OmicKriging", "PAGWAS", "PopGenome", "R4dfp",
      "RBerkeley", "ROracleUI", "RProtoBuf", "RbioRXN", "Rdsm", "SGP",
      "STARSEQ", "VBmix", "WINRPACK", "cit", "doMC", "fork",
      "fdasrvf", "gcbd" , "gearman", "gpmap", "interactivity",
      "makesweave", "mfr", "multic", "multicore", "nice",
      "polyphemus", "rcqp", "synchronicity", "taskPR", "triggr", "vcf2geno",
      "bigmemory", "bigalgebra", "biganalytics", "bigmemory.sri",
      "bigrf", "bigtabulate", "planor",
# don't work
      "excel.link", # RDCOMClient
      "RWinEdt", # needs Rgui
      "rJavax", # horrible Java things
      "SNPRelate", "Storm", # runs forever
      "StreamingLm", "parallelize.dynamic", "translate"
      )

biarch <- c("PKI", "RSclient", "R2SWF")

multi <- c("BayesXsrc", "C50", "Cairo", "Cubist", "FastRWeb",
           "GWAtoolbox", "JavaGD", "RCA", "RCurl", "RInside",
           "RJSONIO", "RMySQL", "RPostgreSQL", "Rserve", "Rssa",
           "SWATmodel", "excursions", "jsonlite", "maps", "rJava",
           "rcom", "rgl", "tth")

extras <- c("XMLRPC", "yags")
