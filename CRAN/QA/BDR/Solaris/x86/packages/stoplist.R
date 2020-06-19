stoplist <-
  c(
      "Boom", "BoomSpikeSlab", "bsts", "CausalImpact", "MarketMatching", "TSstudio", "cbar",
      "MSeasy", "MSeasyTkGUI", "specmine", "CorrectOverloadedPeaks", "LipidMS", "binneR",  # mzR
      "RAMClustR", # xcms
      "RDieHarder", # needs GNU make
      "RDocumentation", # wiped out ~/.Rprofile
      "RestRserve",
      "Rmosek", "REBayes",
      "RProtoBuf", "proffer", "factset.protobuf.stach", 
      "RQuantLib", "RVowpalWabbit", "RcppRedis",
      "Rhpc", # needs R as a shared library
      "Rsymphony", "PortfolioOptim", "ROI.plugin.symphony", "strand", 
      "EthSEQ", "R.SamBada", "dartR", "simplePHENOTYPES", # SNPRelate and gdsfmt, latter fails to install
      "arrow", # flaky at best, only a partial install
      "diffMeanVar", "maGUI", # have a ridiculous number of BioC dependencies
      "iptools", "rIP", # /usr/include/net/if.h
      "md.log", # naming
      "multipanelfigure", # crashes on magick
      ## external libs
      "BRugs", 'RQuantLib',
      "RVowpalWabbit", # Boost::Program_Options
      "Rblpapi", "RcppRedis", "gpg",
      "gert", "worcs",# libgit2
      "littler", # needs R as a shared library
      "nmaINLA", # Suggests: INLA
      "opencv",
      "qtbase", "qtpaint", "qtutils",
      "redux", "doRedis",# hiredis
      "rsolr", # hangs check run
      "rrd",
      "ssh", "qsub", "sybilSBML", "tesseract", "neo4jshell",
      ## external tools
      "ROI.plugin.cplex", "Rcplex", "cplexAPI",
      "IRATER", # R2admb for anything useful
      "PythonInR", "IGP", "WebGestaltR",
      "RAppArmor", "RcppAPT", "RcppMeCab", "Rgretl", "RmecabKo",
      "R2MLwiN",
      "RMark", "R2ucare", "multimark",
      "ROracle", 'ora',
      "Rsagacmd",
      "av", # FFmpeg
      "caRpools", # MAGeCK
      "fsdaR", # MATLAB runtime
      "gifski",  "moveVis", "salso", "baseflow", # Cargo/Rust
      "msgtools",
      "nFCA", # ruby
      "rggobi", "PKgraph", "SeqGrapheR", "beadarrayMSV", "clusterfly",
      "rLindo",
      "rsvg", "ChemmineR", "RIdeogram", "colorfindr", "netSEM", "uCAREChemSuiteCLI", "vtree", "integr", "cohorttools", "actel",
      "tmuxr",
      "RcppSimdJson" # C++17
       )

## Java version >= 8
Java <- c("ChoR", "CrypticIBDcheck", "J4R", "RKEEL", "RKEELdata", "RKEELjars",
          "RxnSim", "SimuChemPC", "corehunter", "deisotoper", "helixvis",
          "jdx", "jsr223", "qCBA", "rCBA", "rJPSGCS", "rcdk",
          "enviGCMS", "BioMedR", "pmd", # rcdk
          'rscala', 'bamboo', 'sdols', 'shallot', 'AntMAN', 'aibd',
          'RWeka', 'RWekajars', "AntAngioCOOL", "BASiNET", "Biocomb",
          "DecorateR", "FSelector", "HybridFS", "LLM", "MSIseq",
          "NoiseFiltersR", "RtutoR", "aslib", "lilikoi", "petro.One",
          "smartdata", "streamMOA",
	  "RJDemetra", "ggdemetra", "rjdmarkdown", 
          "rjdqa", "pathfindR", "rsubgroup",
          "rviewgraph")

Java <- c(Java, "XLConnect", "Dominance", "LLSR", "MLMOI", "table1xls", "betadiv")

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
