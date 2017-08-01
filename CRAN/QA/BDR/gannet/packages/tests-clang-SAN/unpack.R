source('../common.R')
stoplist <- c(stoplist, noclang, "sanitizers", "gmwm", "pdc", "rem", 'Smisc')
stoplist <- c(stoplist, "HTSSIP") # RAM usage
do_it(stoplist)
