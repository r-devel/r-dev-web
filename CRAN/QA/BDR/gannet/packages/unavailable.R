setRepositories(ind=1:7)
av <- row.names(available.packages())
av <- c(av, "Rstem")
inst <- row.names(installed.packages(.libPaths()[1]))
#inst <- dir(.libPaths()[1])
ex <- setdiff(inst, av)
if(length(ex) > 30) q()
if(length(ex)) {
    message ("removing ", paste(sQuote(ex), collapse =" "))
    remove.packages(ex, .libPaths()[1])
    paths <- c(file.path("~/R/packages/*", ex),
	       file.path("~/R/test-clang", ex),
               file.path("~/R/packages/*", paste0(ex, ".in")),
               file.path("~/R/packages/*", paste0(ex, ".out")),
               file.path("~/R/packages/*", paste0(ex, ".Rcheck")))
    unlink(Sys.glob(paths), recursive = TRUE)
}
