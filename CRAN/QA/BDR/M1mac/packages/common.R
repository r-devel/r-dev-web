stoplist <-
    c("permGPU", 'kmcudaR',
      ## need x86
      "Rrdrand",
      ## external tools
      "RMark", # only x86_64 binaries, not signed
      "ROracle", "ora",
      "Rblpapi",  # only x86_64 binaries
      "Rcplex", "ROI.plugin.cplex", # commercial
      "RcppMeCab", "RmecabKo",
      "caRpools", # MAGeCK
      "gcbd",     # Debian, Nvidia GPU
      "localsolver",
      "partialling.out",
      "rcrypt")   # GnuPG

noinstall <- c(readLines('~/R/packages/noinstall', warn = FALSE))
