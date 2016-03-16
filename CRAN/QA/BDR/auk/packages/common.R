stoplist <-
    c("HiPLARM", "RAppArmor", "RDieHarder",
      "REBayes", "RMark", "RMongo", "ROracle", "RQuantLib",
      "RSAP", "Rcplex", "Rhpc", "Rmosek", 
      "cplexAPI", "cudaBayesreg", "gputools", "gmatrix", "magma", "ora",
      "permGPU", "rLindo", "rmongodb", "sprint",
      "localsolver", "RcppAPT", "caRpools", "gpuR", "littler",
      "pdftools", "hunspell")

stoplist <- c(stoplist, 'BiplotGUI', 'MDSGUI', 'R2MLwiN', 'R2PPT', 'R2wd',
              'RPyGeo', 'RWinEdt', 'excel.link', 'installr')

noinstall <- c('MSeasy', 'MSeasyTkGUI', 'specmine', 'littler', 'dynaTree')
