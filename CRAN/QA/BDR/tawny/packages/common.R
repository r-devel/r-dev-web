stoplist <-
    c("BRugs",
      "ROracle", "RQuantLib",
      "Rcplex", "Rpoppler", "ora", "rLindo", "ROI.plugin.cplex", "cplexAPI",
      "localsolver", "permGPU", 'kmcudaR', "gpuR",
      "qtbase", "qtpaint", ## qt users
      "rcrypt", # needs gpg
      ## ggobi no longer builds, binary is linked to old GTK+
      "rggobi", "PKgraph", "SeqGrapheR", "beadarrayMSV", "clusterfly",
      "gpg", "IRATER", "tesseract",
#      'argparse', 'optparse', # missing SystemRequirements
      'mssqlR',
      'opencv', # needs opencv4
      #'ecmwfr', ## never returns
      #'arrow',
      ## memory issues
      'cbq', 'ctsem', 'pcFactorStan',
      ## external tools
      #"PythonInR", "IGP", "WebGestaltR", "rlo",
      "RAppArmor", "RcppAPT", "RcppMeCab", "RmecabKo",
      "RMark", "R2ucare", "multimark",
      #'Rsagacmd',
      'RPostgres', 'RGreenplum', "rpg",
      "caRpools", # MAGeCK
      "nFCA", # ruby
      "rsvg", "RIdeogram", "colorfindr", "netSEM", "uCAREChemSuiteCLI", "vtree", "integr", "cohorttools", "BioMedR",
      "sybilSBML", "rGEDI",
      'OpenCL',
      'rrd') # need rrdtool libraries

## nothing depends on mzR any more
#C8 <- readLines('~/R/packages/mzR_fail')

noinstall <- c('rMouse', # AWT headless
               "ggtern", "cocktailApp", "plot3logit", "tricolore",
	       'cyanoFilter','flowDiv') # cytolib
