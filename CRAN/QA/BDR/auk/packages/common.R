stoplist <-
    c("CARramps", "HiPLARM", "RAppArmor", "RDieHarder",
      "REBayes", "RMark", "RMongo", "ROracle", "RQuantLib",
      "RSAP", "Rcplex", "Rhpc", "Rmosek", 
      "WideLM", "cplexAPI", "cudaBayesreg", "gputools", "gmatrix", "magma", "ora",
      "permGPU", "rJavax", "rLindo", "rmongodb", "rpud", "rsproxy", "sprint",
      "localsolver", "cqrReg", "iFes")

stoplist <- c(stoplist, 'BiplotGUI', 'MDSGUI', 'R2MLwiN', 'R2PPT', 'R2wd',
              'RPyGeo', 'RWinEdt', 'excel.link', 'installr',
              'BayesXsrc', 'R2BayesX')
