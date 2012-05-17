stoplist <-
    c(# recommended
      "KernSmooth", "MASS", "Matrix","boot", "class", "cluster",
      "codetools", "foreign", "lattice",  "mgcv", "nlme", "nnet",
      "rpart", "spatial", "survival",
# Missing external software
      "GDD", "OpenCL", "RDF","RDieHarder", "RMongo", "ROAuth", "ROracle",
      "Rcplex", "RScaLAPACK", "Rlof", "Rmosek",  "SV", "cplexAPI", "h5r",
      "mimR", "mvgraph", "rpvm", "rzmq",
      "ncdf4", "M3", # ncdf4
      "CARramps", "WideLM", "cudaBayesreg", "gputools", "magma", # cuda
      "qtbase", "qtpaint", "qtutils",
      "IQMNMR", "Rmpi", "bcool", "doMPI", "npRmpi", "pmclust", "rpud", "sprint", # mpi
# Unix-only
      "R4dfp", "RBerkeley", "ROracleUI", "RProtoBuf",  "TSpadi", "VBmix",
      "WINRPACK", "cit", "cmprskContin", "doMC", "fork", "gcbd",
      "interactivity", "makesweave", "mfr", "multic", "multicore", "nice",
      "parmigene", "polyphemus", "synchronicity", "taskPR", "triggr",
# don't work
      "excel.link", # RDCOMClient
      "RWinEdt", # needs Rgui
      "farmR", "rJavax" # horrible Java things
      )

biarch <- c("SQLiteMap", "arulesSequences", "sparsenet", "udunits2")

multi <- c("Cairo", "Cubist", "FastRWeb", "GWAtoolbox", "JavaGD", "RCurl",
           "RInside", "RJSONIO", "RMySQL", "RPostgreSQL", "Rserve",
           "Rssa", "bigmemory", "maps", "rJava", "rcom", "rgl")

extras <- c("XMLRPC", "yags")

ggobi_users <- c("rggobi",  "PKgraph",  "beadarrayMSV", "clusterfly")

stoplist <- c(stoplist, ## and for 32-bit-only
              ggobi_users, "hdf5", "satin")

