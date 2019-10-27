stoplist <-
  c(
#      "RMySQL", "TSMySQL", "dbConnect", "Causata", "compendiumdb", "wordbankr", "gmDatabase", "MetaIntegrator", "toxboot", "mdsr", "BETS", "taxizedb", "nowcasting", "GetITRData",
#      "RMariaDB",
      "Boom", "BoomSpikeSlab", "bsts", "CausalImpact", "MarketMatching", "TSstudio", "cbar",
      "MSeasy", "MSeasyTkGUI", "specmine", "CorrectOverloadedPeaks", "LipidMS", "binneR",  # mzR
      "RAMClustR", # xcms
      "RDieHarder", # needs GNU make
      "RDocumentation", # wiped out ~/.Rprofile
      "Rmosek", "REBayes",
      "RProtoBuf", # seems to need version 3 but does not say so
      "RQuantLib", "RVowpalWabbit", "RcppRedis",
      "Rhpc", # needs R as a shared library
      "Rsymphony", "PortfolioOptim", "ROI.plugin.symphony",
      "EthSEQ", "R.SamBada", "dartR", # SNPRelate and gdsfmt, latter fails to install
      "diffMeanVar", "maGUI", # have a ridiculous number of BioC dependencies
      "iptools", "rIP", # /usr/include/net/if.h
      "md.log", # naming
      "multipanelfigure", # crashes on magick
      ## external libs
      "BRugs", 'RQuantLib',
      "RVowpalWabbit", # Boost::Program_Options
      "Rblpapi", "RcppRedis", "gpg",
      "gert", # libgit2
      "h5", "rblt", # C++ interface
      "littler", # needs R as a shared library
      "nmaINLA", # Suggests: INLA
      "opencv",
      "qtbase", "qtpaint", "qtutils",
      "redux", # hiredis
      "rrd",
      "ssh", "qsub", "sybilSBML", "tesseract",
      ## external tools
      "ROI.plugin.cplex", "Rcplex", "cplexAPI",
      "IRATER", # R2admb for anything useful
      "PythonInR", "IGP", "WebGestaltR", "rlo",
      "RAppArmor", "RcppAPT", "RcppMeCab", "Rgretl", "RmecabKo",
      "R2MLwiN",
      "RMark", "R2ucare", "multimark",
      "ROracle", 'ora',
      "Rsagacmd",
      "av", # FFmpeg
      "caRpools", # MAGeCK
      "gifski",  "moveVis", "salso",# Cargo/Rust
      "msgtools",
      "nFCA", # ruby
      "rggobi", "PKgraph", "SeqGrapheR", "beadarrayMSV", "clusterfly",
      "rLindo",
      "rsvg", "ChemmineR", "RIdeogram", "colorfindr", "netSEM", "uCAREChemSuiteCLI", "vtree", "integr",
      "tmuxr"
       )

## Java version >= 8
Java <- c("ChoR", "CrypticIBDcheck", "RKEEL", "RKEELdata", "RKEELjars",
          "RxnSim", "SimuChemPC", "corehunter", "deisotoper", "helixvis",
          "jdx", "jsr223", "qCBA", "rCBA", "rJPSGCS", "rcdk",
          "enviGCMS", "BioMedR", "pmd", # rcdk
          'rscala', 'bamboo', 'sdols', 'shallot',
          'RWeka', 'RWekajars', "AntAngioCOOL", "BASiNET", "Biocomb",
          "DecorateR", "FSelector", "HybridFS", "LLM", "MSIseq",
          "NoiseFiltersR", "RtutoR", "aslib", "lilikoi", "petro.One",
          "smartdata", "streamMOA",
	  "RJDemetra", "ggdemetra", "rjdqa")

CUDA <- # etc
c("cudaBayesreg", "kmcudaR", "permGPU", "localsolver", "OpenCL", "CARrampsOcl", "gpuR", "bayesCL", "gpda")


WindowsOnly <- c("BiplotGUI", "MDSGUI", "R2MLwiN", "R2PPT", "R2wd", "RInno", "RPyGeo", "RWinEdt", "TinnR", "blatr", "excel.link", "installr", "spectrino", "taskscheduleR")

stoplist <- c(stoplist, Java, CUDA)


fakes <- "ROracle"

ll <- c("## Fake installs",
        paste(fakes, "-OPTS = --install=fake", sep=""))
writeLines(ll, "Makefile.fakes")

recommended <-
    c("KernSmooth", "MASS", "Matrix", "boot", "class", "cluster",
      "codetools", "foreign", "lattice", "mgcv", "nlme", "nnet",
      "rpart", "spatial", "survival")
