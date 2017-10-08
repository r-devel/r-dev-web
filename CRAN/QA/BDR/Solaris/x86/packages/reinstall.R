## parallel will not work as make is involved
foo <- row.names(installed.packages(.libPaths()[1]))

chooseBioCmirror(ind = 1)
setRepositories(ind = c(2:4, 7))
foo2 <- row.names(available.packages())
foo <- intersect(foo, foo2)

source('BioCgcc.R')
foo <- setdiff(foo, gcc)

Sys.setenv(DISPLAY = ':5', MAKE = 'gmake')
install.packages(foo, Ncpus = 1)
