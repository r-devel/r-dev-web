stoplist <-
    c(
      "ROracle", "ora",
      "Rcplex", "ROI.plugin.cplex",
      "localsolver", "permGPU", 'kmcudaR',
      "IRATER", # no ADMB, so fails checks
      ## need x86
      "BRugs", "Rrdrand",
      ## external tools
      "rcrypt",
      "RcppMeCab", "RmecabKo",
      "RMark",
      "Rblpapi",
      "Rpoppler",
      "caRpools", # MAGeCK
      'rrd') # needs rrdtool libraries


GTK <- c("RGtk2", "cairoDevice")

ban <- c("N2R", 'sccore', 'leidenAlg', 'pagoda2', 'conos',
         'dendsort', 'gapmap', 'scITD')

stoplist <- c(stoplist, ban, GTK)

noinstall <- c(readLines('~/R/packages/noinstall'))
