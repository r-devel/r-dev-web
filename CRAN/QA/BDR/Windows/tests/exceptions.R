stoplist <-
    c(# recommended
      "KernSmooth", "MASS", "Matrix","boot", "class", "cluster",
      "codetools", "foreign", "lattice",  "mgcv", "nlme", "nnet",
      "rpart", "spatial", "survival",
# Missing external software
      "OpenCL", "RDieHarder", "REBayes", "RMongo", "ROAuth", "ROracle",
      "Rcplex", "RSAP", "Rlof", "Rmosek", "cplexAPI",
      "mimR", "mvgraph", "rzmq",
      "ncdf4", "M3", "qat", # ncdf4
      "CARramps", "WideLM", "cudaBayesreg", "gputools", "magma", "permGPU", # cuda
      "qtbase", "qtpaint", "qtutils", "ProgGUIinR",
      "IQMNMR", "Rmpi", "bcool", "doMPI", "npRmpi", "parspatstat",
      "pbdBASE", "pbdDEMO", "pbdDMAT", "pbdMPI", "pbdSLAP",
      "pmclust", "rpud", "sprint", # mpi
      "RMySQL", "TSMySQL", "dbConnect",
# Unix-only
      "HiPLARM", "R4dfp", "RBerkeley", "ROracleUI", "RProtoBuf", "SGP",
      "STARSEQ", "VBmix", "WINRPACK", "cit", "doMC", "fork", "fdasrvf",
      "gcbd" , "gearman", "interactivity", "makesweave", "mfr", "multic",
      "multicore", "nice",
      "polyphemus", "rcqp", "synchronicity", "taskPR", "triggr", "vcf2geno",
      "bigmemory", "biganalytics", "bigmemory.sri", "bigtabulate", "BerkeleyEarth", "PopGenome", "RghcnV3",  "planor", "bigrf",
# don't work
      "excel.link", # RDCOMClient
      "RWinEdt", # needs Rgui
      "rJavax", # horrible Java things
      "SNPRelate" # runs forever
      )

biarch <- c("PKI", "RSclient")

multi <- c("BayesXsrc", "C50", "Cairo", "Cubist", "FastRWeb",
           "GWAtoolbox", "JavaGD", "RCurl", "RInside", "RJSONIO",
           "RMySQL", "RPostgreSQL", "Rserve", "Rssa", "SWATmodel",
           "bigmemory", "maps", "rJava", "rcom", "rgl", "tth")

extras <- c("XMLRPC", "yags")
