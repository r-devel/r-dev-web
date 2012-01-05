stoplist <-
    c(# recommended
      "KernSmooth", "MASS", "Matrix","boot", "class", "cluster",
      "codetools", "foreign", "lattice",  "mgcv", "nlme", "nnet",
      "rpart", "spatial", "survival",
# Missing external software
      "GDD", "OpenCL", "RDF","RDieHarder", "RMongo", "ROAuth",
      "ROI.plugin.symphony", "ROracle", "Rcplex", "RScaLAPACK",
      "Rlof", "Rmosek",  "SV", "cplexAPI", "mpc", "mvgraph", "rzmq","udunits2",
      "ncdf4", "M3", # ncdf4
      "Rsymphony", "clpAPI", "glpkAPI", "psgp",
      "CARramps", "cudaBayesreg", "gputools", "magma", # cuda
      "IQMNMR", "Rmpi", "bcool", "doMPI", "rpvm", "npRmpi", "rpud", "sprint", # mpi
# Unix-only
      "R4dfp", "RBerkeley", "ROracleUI", "RProtoBuf",  "TSpadi", "WINRPACK",
      "arulesSequences", "cmprskContin", "doMC", "fork", "gcbd",
      "makesweave", "multicore", "nice", "parmigene", "polyphemus",
      "synchronicity", "taskPR",
# don't work
      "RWinEdt", # need Rgui
      "VBmix", # sys/socket.h
      "farmR", # horrible Java things
      "interactivity", # Rinterface.h
      "mfr", # random, srandom
      "multic", # sys/times.h
      "rJavax", # same Java nonsense as farmR
      "triggr" # pthread.h sys/socket.h
      )

biarch <- c("SQLiteMap", "clpAPI", "glpkAPI") # my update of SQLiteMap

multi <- c("Cairo", "Cubist", "FastRWeb", "GWAtoolbox", "JavaGD", "RCurl",
           "RInside", "RJSONIO", "RMySQL", "RPostgreSQL", "Rserve",
           "Rssa", "bigmemory", "maps", "mvabund", "rJava", "rcom", "rgl")

extras <- c("SSOAP", "XMLRPC", "XMLSchema", "yags")

ggobi_users <- c("rggobi", "gcmrec", "magnets", "WMTregions", "beadarrayMSV",
                 "clusterfly", "PKgraph")

if(getRversion() < "1.5.0") {
    nomulti <- c(ggobi_users,
                 "OSACC", # fail to compile, tries to store pointers in long
                 "RSvgDevice", "RSVGTipsDevice", "eco") # crashes
    stoplist <- c(stoplist, "RQuantLib")
} else {
    stoplist <- c(stoplist,
                  "h5r",
                  ## and for 32-bit
                  ggobi_users,
                  "hdf5", "satin",
                  "BiGGR") # rsbml
    nomulti <- character()
}
