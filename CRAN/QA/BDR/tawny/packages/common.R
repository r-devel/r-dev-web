stoplist <-
    c("BRugs", "RAppArmor", "RDieHarder", "RMark", "ROracle", "RQuantLib",
      "RSAP", "Rcplex", "RcppOctave", "Rpoppler", "ora", "rLindo",
      "ROI.plugin.cplex",
      ## CUDA
      "CARramps", "HiPLARM", "WideLM", "cplexAPI", "cudaBayesreg", "gmatrix",
      "gputools",  'iFes', "localsolver", "magma", "permGPU", "rpud", 'kmcudaR',
      ## qt users
      "qtbase", "qtpaint", "qtutils", "VBmix",
      "RcppAPT", "caRpools", "rcrypt", "rsvg", "multipanelfigure", "ionicons",
      #"magick", "texPreview", # need C++ interface
      # ggobi no longer builds, binary is linked to old GTK+
      "rggobi", "PKgraph", "SeqGrapheR", "beadarrayMSV", "clusterfly",
      "gpg", "IRATER", "tesseract",
      'miscF', 'agRee', 'PottsUtils', # requires BRugs
      'argparse', 'optparse', # missing SystemRequirements
      'msgtools', # no GNU gettext
      'odbc', 'rpg', 'mssqlR',
      'RDocumentation', # wipes out ~/.Rprofile
      'RmecabKo', 'tmuxr',
      'rscala', 'shallot', 'bamboo', 'sdols', # need Scala (>= 2.11)
      ## Windows-only
      'BiplotGUI', 'MDSGUI', 'R2MLwiN', 'R2PPT', 'R2wd',
      'RPyGeo', 'RWinEdt', "RInno", 'blatr', 'excel.link', 'installr', 'spectrino')

noinstall <- c("R2STATS", "rpg", 'plink', 'rgeolocate', 'mcPAFit', 'bayesCL', 'humarray', 'odbc', 'mongolite', 'healthcareai', 'flowDiv', 'libstableR', 'rMouse', 'rvinecopulib', 'corehunter', 'RPostgres', 'harrietr', 'markmyassignment', 'pbdZMQ')

