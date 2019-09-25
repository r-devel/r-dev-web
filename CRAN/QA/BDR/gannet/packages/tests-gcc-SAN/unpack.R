source('../common.R')
## forensim infinite-loops in tcltk
## BayesXsrc was killed using 31Gb for a compile, rmatio 12.5GB
stoplist <- c(stoplist, 'sanitizers',  'BayesXsrc', 'crs', 'forensim', "rmatio")
## blavaan uses 10GB, ctsem 19GB, rstanarm 8GB
stan <- tools::dependsOnPkgs('StanHeaders',,FALSE)
stoplist <- c(stoplist, stan)
do_it(stoplist, TRUE)
