stoplist <-
    c(
      "ROracle", "RQuantLib", "ora",
      "Rcplex", "Rpoppler", "ROI.plugin.cplex", "cplexAPI",
      "localsolver", "permGPU", 'kmcudaR',
      "IRATER", # ADMB, so fails checks
      'mssqlR', # hangs
      ## memory issues
#      'cbq', 'ctsem', 'pcFactorStan',
      ## need x86
      "BRugs",
      "Rrdrand",
      ## external tools
      "rcrypt",
      "RcppMeCab", "RmecabKo",
      "RMark",
      "Rblpapi",
      "caRpools", # MAGeCK
      'rrd') # needs rrdtool libraries
#      'dietr')

ban <- c('N2R', 'sccore', 'leidenAlg', 'pagoda2', 'conos')

GTK <- c("DataEntry", "RSCABS", "RGtk2", "StatCharrms", "cairoDevice", "gWidgets2RGtk2", "icardaFIGSr", "maGUI", "plfMA", "sara4r", "smartR", "vmsbase", "x12GUI")

stoplist <- c(stoplist, ban, GTK)

noinstall <- c(
               readLines('~/R/packages/noinstall'))
