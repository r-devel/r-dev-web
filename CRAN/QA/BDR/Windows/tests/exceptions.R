stoplist <-
    c(# recommended
      "KernSmooth", "MASS", "Matrix","boot", "class", "cluster",
      "codetools", "foreign", "lattice",  "mgcv", "nlme", "nnet",
      "rpart", "spatial", "survival",
# Missing external software
      "GDD", "OpenCL", "RDF","RDieHarder", "RMongo", "ROAuth", "ROracle",
      "Rcplex", "RScaLAPACK", "Rlof", "Rmosek",  "SV", "cplexAPI", "h5r",
      "mimR", "mvgraph", "rzmq",
      "ncdf4", "M3", # ncdf4
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

biarch <- c("SQLiteMap", "arulesSequences", "udunits2") # my update of SQLiteMap

multi <- c("Cairo", "Cubist", "FastRWeb", "GWAtoolbox", "JavaGD", "RCurl",
           "RInside", "RJSONIO", "RMySQL", "RPostgreSQL", "Rserve",
           "Rssa", "bigmemory", "maps", "rJava", "rcom", "rgl")

extras <- c("XMLRPC", "yags")

ggobi_users <- c("rggobi",  "PKgraph", "WMTregions", "beadarrayMSV",
                 "clusterfly", "magnets")

if(getRversion() < "2.15.0") {
    nomulti <- c(ggobi_users,
                 "OSACC", # fail to compile, tries to store pointers in long
                 "RSvgDevice", "RSVGTipsDevice", "eco") # crashes
} else {
    stoplist <- c(stoplist, ## and for 32-bit-only
                  ggobi_users, "hdf5", "satin", "BiGGR") # rsbml
    nomulti <- character()
}
