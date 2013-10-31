stoplist <- c("ExomeDepth", "aroma.apd",
              "aroma.cn", "aroma.core", "aroma.affymetrix", "calmate",
              "ACNE", "NSA",
              "rggobi", "PKgraph", "beadarrayMSV",
              "StochaTR", "SNPMaP", "SRMA", "RMySQL", "TSMySQL", "dbConnect", "Causata", 
      "BRugs","CARramps", "CARrampsOcl", "GridR", "OpenCL",
      "RBerkeley", "RDieHarder", "RMark", "RMongo",  "ROAuth", "ROracle",
      "RQuantLib", "RScaLAPACK", "Rcplex", "RiDMC",
      "Rmosek", "VBmix", "WideLM", "cmprskContin",
      "cplexAPI", "cudaBayesreg", "gputools", "gmatrix", "magma", "permGPU",
      "qtbase", "qtpaint", "qtutils", "rJavax", "rpud", "rpvm", "rscproxy", "rzmq", "twitteR",
      "RcppOctave", "HiPLARM", "RAppArmor", "RSAP", "REBayes", "ora", "rLindo")


fakes <- "ROracle"

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

Sys.setenv("OPENSSL_INCLUDES" = "/opt/csw/include")

