stoplist <-
    c(# recommended
      "KernSmooth", "MASS", "Matrix","boot", "class", "cluster",
      "codetools", "foreign", "lattice",  "mgcv", "nlme", "nnet",
      "rpart", "spatial", "survival",
# Missing external software
      "RDieHarder", "RMark", "ROAuth", "ROracle", "RQuantLib", "Rcplex",
      "RScaLAPACK", "Rsymphony", "SV", "ncdf4", "udunits2",
      "clpAPI", "glpkAPI", "nloptr", "OpenCL", "mpc", "cplexAPI",
      "ROI.plugin.symphony",
      "M3", # ncdf4
      "cudaBayesreg", "gputools", "magma", # cuda
      "IQMNMR", "Rmpi", "doMPI", "rpvm", "npRmpi", "rpud", "sprint", # mpi
      "rmosek", "RMongo", "rzmq", "bcool", "Rlof",
# Unix-only
      "R4dfp", "RBerkeley", "ROracleUI", "RProtoBuf",  "TSpadi", "WINRPACK",
      "arulesSequences", "cmprskContin", "doMC", "fork", "gcbd",
      "makesweave", "multicore", "nice", "synchronicity", "taskPR",
# don't work
      "VBmix", "farmR", "interactivity", "mfr", "multic", "mvgraph",
      "parmigene", "psgp", "triggr",
      "ADaCGH", # no GDD
      "websockets", "rJavax",
# special-cased
      "GDD")

biarch <- c("XML")
multi <- c("JavaGD", "RCurl", "RInside", "RMySQL", "RPostgreSQL", "Rserve",
           "Rssa", "bigmemory", "maps", "rJava", "rcom", "rgl")
nomulti <- c("gcmrec", "magnets", # because of rggobi
             "RSvgDevice", "RSVGTipsDevice", "SNPassoc", "coxphf",
             "eco", "yaml") # crashes/loops

extras <- c("RDCOMClient", "SSOAP", "XMLRPC", "XMLSchema", "yags")
