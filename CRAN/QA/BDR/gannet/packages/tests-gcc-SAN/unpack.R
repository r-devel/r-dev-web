source('../common.R')
stoplist <- c(stoplist, CUDA, 'sanitizers', 'Smisc', 'rstanarm', 'survHE', 'trialr')
do_it(stoplist, TRUE)
