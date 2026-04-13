top <- file.path(normalizePath("~"), "tmp", "vnu.d")

is_symlink <- function(paths) {
    links <- Sys.readlink(paths)
    !is.na(links) & nzchar(links)
}

run <- function() {

    if(!dir.exists(top))
        dir.create(top, recursive = TRUE)

    results.d <- file.path(top, "results")
    trouble.d <- file.path(top, "trouble")

    if(!dir.exists(results.d))
        dir.create(results.d)
    if(!dir.exists(trouble.d))
        dir.create(trouble.d)

    sources <- Sys.glob(file.path("/data/Repositories/CRAN/src/contrib/",
                                  "*.tar.gz"))
    sources <- sources[!is_symlink(sources)]
    results <- file.path(results.d,
                         sub("tar.gz$", "out", basename(sources)))
    sources <- sources[!file.exists(results) |
                       (file.mtime(sources) > file.mtime(results))]
    ## Apparently this can give NAs ... not sure how?
    sources <- sources[!is.na(sources)]

    jar <- system.file("java", "vnu.jar", package = "vnu.jar")

    one <- function(src) {
        pkg <- basename(src)
        file.remove(Sys.glob(file.path(results.d,
                                       paste(sub("_.*", "_*", pkg)))))
        if(interactive())
            message(sprintf("processing %s ...", pkg))
        tmp <- tempfile(fileext = ".html")
        suppressMessages(suppressWarnings({
            tools::pkg2HTML(src, out = tmp, concordance = TRUE)
        }))
        bad <- W3CMarkupValidator::w3c_markup_validate(file = tmp,
                                                       jar = jar,
                                                       concordance = TRUE)
        if(NROW(bad)) {
            rds <- file.path(results.d, sub("tar.gz$", "rds", pkg))
            saveRDS(bad, rds)
        }
        out <- file.path(results.d, sub("tar.gz$", "out", pkg))
        write.dcf(bad, out)
    }

    wrk <- function(src) {
        val <- tryCatch(one(src), error = identity)
        if(inherits(val, "error"))
            message(paste(c(sprintf("processing %s failed with message:",
                                    basename(src)),
                            conditionMessage(val)),
                          collapse = "\n"))
    }

    if(length(sources))
        parallel::mclapply(sources, wrk, mc.cores = 12L)

    trouble <- c(Sys.glob(file.path(trouble.d, "*.out")),
                 Sys.glob(file.path(trouble.d, "*.rds")))
    file.remove(trouble)
    results <- Sys.glob(file.path(results.d, "*.rds"))
    if(length(results)) {
        ## <FIXME>
        ## For now, filter out the type=info diagnostics which do not
        ## have subtype=warning, currently only
        ##   Trailing slash on void elements has no effect and interacts
        ##   badly with unquoted attribute values.
        ## so look for this directly.
        ## Also filter out the type=info subtype=warning 
        ##   This document appears to be written in
        ## diagnostics.
        ## When no longer doing this, change to
        ##   file.copy(results, trouble.d)
        two <- function(res) {
            bad <- readRDS(res)
            msg <- bad[, "message"]
            ind <- (startsWith(msg, "This document appears to be written in") |
                    startsWith(msg, "Trailing slash on void elements has no effect"))
            bad <- bad[!ind, , drop = FALSE]
            if(NROW(bad)) {
                out <- file.path(trouble.d,
                                 sub("rds$", "out", basename(res)))
                write.dcf(bad, out)
            }
            file.copy(res, trouble.d)
        }
        parallel::mclapply(results, two, mc.cores = 12L)
        ## <FIXME>
    }
    trouble <- Sys.glob(file.path(trouble.d, "*.out"))
    trouble <- sub("[.]out$", "", basename(trouble))
    tab <- data.frame(Package = sub("_.*", "", trouble),
                      Version = sub(".*_", "", trouble),
                      kind = rep.int("vnu", length(trouble)),
                      href =
                          sprintf("https://www.R-project.org/nosvn/vnu/%s.out",
                                  trouble))
    write.csv(tab, file.path(trouble.d, "vnu.csv"),
              row.names = FALSE, quote = FALSE)
        
}

if(!interactive()) {
    run()
}
