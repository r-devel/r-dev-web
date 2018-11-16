source('../common.R')
## BayesXsrc was killed using 31Gb for a compile, ctsem 19GB
stoplist <- c(stoplist, CUDA, 'sanitizers', 'Smisc', 'rstanarm', 'survHE', 'trialr', 'forensim', 'BayesXsrc', 'ctsem', 'DeLorean')
do_it(stoplist, TRUE)
