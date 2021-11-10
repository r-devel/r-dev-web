stoplist <-
    c(
      "ROracle", "RQuantLib", "ora",
      "Rcplex", "Rpoppler", "ROI.plugin.cplex",
      "localsolver", "permGPU", 'kmcudaR',
      "IRATER", # ADMB, so fails checks
      'mssqlR', # hangs
      ## need x86
      "BRugs", "Rrdrand",
      ## external tools
      "rcrypt",
      "RcppMeCab", "RmecabKo",
      "RMark",
      "Rblpapi",
      "caRpools", # MAGeCK
      'rrd') # needs rrdtool libraries


GTK <- c("RGtk2", "cairoDevice")

ban <- c("N2R", 'sccore', 'leidenAlg', 'pagoda2', 'conos',
         'dendsort', 'gapmap', 'scITD')

stoplist <- c(stoplist, ban, GTK)

noinstall <- c(readLines('~/R/packages/noinstall'))
