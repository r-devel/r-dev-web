stoplist <- c("maxent", "RTextTools",
              "rpvm" ,"GDD", "aroma.apd",
              "aroma.cn", "aroma.core", "aroma.affymetrix", "calmate",
              "ACNE", "MAMA", "NSA",
              "PKgraph", "WMTregions", "beadarrayMSV", "clusterfly",
              "magnets", "StochaTR", "topologyGSA", "ppiPre", "SNPMaP")
stoplist <- c(stoplist, "Rcpp") # 0.9-8 segfaults

fakes <-
    c("CARramps", "GridR", "OpenCL", "RBerkeley", "RDF",
      "R2OpenBUGS",
      "RDieHarder", "RMark", "RMongo", "RMySQL", "ROAuth", "ROracle",
      "RProtoBuf", "RQuantLib", "RScaLAPACK", "Rcplex", "RiDMC",
      "Rmosek", "SV", "TSMySQL", "VBmix", "clpAPI", "cmprskContin",
      "cplexAPI", "cudaBayesreg", "glpkAPI", "gputools", "magma", "mpc",
      "psgp", "rJavax", "rpud", "rpvm", "rscproxy", "rzmq")

ll <- c("## Fake installs",
        paste(fakes, "-OPTS = --install=fake", sep=""))
writeLines(ll, "Makefile.fakes")

recommended <-
    c("KernSmooth", "MASS", "Matrix", "boot", "class", "cluster",
      "codetools", "foreign", "lattice", "mgcv", "nlme", "nnet",
      "rpart", "spatial", "survival")

gcc <- c("MCMCpack", "RGtk2", "glmnet", "revoIPC", "tgp")

