stoplist <- c("BRugs", "ExomeDepth",
              "GDD", "aroma.apd",
              "aroma.cn", "aroma.core", "aroma.affymetrix", "calmate",
              "ACNE", "MAMA", "NSA",
              "PKgraph", "beadarrayMSV",
              "StochaTR", "topologyGSA", "ppiPre", "SNPMaP", "SRMA",
		"longitudinalData", "kml", "kml3d")

stoplist <- c(stoplist, "Rcpp") # 0.9-8 crashes all too often

fakes <-
    c("BTSPAS", "CARramps", "GridR", "OpenCL", "RBerkeley", "RDF",
      "R2OpenBUGS",
      "RDieHarder", "RMark", "RMongo", "RMySQL", "ROAuth", "ROracle",
      "RProtoBuf", "RQuantLib", "RScaLAPACK", "Rcplex", "RiDMC",
      "Rmosek", "SV", "TSMySQL", "VBmix", "WideLM", "clpAPI", "cmprskContin",
      "cplexAPI", "cudaBayesreg", "gputools", "magma", "mpc",
      "qtbase", "qtpaint", "rJavax", "rpud", "rpvm", "rscproxy", "rzmq",
      "RcppOctave")

ll <- c("## Fake installs",
        paste(fakes, "-OPTS = --install=fake", sep=""))
writeLines(ll, "Makefile.fakes")

recommended <-
    c("KernSmooth", "MASS", "Matrix", "boot", "class", "cluster",
      "codetools", "foreign", "lattice", "mgcv", "nlme", "nnet",
      "rpart", "spatial", "survival")

gcc <- c("BayesXsrc", "ElectroGraph", "MCMCpack", "MasterBayes",
          "RGtk2", "Ratings", "glmnet", "gof", "mRm", "phcfM", "rbamtools",
          "smoothSurv", "sparsenet", "tgp")
