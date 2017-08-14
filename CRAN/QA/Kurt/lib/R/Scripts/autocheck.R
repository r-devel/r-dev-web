wrk <- path.expand(file.path("~/tmp/CRAN"))
top <- path.expand(file.path("~/tmp/autocheck.d"))

## FIXME: keep outputs in sync with sources
## FIXME: need to clean up results.d and outputs.d after 10 days or so.
## FIXME: how can we be notified about problems?

run <- function() {
    if(dir.exists(wrk))
        return(0)
    if(!dir.exists(top))
        dir.create(top)
    ## Allow to disable from "outside":
    if(file.exists(file.path(top, "disable")))
        return(0)
    
    if(file.exists(lck <- file.path(top, ".lock")))
        return(0)
    file.create(lck)
    on.exit(file.remove(lck))
    ## From now on we have a lock in place.
    
    ## General idea is the following.
    ## Check results for package tarball
    ##   sources/PACKAGE_VERSION.tar.gz
    ## are put into directory
    ##   results/PACKAGE_VERSION_DATE_TIME
    ## Determine the oldest tarball without corresponding results dir,
    ## and run the check.
    sources.d <- file.path(top, "sources")
    results.d <- file.path(top, "results")
    outputs.d <- file.path(top, "outputs")

    if(!dir.exists(sources.d))
        dir.create(sources.d)
    if(!dir.exists(results.d))
        dir.create(results.d)
    if(!dir.exists(outputs.d))
        dir.create(outputs.d)

    ## Clean up results.
    results <- list.dirs(results.d,
                         full.names = TRUE, recursive = FALSE)
    age <- Sys.Date() - as.Date(file.info(results)$mtime)
    old <- results[as.numeric(age) > 14]
    if(length(old))
        unlink(old, recursive = TRUE)
    
    ## Populate sources: this could also be done by someone else.
    system2("rsync",
            c("-az --recursive --delete",
              "cran.wu.ac.at::CRAN-incoming/recheck/",
              sources.d))

    sources <- Sys.glob(file.path(sources.d, "*.tar.gz"))

    outputs <- list.dirs(outputs.d,
                         full.names = FALSE, recursive = FALSE)
    
    if(!length(sources)) {
        if(length(outputs))
            unlink(file.path(outputs.d, outputs), recursive = TRUE)
        return(0)
    }

    results <- list.dirs(results.d,
                         full.names = FALSE, recursive = FALSE)
    dts <- format(file.info(sources)$mtime, "%Y%m%d_%H%M%S")
    pos <- order(dts)
    ids <- sprintf("%s_%s",
                   sub("[.]tar[.]gz$", "", basename(sources)[pos]),
                   dts[pos])

    old <- outputs[is.na(match(outputs, ids))]
    if(length(old))
        unlink(file.path(outputs.d, old), recursive = TRUE)
    
    new <- ids[is.na(match(ids, results))]
    if(!length(new)) {
        return(0)
    }
    out <- new[1L]
    writeLines(out, lck)
    dir.create(wrk)
    file.copy(file.path(sources.d,
                        paste0(sub("^([^_]+_[^_]+)_.*", "\\1", out),
                               ".tar.gz")),
              wrk)

    ## Avoid 'WARNING: ignoring environment value of R_HOME' ...
    on.exit(Sys.setenv(R_HOME = Sys.getenv("R_HOME")), add = TRUE)
    Sys.unsetenv("R_HOME")
    
    cmd <- path.expand(file.path("~/bin", "check-CRAN-incoming"))
    val <- system2(cmd, "-c -n -r -s",
                   stdout = file.path(wrk, "outputs.txt"),
                   stderr = file.path(wrk, "outputs.txt"))
    ## Should we check the value returned?

    ## Create a summary of the changes.
    cmd <- path.expand(file.path("~/bin",
                                 "summarize-check-CRAN-incoming-changes"))
    system2(cmd, "-m -w", stdout = file.path(wrk, "changes.txt"))

    file.rename(wrk, file.path(results.d, out))

    ## Populate outputs for rsync from cran master.
    dir.create(file.path(outputs.d, out))
    file.copy(file.path(results.d, out, "outputs.txt"),
              file.path(outputs.d, out))
    file.copy(file.path(results.d, out, "changes.txt"),
              file.path(outputs.d, out))
    package <- sub("_.*", "", out)
    if(dir.exists(from <- file.path(results.d, out,
                                    paste0(package, ".Rcheck")))) {
        dir.create(to <- file.path(outputs.d, out, "package"))
        file.copy(file.path(from, "00check.log"), to)
        file.copy(file.path(from, "00install.out"), to)
    }

    return(0)
}

if(!interactive()) {
    val <- run()
}

if(FALSE) {
    while(TRUE) {
        run()
        Sys.sleep(1)
    }
}
    
