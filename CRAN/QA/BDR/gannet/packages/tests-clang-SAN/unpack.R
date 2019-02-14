source('../common.R')
stoplist <- c(stoplist, noclang, "sanitizers", "gmwm", "pdc", "rem", 'Smisc', "forensim", 'BRugs')
stoplist <- c(stoplist, "HTSSIP") # RAM usage
stoplist <- c(stoplist, "BMTME") # hangs on snow usage
do_it(stoplist, TRUE)
