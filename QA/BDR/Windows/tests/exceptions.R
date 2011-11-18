stoplist <-
    c(# recommended
      "KernSmooth", "MASS", "Matrix","boot", "class", "cluster",
      "codetools", "foreign", "lattice",  "mgcv", "nlme", "nnet",
      "rpart", "spatial", "survival",
# Missing external software
      "GDD", "OpenCL", "RDF","RDieHarder", "RMongo", "ROAuth",
      "ROI.plugin.symphony", "ROracle", "Rcplex", "RScaLAPACK",
      "Rlof", "Rmosek", "Rsymphony", "SV",  "clpAPI", "cplexAPI",
      "glpkAPI", "mpc", "mvgraph", "rzmq","udunits2",
      "ncdf4", "M3", # ncdf4
      "cudaBayesreg", "gputools", "magma", # cuda
      "IQMNMR", "Rmpi", "bcool", "doMPI", "rpvm", "npRmpi", "rpud", "sprint", # mpi
# Unix-only
      "R4dfp", "RBerkeley", "ROracleUI", "RProtoBuf",  "TSpadi", "WINRPACK",
      "arulesSequences", "cmprskContin", "doMC", "fork", "gcbd",
      "makesweave", "multicore", "nice", "synchronicity", "taskPR",
# don't work
      "FastRWeb", "RWinEdt", "VBmix", "farmR", "interactivity", "mfr",
      "multic", "parmigene", "rJavax", "triggr")

biarch <- c("XML", "SQLiteMap")

multi <- c("Cairo", "Cubist", "GWAtoolbox", "JavaGD", "RCurl",
           "RInside", "RJSONIO", "RMySQL", "RPostgreSQL", "Rserve", "Rssa",
           "SQLiteMap", "bigmemory", "maps", "mvabund", "rJava", "rcom", "rgl")

nomulti <- c("rggobi", "gcmrec", "magnets", "WMTregions", # because of rggobi
             "OSACC", # fail to compile, tries to store pointers in long
             "RSvgDevice", "RSVGTipsDevice", "eco") # crashes

extras <- c("RDCOMClient", "SSOAP", "XMLRPC", "XMLSchema", "yags")
