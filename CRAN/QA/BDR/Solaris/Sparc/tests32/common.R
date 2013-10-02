stoplist <- c("BRugs", "ExomeDepth",
              "aroma.apd", "aroma.cn", "aroma.core", "aroma.affymetrix", "calmate",
              "ACNE", "MAMA", "NSA",
              "rggobi", "PKgraph", "beadarrayMSV",
              "StochaTR", "SNPMaP", "SRMA","RMySQL", "TSMySQL", "dbConnect", "Causata")

fakes <-
    c("BTSPAS", "CARramps", "CARrampsOcl", "GridR", "OpenCL",
      "RBerkeley", "RDF", "R2OpenBUGS",
      "RDieHarder", "RMark", "RMongo", "ROAuth", "ROracle",
      "RQuantLib", "RScaLAPACK", "Rcplex", "RiDMC",
      "Rmosek", "SV", "VBmix", "WideLM", "cmprskContin",
      "cplexAPI", "cudaBayesreg", "gputools", "magma", "mpc", "permGPU",
      "qtbase", "qtpaint", "rJavax", "rpud", "rpvm", "rscproxy", "rzmq",
      "RcppOctave", "HiPLARM", "RAppArmor", "RSAP", "REBayes", "ora", "rLindo")


ll <- c("## Fake installs",
        paste(fakes, "-OPTS = --install=fake", sep=""))
writeLines(ll, "Makefile.fakes")

recommended <-
    c("KernSmooth", "MASS", "Matrix", "boot", "class", "cluster",
      "codetools", "foreign", "lattice", "mgcv", "nlme", "nnet",
      "rpart", "spatial", "survival")

gcc <- c("BayesXsrc", "ElectroGraph", "MCMCpack", "MasterBayes",
          "RGtk2", "RMessenger", "Ratings", "gearman", "glmnet", "gof", "intervals", "mRm", "phcfM", "rbamtools",
          "smoothSurv", "sparsenet", "tgp", "RJSONIO", "mixcat", "PKI", "RSclient", "cldr",
	"assist")

Sys.setenv("OPENSSL_INCLUDES" = "/opt/csw/include")

