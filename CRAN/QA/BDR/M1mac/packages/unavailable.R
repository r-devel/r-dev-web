args <- commandArgs(TRUE)
if(!length(args)) args <- "tests-devel"
chooseBioCmirror(ind=1)
setRepositories(ind=1:4)
av <- row.names(available.packages(type = "source"))
if(length(av) < 50) q()
av <- c(av, 'INLA')
inst <- row.names(installed.packages(.libPaths()[1]))
inst2 <- sub("[.]in$", "", dir(args, patt = "[.]in$"))
ex <- setdiff(c(inst,inst2), av)
ex <- setdiff(ex, readLines("~/R/packages/BioC_installed"))
if(length(ex) > 100) q()
if(length(ex)) {
    message ("removing ", paste(sQuote(ex), collapse =" "))
##    suppressWarnings(remove.packages(ex, .libPaths()[1]))
    paths <- c(file.path("~/R/Library", ex),
               file.path("~/R/packages/*", ex),
               file.path("~/R/packages/*", paste0(ex, ".in")),
               file.path("~/R/packages/*", paste0(ex, ".out")),
               file.path("~/R/packages/*", paste0(ex, ".log")),
               file.path("~/R/packages/*", paste0(ex, ".Rcheck")))
    unlink(Sys.glob(paths), recursive = TRUE)
}
