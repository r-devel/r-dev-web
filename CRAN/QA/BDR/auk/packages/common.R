stoplist <-
    c("HiPLARM", "RAppArmor", "RDieHarder",
      "REBayes", "RMark", "RMongo", "ROI.plugin.cplex", "ROracle", "RQuantLib",
      "RSAP", "Rcplex", "Rhpc", "Rmosek", 
      "cplexAPI", "cudaBayesreg", "gputools", "gmatrix", "magma", "ora",
      "permGPU", "rLindo", "rmongodb", "sprint",
      "localsolver", "RcppAPT", "caRpools", "gpuR", "littler",
      "Boom", "BoomSpikeSlab", "bsts",
      "csp", # too much memory
      "pdftools", "hunspell", "protolite")

stoplist <- c(stoplist, 'BiplotGUI', 'MDSGUI', 'R2MLwiN', 'R2PPT', 'R2wd',
              'RPyGeo', 'RWinEdt', 'excel.link', 'installr')

noinstall <- c('Statomica', 'RSQLServer', 'aemo', "gsl")
