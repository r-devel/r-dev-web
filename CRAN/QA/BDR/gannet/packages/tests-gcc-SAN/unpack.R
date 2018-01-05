source('../common.R')
stoplist <- c(stoplist, no_mosek, 'sanitizers', 'Smisc', 'rstanarm', 'survHE', 'trialr')
do_it(stoplist, TRUE)
