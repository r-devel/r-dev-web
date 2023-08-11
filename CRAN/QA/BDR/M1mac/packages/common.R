stoplist <-
    c("permGPU", 'kmcudaR',
      ## need x86
      "BRugs", "Rrdrand",
      ## external tools
      "RMark", # only x86_64 binaries, not signed
      "ROracle", "ora",
      "Rblpapi",  # only x86_64 binaries
      "Rcplex", "ROI.plugin.cplex", # commercial
      "RcppMeCab", "RmecabKo",
      "caRpools", # MAGeCK
      "gcbd",     # Debian, Nvidia GPU
      "localsolver",
      "rcrypt")   # GnuPG


ban <- c("N2R", 'sccore', 'leidenAlg', 'pagoda2', 'conos', 'edlibR', 'Rook', 'numbat', 'vrnmf', 'gapmap', 'nda', 'scITD')

stoplist <- c(stoplist, ban)

noinstall <- c(readLines('~/R/packages/noinstall', warn = FALSE))
