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
      "RAppArmor", "RcppAPT", "RcppMeCab", "RmecabKo",
      "RMark", "R2ucare", "multimark",
      "rpg", # PostgreSQL
      "caRpools", # MAGeCK
      "sybilSBML",
      "rGEDI", # geotiff, szip
      'OpenCL',
      'rrd', # need rrdtool libraries
      'tmuxr')

noinstall <- c('proj4', 'SPARSEMODr', 'OptCirClust')

ex <- c('BayesVarSel', 'BullsEyeR', 'LDATS', 'textmineR',
         'textmining', 'tidytext', 'topicdoc', 'topicmodels', 'udpipe')

