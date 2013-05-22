stoplist <- c("ExomeDepth", "GDD", "aroma.apd",
              "aroma.cn", "aroma.core", "aroma.affymetrix", "calmate",
              "ACNE", "NSA",
              "rggobi", "PKgraph", "beadarrayMSV",
              "StochaTR", "topologyGSA", "ppiPre", "SNPMaP", "SRMA")
#stoplist <- c(stoplist, "Rcpp")


fakes <-
    c("BRugs","BTSPAS", "CARramps", "GridR", "OpenCL", "RBerkeley", "RDF", "R2OpenBUGS",
      "RDieHarder", "RMark", "RMongo", "RMySQL", "ROAuth", "ROracle",
      "RProtoBuf", "RQuantLib", "RScaLAPACK", "Rcplex", "RiDMC",
      "Rmosek", "SV", "TSMySQL", "VBmix", "WideLM", "cmprskContin",
      "cplexAPI", "cudaBayesreg", "gputools", "magma", "mpc", "permGPU",
      "qtbase", "qtpaint", "rJavax", "rpud", "rpvm", "rscproxy", "rzmq",
      "RcppOctave", "HiPLARM", "RAppArmor", "RSAP", "REBayes")

ll <- c("## Fake installs",
        paste(fakes, "-OPTS = --install=fake", sep=""))
writeLines(ll, "Makefile.fakes")

recommended <-
    c("KernSmooth", "MASS", "Matrix", "boot", "class", "cluster",
      "codetools", "foreign", "lattice", "mgcv", "nlme", "nnet",
      "rpart", "spatial", "survival")

gcc <- c("BayesXsrc", "ElectroGraph", "MCMCpack", "MasterBayes",
          "RGtk2", "RMessenger", "Ratings", "gearman", "glasso", "glmnet", "gof", "intervals", "mRm", "phcfM", "rbamtools",
          "smoothSurv", "sparsenet", "tgp", "RJSONIO", "mixcat", "PKI", "RSclient", "cldr")

