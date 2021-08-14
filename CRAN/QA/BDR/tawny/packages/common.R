stoplist <-
    c("BRugs",
      "ROracle", "RQuantLib", "ora",
      "Rcplex", "Rpoppler", "rLindo", "ROI.plugin.cplex", "cplexAPI",
      "localsolver", "permGPU", 'kmcudaR', "gpuR",
      "IRATER", # ADMB
      'mssqlR',
      'N2R', 'sccore', 'leidenAlg', 'pagoda2', 'conos', 'dendsort', 'gapmap',
      'modeltime.h2o',
      ## memory issues
      'cbq', 'ctsem', 'pcFactorStan',
      ## hence
      "ctsemOMX", "CoTiMA",
      ## external tools
      "gpg", "rcrypt",
      "RAppArmor", "RcppAPT", "RcppMeCab", "RmecabKo",
      "RMark", "R2ucare", "multimark",
      "rpg", # PostgreSQL
      "caRpools", # MAGeCK
      "rGEDI", # geotiff, szip
      'OpenCL',
      'rrd', # need rrdtool libraries
      'tmuxr')

BH <- c("TDA", "TreeLS", "archiDART", "leafR", "lidR", "mapr", "pflamelet", "pterrace", "topsa","viewshed3d", "wicket")

noinstall <- c('kdtools')

ex <- c('BayesVarSel', 'BullsEyeR', 'LDATS', 'textmineR',
         'textmining', 'tidytext', 'topicdoc', 'topicmodels', 'udpipe')

