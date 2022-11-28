stoplist <-
    c(
      "permGPU", 'kmcudaR',
      ## fails its checks with 1.23, segfaults with 1.28
      "RQuantLib",
      ## need x86
      "BRugs", "Rrdrand",
      ## external tools
      "RMark",
      "ROracle", "ora",
      "Rblpapi",  # only x86_64 binaries
      "Rcplex", "ROI.plugin.cplex",
      "RcppMeCab", "RmecabKo",
      "caRpools", # MAGeCK
      "gcbd",     # Debian, Nvidia GPU
      "localsolver",
      "rcrypt",   # GnuPG
      'rrd') # needs rrdtool libraries


ban <- c("N2R", 'sccore', 'leidenAlg', 'pagoda2', 'conos', 'edlibR', 'Rook', 'numbat', 'vrnmf', 'gapmap', 'nda', 'scITD')

stoplist <- c(stoplist, ban)

noinstall <- c(readLines('~/R/packages/noinstall'))
