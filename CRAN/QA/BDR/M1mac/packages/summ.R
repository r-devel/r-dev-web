#! /opt/R/arm64/bin/Rscript
files <- dir("~/R/packages/tests-devel", patt = "[.]out$", full.names = TRUE)
known <- readLines("~/R/packages/M1known", warn = FALSE)
known <- c(known, scan("~/R/packages/known", '', quiet = TRUE))
known <- paste0("/Users/ripley/R/packages/tests-devel/", known, ".out")
files <- setdiff(files, known)
for (f in known) {
    if(!file.exists(f)) {
        ff <- sub("[.]out", "", basename(f))
        message(sprintf("package %s has been removed",  sQuote(ff)))
        next
    }
    lines <- readLines(f, warn = FALSE)
    st <- grepl("^Status.*ERROR", lines)
    if (!any(st)) {
        ff <- sub("[.]out", "", basename(f))
        message(sprintf("package %s is no longer failing", sQuote(ff)))
    }
}
res <- character()
for (f in files) {
    lines <- readLines(f, warn = FALSE)
    st <- grepl("^Status.*ERROR", lines)
    if (any(st)) {
        res <- c(res, paste0(basename(f), ":", lines[st]))
    }
}
writeLines(res, stdout())
