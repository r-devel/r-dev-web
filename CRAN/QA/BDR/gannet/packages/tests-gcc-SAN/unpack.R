source('../common.R')
## BayesXsrc was killed using 31Gb for a compile
stoplist <- c(stoplist, CUDA, 'sanitizers', 'Smisc', 'rstanarm', 'survHE', 'trialr', 'forensim', 'BayesXsrc')
do_it(stoplist, TRUE)
