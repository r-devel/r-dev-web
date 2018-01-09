source('../common.R')
stoplist <- c(stoplist, CUDA, no_mosek, 'sanitizers', 'Smisc', 'rstanarm', 'survHE', 'trialr')
do_it(stoplist, TRUE)
