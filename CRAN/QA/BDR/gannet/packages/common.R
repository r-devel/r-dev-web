stoplist <- c('BiplotGUI', 'MDSGUI', 'R2MLwiN', 'R2PPT', 'R2wd', 'RPyGeo',
               'RWinEdt', 'blatr', 'excel.link', 'installr', 'spectrino',
               'RcppAPT', 'caRpools', "ROI.plugin.cplex", "CARrampsOcl",
               'RQuantLib', 'PharmacoGx', 'IRATER')

CUDA <- # etc
c("HiPLARM", "RAppArmor", "RDieHarder", "ROI.plugin.cplex", "ROracle", "RSAP", "Rcplex", "Rhpc", "cplexAPI",  "cudaBayesreg", "gmatrix", "gputools", "magma", "ora", "permGPU", "localsolver",
"OpenCL", "CARrampsOcl", "gpuR")

## all C++ interfaces to system software
noclang <- c("RQuantLib", "RcppOctave", "h5", "magick", "sf")

noinstall <- c("littler", 'deeplearning', "DNAprofiles", "sybilSBML", "uroot", "DNAtools", "timetools")

noinstall_clang <- c('BAMBI', 'qtbase', 'qtpaint', 'qtutils', 'ManifoldOptim', 'dfpk')

