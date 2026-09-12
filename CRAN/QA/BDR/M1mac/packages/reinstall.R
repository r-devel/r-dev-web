source("common2.R")

args <- commandArgs()[-(1:3)]
foo <- if(la <- length(args)) {
    if(la == 1L) {
        if(file.exists(args)) readLines(args) else args
    } else args
} else row.names(installed.packages(.libPaths()[1L]))


foo <- setdiff(foo, noupdate)

options(BioC_mirror = "https://bioconductor.statistik.tu-dortmund.de")
setRepositories(ind = 1:4)
#repos <- c("file:///Users/ripley/R/fixed", getOption('repos'))
#options(repos = repos)

install.packages(foo, Ncpus = 8, type="source", INSTALL_opts = opts)
