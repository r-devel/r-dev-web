stoplist <-
    c(# recommended
      "KernSmooth", "MASS", "Matrix","boot", "class", "cluster",
      "codetools", "foreign", "lattice",  "mgcv", "nlme", "nnet",
      "rpart", "spatial", "survival",
# Missing external software
      "GDD", "OpenCL", "RDF","RDieHarder", "RMongo", "ROAuth", "ROracle",
      "Rcplex", "RScaLAPACK", "Rlof", "Rmosek", "cplexAPI",
      "mimR", "mvgraph", "rzmq",
      "ncdf4", "M3", # ncdf4
      "CARramps", "WideLM", "cudaBayesreg", "gputools", "magma", # cuda
      "qtbase", "qtpaint", "qtutils", "ProgGUIinR",
      "IQMNMR", "Rmpi", "bcool", "doMPI", "npRmpi", "parspatstat",
      "pbdBASE", "pbdDMAT", "pbdMPI", "pbdSLAP",
      "pmclust", "rpud", "sprint", # mpi
# Unix-only
      "HiPLARM", "R4dfp", "RBerkeley", "ROracleUI", "RProtoBuf",
      "STARSEQ", "TSpadi", "VBmix", "WINRPACK", "cit", "cmprskContin",
      "doMC", "fork", "fdasrvf", "gcbd" , "gearman", "interactivity",
      "makesweave", "mfr", "multic", "multicore", "nice",
      "polyphemus", "rcqp", "synchronicity", "taskPR", "triggr",
      "vcf2geno",
# don't work
      "excel.link", # RDCOMClient
      "RWinEdt", # needs Rgui
      "rJavax", # horrible Java things
      ## and for 32-bit-only
      "hdf5", "satin",
      "SNPRelate" # runs forever
      )

biarch <- c()

multi <- c("BayesXsrc", "C50", "Cairo", "Cubist", "FastRWeb",
           "GWAtoolbox", "JavaGD", "RCurl", "RInside", "RJSONIO",
           "RMySQL", "RPostgreSQL", "Rserve", "Rssa", "SWATmodel",
           "bigmemory", "maps", "rJava", "rcom", "rgl")

extras <- c("XMLRPC", "yags")
