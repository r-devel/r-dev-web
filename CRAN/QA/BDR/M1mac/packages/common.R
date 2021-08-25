stoplist <-
    c("BRugs",
      "ROracle", "RQuantLib", "ora",
      "Rcplex", "Rpoppler", "rLindo", "ROI.plugin.cplex", "cplexAPI",
      "localsolver", "permGPU", 'kmcudaR', "gpuR",
      "IRATER", # ADMB
      'mssqlR',
      'N2R', 'sccore', 'leidenAlg', 'pagoda2', 'conos',
      'modeltime.h2o',
      ## memory issues
      'cbq', 'ctsem', 'pcFactorStan',
      ## need x86
      "Rrdrand",
      ## external tools
      "gpg", "rcrypt",
      "RAppArmor", "RcppAPT", "RcppMeCab", "RmecabKo",
      "RMark", "R2ucare", "multimark",
      "Rblpapi",
      "caRpools", # MAGeCK
      'OpenCL',
      'rrd', # needs rrdtool libraries
      'dietr',
#      'tiledb',
      'tmuxr')

GTK <- c("Blaunet", "CITAN", "DataEntry", "GFD", "RSCABS", "RGtk2", "StatCharrms", "cairoDevice", "gWidgets2RGtk2", "icardaFIGSr", "maGUI", "plfMA", "sara4r", "smartR", "vmsbase", "x12GUI")

stoplist <- c(stoplist, GTK)

noinstall <- c(
               readLines('~/R/packages/noinstall'))
