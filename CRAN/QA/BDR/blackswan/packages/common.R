CUDA <-c("CARramps", "HiPLARM", "RAppArmor", "RDieHarder", "ROI.plugin.cplex", "ROracle", "RSAP", "Rcplex", "Rhpc", "WideLM", "cplexAPI",  "cudaBayesreg", "gmatrix", "gputools", "magma", "ora", "permGPU", "rJavax", "rpud", "localsolver", "iFes")

Windows <- c('BiplotGUI', 'MDSGUI', 'R2MLwiN', 'R2PPT', 'R2wd', 'RPyGeo',
              'RWinEdt', 'blatr', 'excel.link', 'installr', 'spectrino',
              'rzmq', 'RcppAPT', 'caRpools')
stoplist <- c("RcppOctave", "OpenCL", "CARrampsOcl", "gpuR",
              "rLindo", "RQuantLib", "TSMySQL",
	      "sodium", "homomorpheR", "remoter",
	      "Rmosek", "REBayes",
	      "Boom", "BoomSpikeSlab", "bsts",
	      "littler", "gpuR", "rsvg", "pdftools", "pdfsearch",
              "multipanelfigure", "magick", "rbi", "IRATER", "tesseract")

noinstall <- c("littler", 'RSQLServer', 'deeplearning', "wand", "QCAtools", "ecd", "expint")

stoplist <- c(stoplist, Windows, CUDA)

