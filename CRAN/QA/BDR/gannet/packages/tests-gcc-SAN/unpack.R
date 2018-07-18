source('../common.R')
stoplist <- c(stoplist, CUDA, 'sanitizers', 'Smisc', 'rstanarm', 'survHE', 'trialr', 'forensim')
do_it(stoplist, TRUE)
