snapshot <- function(pkg)
{
    h <- "~/R/packages"
    setwd(h)
    d <- file.path(h, "snapshots", paste(pkg, Sys.Date(), sep = "_"))
    dir.create(d, showWarnings = FALSE)
    dd <- dir(".", patt="^tests")
    dd <- grep("-keep", dd, value = TRUE, invert = TRUE)
    f <- character()
    for(x in dd) {
        f <- c(f, dir(x, full.names = TRUE, patt = paste0("^", pkg, "[.]log$")))
        f <- c(f, dir(x, full.names = TRUE, patt = paste0("^", pkg, "[.]out$")))
    }
    for (g in f)
        dir.create(file.path(d, dirname(g)), showWarnings = FALSE)
    file.copy(f, file.path(d, f), copy.date = TRUE)

    setwd("/vols/ftp/pub/bdr")
    dd <- c("M1mac")
    f <- character()
    for(x in dd) {
        f <- c(f, dir(x, full.names = TRUE, patt = paste0("^", pkg, "[.]log$")))
        f <- c(f, dir(x, full.names = TRUE, patt = paste0("^", pkg, "[.]out$")))
    }
    for (g in f)
        dir.create(file.path(d, dirname(g)), showWarnings = FALSE)
    file.copy(f, file.path(d, f), copy.date = TRUE)
}
