args <- commandArgs(TRUE)
if(!length(args)) args <- "tests-devel"

#chooseBioCmirror(ind=1)
setRepositories(ind=c(1:4))
av <- row.names(available.packages())
av <- c(av, 'INLA')
av <- c(av, tools:::.get_standard_package_names()$base, 'HPO.db','MPO.db')
inst <- row.names(installed.packages(.libPaths()[1]))
## installation might have failed
inst2 <- sub("[.]in$", "", dir(args, patt = "[.]in$"))
ex <- setdiff(c(inst,inst2), av)
ex <- setdiff(ex, readLines("~/R/packages/BioC_installed"))
if(length(ex) > 50) {
    message("too many packages are missing to remove")
    q("no")
}
if(length(ex)) {
    message ("removing ", paste(sQuote(ex), collapse =" "))
    remove.packages(ex, .libPaths()[1]) # duplicated below.
    paths <- c(file.path("~/R/packages/*", ex),
	       file.path("~/R/test-*", ex),
               file.path("~/R/packages/*", paste0(ex, ".in")),
               file.path("~/R/packages/*", paste0(ex, ".out")),
	       file.path("~/R/packages/*", paste0(ex, ".log")),
               file.path("~/R/packages/*", paste0(ex, ".Rcheck")))
    unlink(Sys.glob(paths), recursive = TRUE)
}
