stoplist <-
    c("BRugs", "RAppArmor", "RDieHarder", "RMark", "ROracle", "RQuantLib",
      "RSAP", "Rcplex", "RcppOctave", "Rpoppler", "ora", "rLindo",
      "ROI.plugin.cplex",
      ## CUDA
      "CARramps", "HiPLARM", "WideLM", "cplexAPI", "cudaBayesreg", "gmatrix",
      "gputools",  'iFes', "localsolver", "magma", "permGPU", "rpud", 'kmcudaR',
      "gpda",
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
      'RDocumentation', # wipes out ~/.Rprofile
      'RmecabKo', 'tmuxr', "av",
      ## Windows-only
      'BiplotGUI', 'MDSGUI', 'R2MLwiN', 'R2PPT', 'R2wd',
      'RPyGeo', 'RWinEdt', "RInno", 'blatr', 'excel.link', 'installr', 'spectrino')


## MCMCpack etc

cl3 <- c("ndjson", "readtext", "tweet2r", "streamR")

noinstall <- c(cl3, "rpg", 'bayesCL', 'odbc', 'rMouse',
               'RPostgres', 'RGreenplum', 'MSeasy', 'MSeasyTkGUI',
               'specmine', 'RcppCWB', 'rsvg', 'uCAREChemSuiteCLI', 'colorfindr',
               'binneR', 'ITGM', 'fdq', 'CorrectOverloadedPeaks',
               'enviGCMS', 'HiResTEC','cliqueMS', 'ssh',
               'uCAREChemSuiteCLI', 'RcppMeCab', 'dplyr.teradata',
               'polmineR', 'netSEM', 'rrd', 'peakPantheR', 'LipidMS',
               'qsub', "IRTpp", "R2STATS",
	'PythonInR', 'IGP', 'WebGestaltR','rlo', 'vtree')

