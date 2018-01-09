source('../common.R')
stoplist <- c(stoplist, CUDA, no_mosek)

do_it(stoplist)
