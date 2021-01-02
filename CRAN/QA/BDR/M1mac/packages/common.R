stoplist <-
    c("BRugs",
      "ROracle", "RQuantLib", "ora",
      "Rcplex", "Rpoppler", "rLindo", "ROI.plugin.cplex", "cplexAPI",
      "localsolver", "permGPU", 'kmcudaR', "gpuR",
      "IRATER", # ADMB
      'mssqlR',
      'N2R', 'sccore', 'leidenAlg',
      ## memory issues
      'cbq', 'ctsem', 'pcFactorStan',
      ## external tools
      "gpg", "rcrypt",
      "RAppArmor", "RcppAPT", "RcppMeCab", "RmecabKo",
      "RMark", "R2ucare", "multimark",
      "caRpools", # MAGeCK
      "sybilSBML",
      'OpenCL',
      'rrd', # need rrdtool libraries
      'tmuxr')

noinstall <- c('proj4', 
               readLines('~/R/packages/noinstall'))
