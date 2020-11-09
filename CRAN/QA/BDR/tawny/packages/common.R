stoplist <-
    c("BRugs",
      "ROracle", "RQuantLib", "ora",
      "Rcplex", "Rpoppler", "rLindo", "ROI.plugin.cplex", "cplexAPI",
      "localsolver", "permGPU", 'kmcudaR', "gpuR",
      "IRATER", # ADMB
      'mssqlR',
      ## memory issues
      'cbq', 'ctsem', 'pcFactorStan',
      ## external tools
      "RAppArmor", "RcppAPT", "RcppMeCab", "RmecabKo",
      "RMark", "R2ucare", "multimark",
      "rpg", # PostgreSQL
      "caRpools", # MAGeCK
      "sybilSBML",
      "rGEDI", # geotiff
      'OpenCL',
      'rrd', # need rrdtool libraries
      'tmuxr')

noinstall <- c('proj4', 'N2R', 'sccore', 'GWmodel’, 'GWnnegPCA', 'GWpcor')
