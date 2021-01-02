stoplist <-
  c(
      "Boom", "BoomSpikeSlab", "bsts", "CausalImpact", "MarketMatching", "TSstudio", "cbar",
      "N2R", "sccore", "leidenAlg",
      "RDieHarder", # needs GNU make
      "RDocumentation", # wiped out ~/.Rprofile
      "RestRserve",
      "Rmosek", "REBayes", "RCBR", "NPMLEmix", "dipw",
      "Rhpc", # needs R as a shared library
      "Rsymphony", "PortfolioOptim", "ROI.plugin.symphony", "strand", 
      "arrow", "starvz",# flaky at best, only a partial install
      "iptools", "rIP", # /usr/include/net/if.h
      "md.log", # naming
      "multipanelfigure", # crashes on magick
      ## other packages, usually BioC
      "RAMClustR", "specmine.datasets",# xcms
      "MSeasy", "MSeasyTkGUI", "specmine", "CorrectOverloadedPeaks", "LipidMS", "binneR",  # mzR
      "EthSEQ", "R.SamBada", "dartR", "simplePHENOTYPES", # SNPRelate and gdsfmt, latter fails to install
      "Brundle", "Mega2R", "MetaClean",
      "SubtypeDrug",# ChemineR requires rsvg
      "diffMeanVar", "maGUI", # have a ridiculous number of BioC dependencies
      "GMMAT", "RsqMed", 
      "coxmeg",
      ## external libs
      "BRugs", 'RQuantLib',
      "RVowpalWabbit", # Boost::Program_Options
      "RProtoBuf", "proffer", "factset.protobuf.stach", "acumos",
      "Rblpapi", "RcppRedis", "gpg",
      "gert", "worcs",# libgit2
      "littler", # needs R as a shared library
      "nmaINLA", # Suggests: INLA
      "opencv", "image.textlinedetector",
      "qtbase", "qtpaint", "qtutils",
      "redux", "doRedis",# hiredis
      "rsolr", "trackr", # hangs check run
      "rrd",
      "ssh", "qsub", "sybilSBML", "tesseract", "neo4jshell",
      #"textshaping",
      ## external tools
      "ROI.plugin.cplex", "Rcplex", "cplexAPI",
      "IRATER", # R2admb for anything useful
      "PythonInR", "IGP", "WebGestaltR",
      "RAppArmor", "RcppAPT", "RcppMeCab", "Rgretl", "RmecabKo",
      "R2MLwiN",
      "RMark", "R2ucare", "multimark",
      "ROracle", 'ora',
      #"RPostgres", "oxcovid19", "RGreenplum", "DIZutils", "podr", "ggquickeda",
      "Rsagacmd",
      "av", # FFmpeg
      "caRpools", # MAGeCK
      "fsdaR", # MATLAB runtime
      "gifski",  "moveVis", "salso", "baseflow", # Cargo/Rust
      "msgtools",
      "nFCA", # ruby
      "rggobi", "PKgraph", "SeqGrapheR", "beadarrayMSV", "clusterfly",
      "rLindo",
      "rsvg", "ChemmineR", "RIdeogram", "colorfindr", "netSEM", "uCAREChemSuiteCLI", "vtree", "integr", "cohorttools", "actel", "AdhereRViz", "plethem", "svgtools", "chess",
      "tmuxr",
      "RcppSimdJson", "simfinapi", # C++17
      "tiledb"  # blacklisted
       )

## Java version >= 8
Java <- c("ChoR", "CrypticIBDcheck", "J4R", "RKEEL", "RKEELdata", "RKEELjars",
          "RxnSim", "SimuChemPC", "corehunter", "deisotoper", "helixvis",
          "jdx",  "r5r", #hence
          "jsr223", "qCBA", "rCBA", "rJPSGCS", "rcdk",
          "enviGCMS", "BioMedR", "pmd", "chemmodlab", "MetaDBparse", # rcdk
          'rscala', 'bamboo', 'sdols', 'shallot', 'AntMAN', 'aibd',
          'RWeka', 'RWekajars', "AntAngioCOOL", "BASiNET", "Biocomb",
          "DecorateR", "FSelector", "HybridFS", "LLM", "MSIseq",
          "NoiseFiltersR", "RtutoR", "aslib", "lilikoi", "petro.One",
          "smartdata", "streamMOA", "DIscBIO",
	  "RJDemetra", "ggdemetra", "rjdmarkdown", 
          "rjdqa", "pathfindR", "rsubgroup",
          "rviewgraph")

Java <- c(Java, "XLConnect", "Dominance", "LLSR", "MLMOI", "table1xls", "betadiv", "xlsimple", 'staplr')

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
