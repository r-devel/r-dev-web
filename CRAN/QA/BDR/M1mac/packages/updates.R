source("common.R")
stoplist <- c(stoplist, noinstall)

source("common2.R")

setRepositories(ind = c(1:4))
repos <- c("file:///Users/ripley/R/fixed",
           getOption('repos'))
options(repos = repos)
old <- old.packages()
if(!is.null(old)) {
    old <- setdiff(rownames(old), noupdate)
    install.packages(old, type = "source", INSTALL_opts = opts)
}

setRepositories(ind=1)
new <- new.packages()
new <- setdiff(new, stoplist)
if(length(new)) {
    setRepositories(ind = c(1:4))
    install.packages(new, type = "source", INSTALL_opts = opts)
}
