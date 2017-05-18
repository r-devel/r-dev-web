CUDA <-c("CARramps", "HiPLARM", "RAppArmor", "RDieHarder", "ROI.plugin.cplex", "ROracle", "RSAP", "Rcplex", "Rhpc", "WideLM", "cplexAPI",  "cudaBayesreg", "gmatrix", "gputools", "magma", "ora", "permGPU", "rJavax", "rpud", "localsolver", "iFes", "kmcudaR")

Windows <- c('BiplotGUI', 'MDSGUI', 'R2MLwiN', 'R2PPT', 'R2wd', 'RPyGeo',
              'RWinEdt', 'blatr', 'excel.link', 'installr', 'spectrino',
              'rzmq', 'RcppAPT', 'caRpools', 'RInno')
stoplist <- c("RcppOctave", "OpenCL", "CARrampsOcl", "gpuR",
              "rLindo", "RQuantLib", "TSMySQL",
	      "sodium", "safer", "homomorpheR", "remoter",
	      "Rmosek", "REBayes",
	      "Boom", "BoomSpikeSlab", "bsts",
	      "littler", "gpuR", "rsvg", "pdftools", "pdfsearch", "textreadr",
              "multipanelfigure", "magick", "rbi", "IRATER", "tesseract",
	      "texPreview", "bayesCL", "crminer", "mcPAFit")

noinstall <- c("littler", "wand", 'sybilSBML', 'ionicons', 'largeVis', "corpus")

stoplist <- c(stoplist, Windows, CUDA)

