source('../common.R')
## BayesXsrc was killed using 31Gb for a compile, ctsem 19GB
stoplist <- c(stoplist, 'sanitizers', 'Smisc', 'rstanarm', 'survHE', 'trialr', 'forensim', 'BayesXsrc', 'ctsem', 'DeLorean', 'crs')
do_it(stoplist, TRUE)
