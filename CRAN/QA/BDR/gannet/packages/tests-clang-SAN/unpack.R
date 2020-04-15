source('../common.R')
## forensim infinite-loops in tcltk
## pdc takes forever to compile
stoplist <- c(stoplist, noclang, "sanitizers", "pdc", "forensim", "rcss")
do_it(stoplist, TRUE)
