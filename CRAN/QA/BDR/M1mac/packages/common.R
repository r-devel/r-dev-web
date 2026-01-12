stoplist <-
    c("permGPU", 'kmcudaR',
      ## external tools
      "RMark", # only x86_64 binaries, not signed
      "ROracle", "ora",
      "Rblpapi",  # only x86_64 binaries
      "Rcplex", "ROI.plugin.cplex", # commercial
      "RcppMeCab", "RmecabKo",
      "caRpools", # MAGeCK
      "gcbd",     # Debian, Nvidia GPU
      "localsolver",
      "nser",
      "partialling.out",
      "rcrypt")   # GnuPG

noinstall <- readLines('~/R/packages/noinstall', warn = FALSE)
noinstall <- grep("^#", noinstall, value = TRUE, invert = TRUE)
