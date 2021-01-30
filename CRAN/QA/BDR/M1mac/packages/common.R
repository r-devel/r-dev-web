stoplist <-
    c("BRugs",
      "ROracle", "RQuantLib", "ora",
      "Rcplex", "Rpoppler", "rLindo", "ROI.plugin.cplex", "cplexAPI",
      "localsolver", "permGPU", 'kmcudaR', "gpuR",
      "IRATER", # ADMB
      'mssqlR',
      'N2R', 'sccore', 'leidenAlg', 'pagoda2',
      ## memory issues
      'cbq', 'ctsem', 'pcFactorStan',
      ## need x86
      "Rrdrand",
      ## external tools
#      "Rhpc", "Rmpi", "pbdMPI", "pbdPROF",
#      "bigGP", "doMPI", "kazaam", "metaMix", "moc.gapbk", "pbdBASE", "pbdSLAP", "regRSM",
      "gpg", "rcrypt",
      "RAppArmor", "RcppAPT", "RcppMeCab", "RmecabKo",
      "RMark", "R2ucare", "multimark",
      "caRpools", # MAGeCK
#      "sybilSBML",
      'OpenCL',
      'rrd', # needs rrdtool libraries
      'tmuxr')

BH <- c("TDA", "archiDART", "leafR", "lidR", "mapr", "pflamelet", "pterrace", "topsa", "wicket")

GTK <- c("Blaunet", "CITAN", "DataEntry", "GFD", "RSCABS", "RGtk2", "StatCharrms", "cairoDevice", "gWidgets2RGtk2", "maGUI", "plfMA", "sara4r", "smartR", "vmsbase", "x12GUI")

stoplist <- c(stoplist, GTK)

noinstall <- c('proj4', BH, 
               readLines('~/R/packages/noinstall'))
