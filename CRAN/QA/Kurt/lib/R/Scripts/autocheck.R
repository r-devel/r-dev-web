top <- file.path(normalizePath("~"), "tmp", "autocheck.d")

## FIXME: how can we be notified about problems?

file_age <- function(paths) {
    as.numeric(Sys.Date() - as.Date(file.mtime(paths)))
}

file_age_in_hours <- function(paths) {
    as.numeric(difftime(Sys.time(), file.mtime(paths),
                        units = "hours"))
}

summarize <- function(dir, reverse = FALSE, process = FALSE) {
    log <- file.path(dir, "package", "00check.log")
    results <- tools:::check_packages_in_dir_results(logs = log)
    status <- results$package$status
    out <- sprintf("Package check result: %s\n", status)
    if(status != "OK") {
        details <- tools:::check_packages_in_dir_details(logs = log)
        out <- c(out,
                 sprintf("Check: %s, Result: %s\n  %s\n",
                         details$Check,
                         details$Status,
                         gsub("\n", "\n  ", details$Output, perl = TRUE)))
    }
    if(reverse) {
        changes <- readLines(file.path(dir, "changes.txt"))
        out <- c(out,
                 if(length(changes))
                     c("Changes to worse in reverse depends:\n",
                       changes)
                 else
                     "No changes to worse in reverse depends.")
    }
    if(process) {
        process <- readLines(file.path(dir, "process.txt"))
        if(length(process))
            out <- c(out,
                     "Post-processing issues found:\n",
                     process)
    }
    out
}

format_process_outputs <- function(x) {
    if(!length(x)) return(character())
    fun <- function(u, v) {
        paste(c(sprintf("File: %s", u), v), collapse = "\n")
    }
    paste(unlist(Map(fun, names(x), x), use.names = FALSE),
          collapse = "\n\n")
}

## A very simple post-processor for valgrind checks:
process_valg <- function(dir) {
    files <-
        Sys.glob(file.path(dir,
                           c("*.Rout",
                             "tests/*.Rout",
                             "tests/*.Rout.fail",
                             "*.[RSrs]nw.log",
                             "*.[RSrs]tex.log",
                             "*.Rmd.log")))
    lines <- lapply(files,
                    function(f) {
                        s <- readLines(f, warn = FALSE, encoding = "bytes")
                        h <- gsub("(==[0-9]+==) .*", "\\1", s[1L])
                        s <- s[startsWith(s, h)]
                        if(any(grepl(dir, s)))
                            s
                        else
                            NULL
                    })
    ## Cf. tools:::file_path_relative_to().
    names(lines) <- substring(files, nchar(dir) + 2L)
    Filter(length, lines)
}

## A very simple post-processor for sanitizer checks:
process_xtra <- function(dir) {
    files <-
        Sys.glob(file.path(dir,
                           c("*.Rout",
                             "tests/*.Rout",
                             "tests/*.Rout.fail",
                             "*.[RSrs]nw.log",
                             "*.[RSrs]tex.log",
                             "build_vignettes.log",
                             "00check.log",
                             "00install.out")))
    lines <- lapply(files,
                    function(f) {
                        s <- readLines(f, warn = FALSE, encoding = "bytes")
                        grepv("ASan|AddressSanitizer|runtime error:", s)
                    })
    ## Cf. tools:::file_path_relative_to().
    names(lines) <- substring(files, nchar(dir) + 2L)
    Filter(length, lines)
}

run <- function(service = "pretest") {

    reverse <- (service == "recheck")
    process <- (service %in% c("special/clang-san",
                               "special/gcc-san",
                               "special/valgrind"))

    wrk <- file.path(normalizePath("~"), "tmp",
                     paste0("CRAN_", sub("/", "_", service)))
    if(dir.exists(wrk)) {
        if(file_age_in_hours(wrk) < 6)
            return(0)
        else
            unlink(wrk, recursive = TRUE)
    }

    if(!dir.exists(top))
        dir.create(top, recursive = TRUE)
    ## Allow to disable from "outside":
    if(file.exists(file.path(top, "disable")))
        return(0)

    top <- file.path(top, service)
    if(!dir.exists(top))
        dir.create(top, recursive = TRUE)
    if(file.exists(lck <- file.path(top, ".lock"))) {
        if(file_age_in_hours(lck) < 6)
            return(0)
        else
            file.remove(lck)
    }
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
    old <- results[file_age(results) > 14]
    if(length(old))
        unlink(old, recursive = TRUE)
    
    ## Populate sources: this could also be done by someone else.
    system2("rsync",
            c("-aqzv --recursive --delete",
              sprintf("cran.wu.ac.at::CRAN-incoming/%s/",
                      service),
              sources.d),
            stdout = FALSE, stderr = FALSE)

    sources <- Sys.glob(file.path(sources.d, "*.tar.gz"))

    ## <FIXME>
    ## There currently is no mechanism for *stoplisting* packages (or
    ## maintainers).  For the former, we could use something like
    ##   sources <-
    ##     sources[!startsWith("MiscMetabar_", basename(sources))]
    ## </FIXME>

    outputs <- list.dirs(outputs.d,
                         full.names = FALSE, recursive = FALSE)
    
    if(!length(sources)) {
        if(length(outputs)) {
            old <- file.path(outputs.d, outputs)
            if(!reverse)
                old <- old[file_age(old) > 7]
            if(length(old))
                unlink(old, recursive = TRUE)
        }
        return(0)
    }

    results <- list.dirs(results.d,
                         full.names = FALSE, recursive = FALSE)
    dts <- format(file.mtime(sources), "%Y%m%d_%H%M%S")
    pos <- order(dts)
    ids <- sprintf("%s_%s",
                   sub("[.]tar[.]gz$", "", basename(sources)[pos]),
                   dts[pos])

    old <- file.path(outputs.d, outputs[is.na(match(outputs, ids))])
    if(!reverse)
        old <- old[file_age(old) > 7]
    if(length(old))
        unlink(old, recursive = TRUE)
    
    new <- ids[is.na(match(ids, results))]
    if(!length(new)) {
        return(0)
    }
    new <- new[1L]
    writeLines(new, lck)
    dir.create(wrk, recursive = TRUE)
    file.copy(file.path(sources.d,
                        paste0(sub("^([^_]+_[^_]+)_.*", "\\1", new),
                               ".tar.gz")),
              wrk)

    ## Avoid 'WARNING: ignoring environment value of R_HOME' ...
    on.exit(Sys.setenv(R_HOME = Sys.getenv("R_HOME")), add = TRUE)
    Sys.unsetenv("R_HOME")

    exe <- list()
    ## <NOTE>
    ## We currently hard-wire pretest to use LLVM: could make this
    ## settable via an additional command line option ...
    ## </NOTE>
    arg <- list("pretest" =
                    "-c -fc",
                "recheck" =
                    "-r=most",
                "special/LTO" =
                    "-fg/LTO",
                "special/clang19" =
                    "-fc/lcxx",
                "special/clang-san" =
                    "-fc/xtra",
                "special/donttest" =
                    "-a=\"--run-donttest\"",
                "special/gcc" =
                    "-fg",
                "special/gcc-san" =
                    "-fg/xtra",
                "special/noLD" =
                    "-fg/noLD",
                "special/valgrind" =
                    "-fg/valg -a=\"--use-valgrind\""
                )
    env <- list("special/clang-san" =
                    c("R_LIBS_USER=NULL",
                      "_R_CHECK_CRAN_INCOMING_=false",
                      "_R_CHECK_RD_MATH_RENDERING_=false",
                      sprintf("ASAN_OPTIONS=detect_leaks=0:detect_odr_violation=0:suppressions=%s",
                              file.path(normalizePath("~"),
                                        ".R", "asan.supp")),
                      "UBSAN_OPTIONS=print_stacktrace=1",
                      ## <FIXME>
                      ## remove eventually ...                      
                      "_R_CXX_USE_NO_REMAP_=false",
                      "_R_USE_STRICT_R_HEADERS_=false"
                      ## </FIXME>
                      ),
                "special/donttest" =
                    "_R_CHECK_EXAMPLE_TIMING_THRESHOLD_=600",
                "special/gcc-san" =
                    c("R_LIBS_USER=NULL",
                      "_R_CHECK_CRAN_INCOMING_=false",
                      "_R_CHECK_RD_MATH_RENDERING_=false",
                      sprintf("ASAN_OPTIONS=detect_leaks=0:detect_odr_violation=0:suppressions=%s",
                              file.path(normalizePath("~"),
                                        ".R", "asan.supp")),
                      "UBSAN_OPTIONS=print_stacktrace=1",
                      ## <FIXME>
                      ## remove eventually ...                      
                      "_R_CXX_USE_NO_REMAP_=false",
                      "_R_USE_STRICT_R_HEADERS_=false"
                      ## </FIXME>
                      ),
                "special/noSuggests" =
                    "_R_CHECK_DEPENDS_ONLY_=true",
                "special/valgrind" =
                    c("R_LIBS_USER=NULL",
                      "_R_CHECK_CRAN_INCOMING_=false",
                      "_R_CHECK_RD_MATH_RENDERING_=false",
                      ## <FIXME>
                      ## remove eventually ...                      
                      "_R_CXX_USE_NO_REMAP_=false",
                      "_R_USE_STRICT_R_HEADERS_=false",
                      ## </FIXME>
                      "VALGRIND_OPTS=\"--fullpath-after=\"")
                )
    
    exe <- exe[[service]]
    arg <- arg[[service]]
    env <- env[[service]]
    
    cmd <- file.path(normalizePath("~"), "bin", "check-CRAN-incoming")
    val <- system2(cmd,
                   paste(c("-n -s",
                           paste0("-d=", wrk),
                           arg,
                           if(!is.null(exe))
                               paste("--exe", exe)),
                         collapse = " "),
                   env = c("_R_CHECK_CRAN_STATUS_SUMMARY_=false",
                           env),
                   stdout = file.path(wrk, "outputs.txt"),
                   stderr = file.path(wrk, "outputs.txt"))
    ## Should we check the value returned?

    if(reverse) {
        ## Create a summary of the changes in reverse depends.
        cmd <- file.path(normalizePath("~"),
                         "bin", "summarize-check-CRAN-incoming-changes")
        system2(cmd, c("-m -w -o", wrk),
                stdout = file.path(wrk, "changes.txt"))
    }

    if(process) {
        tmp <- file.path(wrk, paste0(sub("_.*", "", new), ".Rcheck"))
        bad <- if(service == "special/valgrind")
                   process_valg(tmp)
               else
                   process_xtra(tmp)
        writeLines(format_process_outputs(bad),
                   file.path(wrk, "process.txt"))
    }
        
    if(dir.exists(file.path(results.d, new)))
        unlink(file.path(results.d, new), recursive = TRUE)
    file.rename(wrk, file.path(results.d, new))

    ## Populate outputs for rsync from cran master.
    if(dir.exists(file.path(outputs.d, new)))
        unlink(file.path(outputs.d, new), recursive = TRUE)
    dir.create(file.path(outputs.d, new))
    file.copy(file.path(results.d, new, "outputs.txt"),
              file.path(outputs.d, new))
    if(reverse)
        file.copy(file.path(results.d, new, "changes.txt"),
                  file.path(outputs.d, new))
    if(process)
        file.copy(file.path(results.d, new, "process.txt"),
                  file.path(outputs.d, new))
    package <- sub("_.*", "", new)
    if(dir.exists(from <- file.path(results.d, new,
                                    paste0(package, ".Rcheck")))) {
        dir.create(to <- file.path(outputs.d, new, "package"))
        file.copy(file.path(from, "00check.log"), to)
        if(file.exists(fp <- file.path(from, "00install.out")))
            file.copy(fp, to)
        writeLines(summarize(file.path(outputs.d, new),
                             reverse, process),
                   file.path(outputs.d, new, "summary.txt"))
    }

    return(0)
}

if(!interactive()) {
    service <- "pretest"
    args <- commandArgs(trailingOnly = TRUE)
    if(any(ind <- startsWith(args, "-r"))) {
        service <- "recheck"
        args <- args[!ind]
    }
    if(any(ind <- startsWith(args, "-s="))) {
        service <- paste0("special/", substring(args[ind][1L], 4L))
        args <- args[!ind]
    }
    if(any(ind <- startsWith(args, "-t="))) {
        top <- substring(args[ind][1L], 4L)
        args <- args[!ind]
    }
    val <- run(service)
}

if(FALSE) {
    while(TRUE) {
        run()
        Sys.sleep(1)
    }
}
