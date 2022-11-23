stoplist <-
    c(
      "permGPU", 'kmcudaR',
      ## need x86
      "BRugs", "Rrdrand",
      ## external tools
      "RMark",
      "ROracle", "ora",
      "Rblpapi",
      "Rcplex", "ROI.plugin.cplex",
      "RcppMeCab", "RmecabKo",
      "caRpools", # MAGeCK
      "gcbd",
      "localsolver",
      "rcrypt",   # GnuPG
      'rrd') # needs rrdtool libraries


ban <- c("N2R", 'sccore', 'leidenAlg', 'pagoda2', 'conos', 'edlibR', 'Rook', 'numbat', 'vrnmf', 'gapmap', 'nda', 'scITD')

stoplist <- c(stoplist, ban)

noinstall <- c(readLines('~/R/packages/noinstall'))
