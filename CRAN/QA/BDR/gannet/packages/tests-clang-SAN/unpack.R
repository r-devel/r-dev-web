source('../common.R')
stoplist <- c(stoplist, CUDA, noclang, "sanitizers", "gmwm", "pdc", "rem", 'Smisc', "forensim")
stoplist <- c(stoplist, "HTSSIP") # RAM usage
do_it(stoplist, TRUE)
