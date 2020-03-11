stoplist <-
    c("BRugs", "RAppArmor",
      "RMark", "ROracle", "RQuantLib",
      "RSAP", "Rcplex", "RcppOctave", "Rpoppler", "ora", "rLindo",
      "ROI.plugin.cplex",
      ## CUDA
      "CARramps", "HiPLARM", "WideLM", "cplexAPI", "cudaBayesreg", "gmatrix",
      "gputools",  'iFes', "localsolver", "magma", "permGPU", "rpud", 'kmcudaR',
      "gpda", "gpuR",
      ## qt users
      "qtbase", "qtpaint", "qtutils", "VBmix",
      "RcppAPT", 
      "rcrypt", # needs gpg
      #"magick", "texPreview", # need C++ interface
      ## ggobi no longer builds, binary is linked to old GTK+
      "rggobi", "PKgraph", "SeqGrapheR", "beadarrayMSV", "clusterfly",
      "gpg", "IRATER", "tesseract",
      'argparse', 'optparse', # missing SystemRequirements
      'rpg', 'mssqlR',
      'RmecabKo',
      'opencv',
      'ecmwfr', ## never returns
      'arrow',
      ## memory issues
      'cbq', 'ctsem', 'pcFactorStan',
      ## external tools
      #"PythonInR", "IGP", "WebGestaltR", "rlo",
      "RAppArmor", "RcppAPT", "RcppMeCab", "Rgretl", "RmecabKo",
      "RMLwiN", 
      "RMark", "R2ucare", "multimark",
      'Rsagacmd',
      'RPostgres', 'RGreenplum',
      "caRpools", # MAGeCK
      'msgtools', # no GNU gettext
      "nFCA", # ruby
      "rsvg", "ChemmineR", "RIdeogram", "colorfindr", "netSEM", "uCAREChemSuiteCLI", "vtree", "integr", "cohorttools", "BioMedR",
      'OpenCL', 'bayesCL',
      'rrd', # need rrdtool libraries
      "tmuxr")

C8 <- readLines('~/R/packages/mzR_fail')

noinstall <- c('rMouse', # AWT headless
               'skeleSim', 'tsmp', "symengine", "PythonInR",
               'RVowpalWabbit', # 'thread' conflict
	       'cyanoFilter','flowDiv', 'beadplexr')
