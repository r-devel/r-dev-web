stoplist <-
    c("BRugs", "RAppArmor",
     # "RDieHarder",
      "RMark", "ROracle", "RQuantLib",
      "RSAP", "Rcplex", "RcppOctave", "Rpoppler", "ora", "rLindo",
      "ROI.plugin.cplex",
      ## CUDA
      "CARramps", "HiPLARM", "WideLM", "cplexAPI", "cudaBayesreg", "gmatrix",
      "gputools",  'iFes', "localsolver", "magma", "permGPU", "rpud", 'kmcudaR',
      "gpda", "gpuR",
      ## qt users
      "qtbase", "qtpaint", "qtutils", "VBmix",
      "RcppAPT", "caRpools", "rcrypt",
      #"magick", "texPreview", # need C++ interface
      # ggobi no longer builds, binary is linked to old GTK+
      "rggobi", "PKgraph", "SeqGrapheR", "beadarrayMSV", "clusterfly",
      "gpg", "IRATER", "tesseract",
      'argparse', 'optparse', # missing SystemRequirements
      'rpg', 'mssqlR',
      'odbc', "datrProfile", "dbparser", 'dplyr.teradata', 'drfit', "explore", "virtuoso",
      'RmecabKo',
      'opencv',
      ## external tools
      "PythonInR", "IGP", "WebGestaltR", "rlo",
      "RAppArmor", "RcppAPT", "RcppMeCab", "Rgretl", "RmecabKo",
      "RMLwiN", 
      "RMark", "R2ucare", "multimark",
      'Rsagacmd',
      'RPostgres', 'RGreenplum',
      "caRpools", # MAGeCK
#      "gifski", # Cargo/Rust
      'msgtools', # no GNU gettext
      "nFCA", # ruby
      "rsvg", "ChemmineR", "RIdeogram", "colorfindr", "netSEM", "uCAREChemSuiteCLI", "vtree", "integr", "cohorttools", "BioMedR",
      'OpenCL', 'bayesCL',
      'ssh', 'qsub',
      'rrd',
      "tmuxr")

C8 <- readLines('~/R/packages/mzR_fail')

noinstall <- c('rMouse', # AWT headless
	       'isotree',  # missing fn
               'RVowpalWabbit', # 'thread' conflict
               "baseflow", # cargo fails
	       'cyanoFilter','flowDiv', 'beadplexr')
