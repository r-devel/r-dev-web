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
      "Rmpi", "pbdMPI", "pbdPROF",
      "bigGP", "doMPI", "kazaam", "metaMix", "moc.gapbk", "pbdBASE", "pbdSLAP", "regRSM",
      "gpg", "rcrypt",
      "RAppArmor", "RcppAPT", "RcppMeCab", "RmecabKo",
      "RMark", "R2ucare", "multimark",
      "caRpools", # MAGeCK
#      "sybilSBML",
      'OpenCL',
      'rrd', # needs rrdtool libraries
      'tmuxr')

BH <- c("CoordinateCleaner", "TDA", "TreeLS", "archiDART", "bRacatus", "bdchecks", "bdclean", "gde", "leafR", "lidR", "mapr", "rangeModelMetadata", "occCite", "pflamelet", "pterrace", "rgbif", "spocc", "topsa", "viewshed3d", "wallace", "wicket")

noinstall <- c('proj4', BH,
               readLines('~/R/packages/noinstall'))
