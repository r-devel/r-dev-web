stoplist <-
    c("BRugs", "RAppArmor", "RDieHarder", "RMark", "ROracle", "RQuantLib",
      "RSAP", "Rcplex", "RcppOctave", "Rpoppler", "ora", "pdftools", "rLindo",
      ## CUDA
      "CARramps", "HiPLARM", "WideLM", "cplexAPI", "cudaBayesreg", "gmatrix",
      "gputools",  'iFes', "localsolver", "magma", "permGPU", "rpud",
      ## qt users
      "qtbase", "qtpaint", "qtutils", "VBmix",
      #"RMySQL", "Causata", "TSMySQL",  "compendiumdb", "dbConnect",
      "RcppAPT", "caRpools", "rcrypt", "rsvg", "hunspell",
      "Boom", "BoomSpikeSlab", "bsts",
      # ggobi no longer builds, binary is linked to old GTK+
      "rggobi", "PKgraph", "SeqGrapheR", "beadarrayMSV", "clusterfly",
      ## Windows-only
      'BiplotGUI', 'MDSGUI', 'R2MLwiN', 'R2PPT', 'R2wd',
      'RPyGeo', 'RWinEdt', 'blatr', 'excel.link', 'installr', 'spectrino')

noinstall <- c("R2STATS", "gpuR", 'dynaTree', 'rmumps', 'PAC', 'rmcfs')

noinstall <- c(noinstall, "MSeasy", "MSeasyTkGUI", "specmine", "Statomica")

