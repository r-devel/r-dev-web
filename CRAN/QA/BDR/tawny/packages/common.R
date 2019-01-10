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
      'miscF', 'agRee', 'PottsUtils', # requires BRugs
      'argparse', 'optparse', # missing SystemRequirements
      'msgtools', # no GNU gettext
      'odbc', 'rpg', 'mssqlR', 'drfit',
#      'RDocumentation', # wipes out ~/.Rprofile
      'RmecabKo', 'tmuxr', "av",
      ## external tools
      "PythonInR", "IGP", "WebGestaltR", "rlo",
      "RAppArmor", "RcppAPT", "RcppMeCab", "Rgretl", "RmecabKo",
      "RMLwiN", "RMark", "R2ucare", "multimark",
      'RPostgres', 'RGreenplum',
      "caRpools", # MAGeCK
      "gifski", # Cargo/Rust
      "msgtools",
      "nFCA", # ruby
      "rsvg", "ChemmineR", "RIdeogram", "colorfindr", "netSEM", "uCAREChemSuiteCLI", "vtree",
      "tmuxr")


noinstall <- c("rpg", 'bayesCL', 'odbc', 'rMouse', "rrd", "dbparser",
               'RcppCWB', 'ssh', 'dplyr.teradata',
               'polmineR', 'qsub', "R2STATS", 'pkgcache')
