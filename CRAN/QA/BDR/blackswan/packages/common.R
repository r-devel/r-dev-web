CUDA <-c("CARramps", "HiPLARM", "RAppArmor", "RDieHarder", "ROracle", "RSAP", "Rcplex", "Rhpc", "WideLM", "cplexAPI",  "cudaBayesreg", "gmatrix", "gputools", "magma", "ora", "permGPU", "rJavax", "rpud", "localsolver", "iFes")

Windows <- c('BiplotGUI', 'MDSGUI', 'R2MLwiN', 'R2PPT', 'R2wd', 'RPyGeo',
              'RWinEdt', 'blatr', 'excel.link', 'installr', 'spectrino',
              'rzmq', 'RcppAPT', 'caRpools')
stoplist <- c("RcppOctave", "OpenCL", "CARrampsOcl", "gpuR",
              "rLindo", "RQuantLib", "TSMySQL",
	      "sodium", "homomorpheR", "remoter",
              "dgmb", # TkTable
	      "Rmosek", "REBayes",
	      "Boom", "BoomSpikeSlab", "bsts",
	      "littler", "gpuR", "rsvg", "pdftools", "hunspell")

noinstall <- c("MSeasy", "MSeasyTkGUI", "specmine", "dynaTree")

stoplist <- c(stoplist, Windows, CUDA)

