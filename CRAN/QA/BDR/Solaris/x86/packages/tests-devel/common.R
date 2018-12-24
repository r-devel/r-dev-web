stoplist <-
  c(
#      "RMySQL", "TSMySQL", "dbConnect", "Causata", "compendiumdb", "wordbankr", "gmDatabase", "MetaIntegrator", "toxboot", "mdsr", "BETS", "taxizedb", "nowcasting", "GetITRData",
#      "RMariaDB",
      "Boom", "BoomSpikeSlab", "bsts", "CausalImpact", "TSstudio", "cbar",
      "MSeasy", "MSeasyTkGUI", "specmine", "CorrectOverloadedPeaks", "LipidMS", "binneR",  # mzR
      "MonetDBLite", 'restez', # installation failure
      "RDocumentation", # wiped out ~/.Rprofile
      "RProtoBuf", # seems to need version 3 but does not say so
      "Rsymphony", "ROI.plugin.symphony",
      "dartR", # SNPRelate and gdsfmt, latter fails to install
      "diffMeanVar", "maGUI", # have a ridiculous number of BioC dependencies
      "iptools", # /usr/include/net/if.h
      "md.log", # naming
      "multipanelfigure", # crashes on magick
      ## external libs
      "BRugs", "REBayes", 'RQuantLib',
      "RVowpalWabbit", # Boost::Program_Options
      "Rblpapi", "RcppRedis", "Rmosek", "gpg",
      "h5", # C++ interface
      "keyring", "crypto", "togglr",
      "nmaINLA", # Suggests: INLA
      "qtbase", "qtpaint", "qtutils",
      "redland", "rdflib", "datapack", "dataone",
      "redux", # hiredis
      "sodium", "homomorpheR", "safer",
      "ssh", "sybilSBML", "tesseract",
      ## external tools
      "IRATER", # R2admb for anything useful
      "PythonInR", "IGP", "WebGestaltR", "rlo",
      "RAppArmor", "RcppAPT", "RcppMeCab", "Rgretl", "RmecabKo",
      "RMark", "R2ucare", "multimark",
      "RMongo", "ROracle",
      "av", # FFmpeg
      "caRpools", # MAGeCK
      "gifski", # Cargo/Rust
      "msgtools",
      "nFCA", # ruby
      "rggobi", "PKgraph", "SeqGrapheR", "beadarrayMSV", "clusterfly",
      "rsvg", "ChemmineR", "colorfindr", "netSEM", "uCAREChemSuiteCLI", "vtree",
      "tmuxr"
       )

## Java version >= 8
Java <- c("ChoR", "CrypticIBDcheck", "RKEEL", "RKEELdata", "RKEELjars",
          "RxnSim", "SimuChemPC", "corehunter", "deisotoper", "helixvis",
          "jdx", "jsr223", "qCBA", "rCBA", "rJPSGCS", "rcdk",
          "enviGCMS", # rcdk
          'rscala', 'bamboo', 'sdols', 'shallot',
          'RWeka', 'RWekajars', "AntAngioCOOL", "BASiNET", "Biocomb",
          "DecorateR", "FSelector", "HybridFS", "LLM", "MSIseq",
          "NoiseFiltersR", "RtutoR", "aslib", "lilikoi", "smartdata")

CUDA <- # etc
c("RDieHarder", "ROI.plugin.cplex", "ROracle","ora", "Rcplex", "Rhpc", "cplexAPI",  "cudaBayesreg", "kmcudaR", "permGPU", "localsolver", "OpenCL", "CARrampsOcl", "littler", "ora", "gpuR", "bayesCL", "gpda", "rLindo")


WindowsOnly <- c("BiplotGUI", "MDSGUI", "R2MLwiN", "R2PPT", "R2wd", "RInno", "RPyGeo", "RWinEdt", "TinnR", "blatr", "excel.link", "installr", "spectrino", "taskscheduleR")

stoplist <- c(stoplist, Java, CUDA,  WindowsOnly)


fakes <- "ROracle"

ll <- c("## Fake installs",
        paste(fakes, "-OPTS = --install=fake", sep=""))
writeLines(ll, "Makefile.fakes")

recommended <-
    c("KernSmooth", "MASS", "Matrix", "boot", "class", "cluster",
      "codetools", "foreign", "lattice", "mgcv", "nlme", "nnet",
      "rpart", "spatial", "survival")

## gfortran
gcc <- c("glasso", "glmnet")

## C++ linkage
gcc <- c(gcc, "RProtoBuf", "V8", "magick", "rgdal", "sf")

gcc <- c(gcc, "Rcpp") # packages LinkingTo it automatically use gcc

## compile stan models
gcc <- c(gcc, "BANOVA", "prophet")

gcc <- c(gcc,
         "PhyloMeasures", # CC gives compilation error
         "RGtk2", # OpenCSW headers
         "Rrdrand", # segfaults
         "RcppParallel", # stated requirement
	 "bayesSurv", "smoothSurv", # Scythe issues
         "bigalgebra", # munmap in BH
         "deSolve", # installs with CC but changes results
         "freetypeharfbuzz", # Error: Narrowing conversion
         "jqr", # syntax error in libjq C header
         "rgeos", # compiles with CC but does not work
         "rzmq", # configure fails, no explanation
         "subprocess", # does not compile with CC
         "tuneR" # inline gcc-style asm in C
         )

Sys.setenv("OPENSSL_INCLUDES" = "/opt/csw/include", CURL_INCLUDES = "/opt/csw/include", "V8_INCLUDES" = "/opt/csw/include")

av <- function()
{
    ## setRepositories(ind = 1) # CRAN
    options(available_packages_filters =
            c("R_version", "OS_type", "CRAN", "duplicates"))
    av <- available.packages(contriburl = CRAN)[, c("Package", "Version", "Repository")]
    av <- as.data.frame(av, stringsAsFactors = FALSE)
    path <- with(av, paste0(Repository, "/", Package, "_", Version, ".tar.gz"))
    av$Repository <- NULL
    av$Path <- sub(".*contrib/", "../contrib/", path)
    av$mtime <- file.info(av$Path)$mtime
    names(av) <- c("name", "Version", "path", "mtime")
    av[order(av$name), ]
}
