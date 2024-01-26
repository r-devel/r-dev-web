#! /opt/R/arm64/bin/Rscript
files <- dir("~/R/packages/tests-devel", patt = "[.]out$", full.names = TRUE)
known <- readLines("~/R/packages/M1known", warn = FALSE)
known <- c(known, readLines("~/R/packages/known", warn = FALSE))
known <- known[nzchar(known)]
known <- grep("^#", known, invert = TRUE, value = TRUE)
known <- paste0("/Users/ripley/R/packages/tests-devel/", known, ".out")
files <- setdiff(files, known)
for (f in known) {
    if(!file.exists(f)) {
        ff <- sub("[.]out", "", basename(f))
        message(sprintf("package %s has been removed",  sQuote(ff)))
        next
    }
    lines <- readLines(f, warn = FALSE)
    st <- grepl("^Status.*ERROR", lines, useBytes = TRUE)
    if (!any(st)) {
        ff <- sub("[.]out", "", basename(f))
        message(sprintf("package %s is no longer failing", sQuote(ff)))
    }
}
res <- character()
for (f in files) {
    lines <- readLines(f, warn = FALSE)
    st <- grepl("^Status.*ERROR", lines, useBytes = TRUE)
    if (any(st)) {
        res <- c(res, paste0(basename(f), ":", lines[st]))
    }
}
writeLines(res, stdout())

warns <- readLines("~/R/packages/warn_known", warn = FALSE)
warns <- warns[nzchar(warns)]
warns <- grep("^#", warns, invert = TRUE, value = TRUE)
warns <- paste0("/Users/ripley/R/packages/tests-devel/", warns, ".out")
for (f in warns) {
    if(!file.exists(f)) {
        ff <- sub("[.]out", "", basename(f))
        message(sprintf("package %s has been removed",  sQuote(ff)))
        next
    }
    lines <- readLines(f, warn = FALSE)
    st <- grepl("installed.*WARNING", lines, useBytes = TRUE)
    if (!any(st)) {
        ff <- sub("[.]out", "", basename(f))
        message(sprintf("package %s is no longer warning", sQuote(ff)))
    }
}
res <- character()
for (f in files) {
    if (f %in% warns) next
    lines <- readLines(f, warn = FALSE)
    st <- grepl("installed.*WARNING", lines, useBytes = TRUE)
    if (any(st)) {
        res <- c(res, f)
    }
}
if(length(res)) {
    message("New installation warnings for:")
    res <- sub("[.]out", "", basename(res))
    writeLines(strwrap(paste(res, collapse = " "), indent = 4, exdent = 4),
               stdout())
}
