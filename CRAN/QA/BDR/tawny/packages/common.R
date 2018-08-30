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
      'odbc', 'rpg', 'mssqlR',
      'RDocumentation', # wipes out ~/.Rprofile
      'RmecabKo', 'tmuxr',
#      'rscala', 'shallot', 'bamboo', 'sdols', # need Scala (>= 2.11)
      ## Windows-only
      'BiplotGUI', 'MDSGUI', 'R2MLwiN', 'R2PPT', 'R2wd',
      'RPyGeo', 'RWinEdt', "RInno", 'blatr', 'excel.link', 'installr', 'spectrino')


## MCMCpack etc

cl2 <- c("ANOM", "BSagri", "BayesESS", "BayesLCA", "BayesMed",
	 "BayesSingleSub", "Bergm", "CARBayes", "CoinMinD", "DAC",
	 "DMRMark", "DPtree", "Demerelate", "HKprocess", "HWEBayes",
	 "MBSGS", "MBSP", "MCMCpack", "MCPAN", "MHTcop", "MixSIAR",
	 "NSUM", "NetworkChange", "PANICr", "PLMIX", "PhViD",
	 "PortRisk", "PottsUtils", "REIDS", "RSAP", "RcppAPT",
	 "RxCEcolInf", "SimpleTable", "SizeEstimation", "StVAR",
	 "WhatIf", "Zelig", "ZeligChoice", "ZeligEI", "adaptsmoFMRI",
	 "agRee", "anominate", "bacr", "bayespref", "bhrcr",
	 "blavaan", "caRpools", "coarseDataTools", "dartR", "evolqg",
	 "fdrDiscreteNull", "fts", "gset", "hzar", "manet", "miscF",
	 "mvst", "ndjson", "noncomplyR", "optDesignSlopeInt",
	 "pCalibrate", "pairwiseCI", "popdemo", "quokar",
	 "radmixture", "readtext", "robustsae", "sizeMat", "spagmix",
	 "sparsereg", "spikeSlabGAM", "ssmsn", "starmie", "streamR",
	 "tweet2r", "twl", "uskewFactors", "zeligverse")

noinstall <- c(cl2, "rpg", 'bayesCL', 'humarray', 'odbc', 'rMouse',
               'RPostgres', 'RGreenplum', 'MSeasy', 'MSeasyTkGUI',
               'specmine', 'RcppCWB', 'rsvg', 'uCAREChemSuiteCLI',
               'binneR', 'ITGM', 'fdq', 'CorrectOverloadedPeaks',
               'enviGCMS', 'HiResTEC','cliqueMS', 'ssh',
               'uCAREChemSuiteCLI', 'RcppMeCab', 'dplyr.teradata',
               'polmineR', 'netSEM', 'rrd', 'peakPantheR', 'LipidMS',
               'imagerExtra', 'qsub')

