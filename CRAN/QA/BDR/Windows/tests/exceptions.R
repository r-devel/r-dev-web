stoplist <-
    c(# recommended
      "KernSmooth", "MASS", "Matrix","boot", "class", "cluster",
      "codetools", "foreign", "lattice",  "mgcv", "nlme", "nnet",
      "rpart", "spatial", "survival",
# Missing external software
      "GDD", "OpenCL", "RDF","RDieHarder", "RMongo", "ROAuth",
      "ROracle", "Rcplex", "RScaLAPACK",
      "Rlof", "Rmosek",  "SV", "cplexAPI", "mpc", "mvgraph", "rzmq", "udunits2",
      "ncdf4", "M3", # ncdf4
      "Rsymphony", "ROI.plugin.symphony",
      "CARramps", "cudaBayesreg", "gputools", "magma", # cuda
      "IQMNMR", "Rmpi", "bcool", "doMPI", "rpvm", "npRmpi", "rpud", "sprint", # mpi
# Unix-only
      "R4dfp", "RBerkeley", "ROracleUI", "RProtoBuf",  "TSpadi", "VBmix",
      "WINRPACK", "cit", "cmprskContin", "doMC", "fork", "gcbd",
      "interactivity", "makesweave", "mfr", "multic", "multicore", "nice",
      "parmigene", "polyphemus", "synchronicity", "taskPR", "triggr",
# don't work
      "RWinEdt", # needs Rgui
      "farmR", "rJavax" # horrible Java things
      )

biarch <- c("SQLiteMap", "arulesSequences", "clpAPI", "glpkAPI") # my update of SQLiteMap

multi <- c("Cairo", "Cubist", "FastRWeb", "GWAtoolbox", "JavaGD", "RCurl",
           "RInside", "RJSONIO", "RMySQL", "RPostgreSQL", "Rserve",
           "Rssa", "bigmemory", "maps", "mvabund", "rJava", "rcom", "rgl")

extras <- c("SSOAP", "XMLRPC", "XMLSchema", "yags")

ggobi_users <- c("rggobi", "gcmrec", "magnets", "WMTregions", "beadarrayMSV",
                 "clusterfly", "PKgraph")

if(getRversion() < "2.15.0") {
    nomulti <- c(ggobi_users,
                 "OSACC", # fail to compile, tries to store pointers in long
                 "RSvgDevice", "RSVGTipsDevice", "eco") # crashes
    stoplist <- c(stoplist, "clpAPI", "glpkAPI", "RQuantLib")
} else {
    stoplist <- c(stoplist,
                  "h5r",
                  ## and for 32-bit-only
                  ggobi_users,
                  "hdf5", "satin",
                  "BiGGR") # rsbml
    nomulti <- character()
}
