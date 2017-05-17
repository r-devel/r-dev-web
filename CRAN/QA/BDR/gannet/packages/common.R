stoplist <- c('BiplotGUI', 'MDSGUI', 'R2MLwiN', 'R2PPT', 'R2wd', 'RInno',
	       'RPyGeo', 'RWinEdt', 'blatr', 'excel.link', 'installr', 'spectrino',
               'RcppAPT', 'caRpools', "ROI.plugin.cplex", "CARrampsOcl",
               'RQuantLib', 'PharmacoGx', 'IRATER', "sybilSBML", "kmcudaR")

CUDA <- # etc
c("HiPLARM", "RAppArmor", "RDieHarder", "ROI.plugin.cplex", "ROracle", "RSAP", "Rcplex", "Rhpc", "cplexAPI",  "cudaBayesreg", "gmatrix", "gputools", "magma", "ora", "permGPU", "localsolver",
"OpenCL", "CARrampsOcl", "gpuR", "kmcudaR")

## all C++ interfaces to system software
noclang <- c("RQuantLib", "RcppOctave", "h5", "magick", "sf", "texPreview",
	     "qtbase", "qtpaint", "qtutils")

noinstall <- c("littler", "largeVis", "mcPAFit", "corpus")

noinstall_clang <- c('BAMBI', 'ManifoldOptim')

