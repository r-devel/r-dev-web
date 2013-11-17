require("tools", quietly = TRUE)

check_log_URL <- "http://www.R-project.org/nosvn/R.check/"

## r_patched_is_prelease <- TRUE
## r_p_o_p <- if(r_patched_is_prelease) "r-prerel" else "r-patched"

GCC_compilers_KH <- "GCC 4.8.2 (Debian 4.8.2-1)"
## GCC_compilers_UL_32 <- "GCC 4.2.1-sjlj (mingw32-2)"
## GCC_compilers_UL_64 <- "GCC 4.5.0 20100105 (experimental)"
GCC_compilers_SU <- "GCC 4.2.1"
## i686-apple-darwin10-llvm-gcc-4.2 (GCC) 4.2.1 (Based on Apple Inc. build 5658) (LLVM build 2336.1.00)

## Adjust as needed, in particular for prerelease stages.
## <NOTE>
## Keeps this in sync with
##   lib/bash/check_R_cp_logs.sh
##   lib/bash/cran_daily_check_results.sh
## (or create a common data base eventually ...)
## </NOTE>

check_flavors_db <- local({
    fields <-
        list(c("r-devel-linux-x86_64-debian-clang",
               "r-devel", "Linux", "x86_64", "(Debian Clang)",
               "Debian GNU/Linux testing",
               "2x 8-core Intel(R) Xeon(R) CPU E5-2690 0 @ 2.90GHz",
               paste("Debian clang version 3.3-12 (branches/release_33);",
                     "GNU Fortran (GCC)",
                     substring(GCC_compilers_KH, 5))),
             c("r-devel-linux-x86_64-debian-gcc",
               "r-devel", "Linux", "x86_64", "(Debian GCC)",
               "Debian GNU/Linux testing",
               "2x 8-core Intel(R) Xeon(R) CPU E5-2690 0 @ 2.90GHz",
               GCC_compilers_KH),
             c("r-devel-linux-x86_64-fedora-clang",
               "r-devel", "Linux", "x86_64", "(Fedora Clang)",
               "Fedora 18",
               "2x 6-core Intel Xeon E5-2440 0 @ 2.40GHz",
               "clang version 3.3 (tags/RELEASE_33/final); GNU Fortran (GCC) 4.7.2 20121109 (Red Hat 4.7.2-8)"),
             c("r-devel-linux-x86_64-fedora-gcc",
               "r-devel", "Linux", "x86_64", "(Fedora GCC)",
               "Fedora 18",
               "2x 6-core Intel Xeon E5-2440 0 @ 2.40GHz",
               "gcc (GCC) 4.7.2 20121109 (Red Hat 4.7.2-8)"),
             c("r-devel-macosx-x86_64",
               "r-devel", "OS X", "x86_64", "",
               "OS X 10.9",
               "iMac, 4-core Intel Core i7 @ 3.10GHz",
               "clang-500.2.79 (based on LLVM 3.3svn), gfortran 4.2.3"),
             c("r-devel-windows-ix86+x86_64",
               "r-devel", "Windows", "ix86+x86_64", "",
               "Windows Server 2008 (64-bit)",
               "2x Intel Xeon E5-2670 (8 core) @ 2.6GHz",
               "GCC 4.6.3 20111208 (prerelease)"),
             c("r-patched-linux-x86_64",
               "r-patched", "Linux", "x86_64", "",
               "Debian GNU/Linux testing",
               "2x 8-core Intel(R) Xeon(R) CPU E5-2690 0 @ 2.90GHz",
               GCC_compilers_KH),
             c("r-patched-solaris-sparc",
               "r-patched", "Solaris", "sparc", "",
               "Solaris 10",
               "8-core UltraSPARC T2 CPU @ 1.2 GHz",
               "Solaris Studio 12.3"),
             c("r-patched-solaris-x86",
               "r-patched", "Solaris", "x86", "",
               "Solaris 10",
               "8x Opteron 8218 (dual core) @ 2.6 GHz",
               "Solaris Studio 12.3"),
             c("r-release-linux-ix86",
               "r-release", "Linux", "ix86", "",
               "Debian GNU/Linux testing",
               "Intel(R) Core(TM)2 Duo CPU E6850 @ 3.00GHz",
               GCC_compilers_KH),
             c("r-release-linux-x86_64",
               "r-release", "Linux", "x86_64", "",
               "Debian GNU/Linux testing",
               "2x 8-core Intel(R) Xeon(R) CPU E5-2690 0 @ 2.90GHz",
               GCC_compilers_KH),
             c("r-release-macosx-x86_64",
               "r-release", "MacOS X", "x86_64", "",
               "Mac OS X 10.6.8",
               "MacPro, Intel Xeon 54XX @ 2.80GHz",
               GCC_compilers_SU),
             c("r-release-windows-ix86+x86_64",
               "r-release", "Windows", "ix86+x86_64", "",
               "Windows Server 2008 (64-bit)",
               "2x Intel Xeon E5-2670 (8 core) @ 2.6GHz",
               "GCC 4.6.3 20111208 (prerelease)"),
             ## c("r-oldrel-macosx-ix86",
             ##   "r-oldrel", "MacOS X", "ix86", "",
             ##   "Mac OS X 10.5.8 (9L31a)",
             ##   "MacPro, Intel Xeon 54XX @ 2.80GHz",
             ##   GCC_compilers_SU),
             c("r-oldrel-windows-ix86+x86_64",
               "r-oldrel", "Windows", "ix86+x86_64", "",
               "Windows Server 2008 (64-bit)",
               "2x Intel Xeon E5-2670 (8 core) @ 2.6GHz",
               "GCC 4.6.3 20111208 (prerelease)")
             )
    db <- do.call(rbind, fields)
    dimnames(db) <- list(db[, 1L], 
                         c("Label", "Flavor", "OS_type", "CPU_type",
                           "Spec", "OS_kind", "CPU_info", "Compilers") )
    as.data.frame(db[, -1L], stringsAsFactors = FALSE)
})

## Even more ugliness ...
## <FIXME>
## Perhaps this can be merged into check_flavors_db?
check_flavors_map <- if(system2("hostname", stdout = TRUE) == "gimli") {
    c("r-devel-clang" = "r-devel-linux-x86_64-debian-clang",
      "r-devel-gcc" = "r-devel-linux-x86_64-debian-gcc",
      "r-patched-gcc" = "r-patched-linux-x86_64",
      "r-release-gcc" = "r-release-linux-x86_64",
      "r-prerel-gcc" = "r-prerel-linux-x86_64")
} else NULL
## </FIXME>

## Cannot use 'r-devel-windows-ix86+x86_64' as HTML id attribute as
## these should not contain a plus.
.valid_HTML_id_attribute <-
function(s)
    gsub("[^[:alnum:]_:.-]", "_", s)    

write_check_flavors_db_as_HTML <-
function(db = check_flavors_db, out = "")
{
    if(out == "") 
        out <- stdout()
    else if(is.character(out)) {
        out <- file(out, "wt")
        on.exit(close(out))
    }
    if(!inherits(out, "connection")) 
        stop("'out' must be a character string or connection")

    ## <FIXME>
    ## Drop Spec for now ...
    db$Spec <- NULL
    ## </FIXME>

    flavors <- rownames(db)

    writeLines(c("<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">",
                 "<html xmlns=\"http://www.w3.org/1999/xhtml\">",
                 "<head>",
                 "<title>CRAN Package Check Flavors</title>",
                 "<link rel=\"stylesheet\" type=\"text/css\" href=\"../CRAN_web.css\"/>",
                 "</head>",
                 "<body lang=\"en\">",
                 "<h2>CRAN Package Check Flavors</h2>",
                 "<p>",
                 sprintf("Last updated on %s.", format(Sys.time())),
                 "</p>",
                 "<p>",
                 "Systems used for CRAN package checking.",
                 "</p>",
                 "<table border=\"1\" summary=\"CRAN check flavors.\">",
                 paste("<tr>",
                       paste(sprintf("<th> %s </th>",
                                     gsub(" ", "&nbsp;",
                                          c("Flavor", "R Version",
                                            "OS Type", "CPU Type",
                                            "OS Info", "CPU Info",
                                            "Compilers"))),
                             collapse = " "),
                       "</tr>"),
                 do.call(sprintf,
                         c(list(paste("<tr id=\"%s\">",
                                      paste(rep.int("<td> %s </td>",
                                                    ncol(db) + 1L),
                                            collapse = " "),
                                      "</tr>")),
                           list(.valid_HTML_id_attribute(flavors)),
                           list(flavors),
                           db)),
                 "</table>",
                 "</body>",
                 "</html>"),
               out)
}

check_flavor_summary <-
function(dir =
         file.path("~", "tmp", "R.check",
                   "r-devel-linux-x86_64-debian-clang"),
         check_dirs_root = file.path(dir, "PKGS"))
{
    if(!file_test("-d", check_dirs_root)) return()

    ## Just making sure ...
    lc_ctype <- Sys.getlocale("LC_CTYPE")
    Sys.setlocale("LC_CTYPE", "en_US.UTF-8")
    on.exit(Sys.setlocale("LC_CTYPE", lc_ctype))

    ## Assume R 2.6.0 or later.
    is_invalid_multibyte_string <- function(s)
        is.na(nchar(s, "c", allowNA = TRUE))

    get_description_fields_as_utf8 <-
        function(dfile, fields = c("Version", "Priority", "Maintainer"))
    {
        ## Assume a UTF-8 locale.
        meta <- if(file.exists(dfile))
            try(read.dcf(dfile,
                         fields = unique(c(fields, "Encoding")))[1L, ],
                silent = TRUE)
        else
            NULL
        ## What if this fails?  Grr ...
        if(inherits(meta, "try-error") || is.null(meta))
            return(rep.int("", length(fields)))
        else if(any(i <- !is.na(meta) &
                    is_invalid_multibyte_string(meta))) {
            ## Try converting to UTF-8.
            from <- meta["Encoding"]
            if(is.na(from)) from <- "latin1"
            meta[i] <- iconv(meta[i], from, "UTF-8")
        }
        meta[fields]
    }
    
    check_dirs <- list.files(path = check_dirs_root,
                             pattern = "\\.Rcheck", full.names = TRUE)
    check_logs <- file.path(check_dirs, "00check.log")
    if(!all(ind <- file.exists(check_logs))) {
        check_dirs <- check_dirs[ind]
        check_logs <- check_logs[ind]
    }
    ## Want Package, Version, Priority, Maintainer, Status, Flags.    
    summary <- matrix(character(), nrow = length(check_dirs), ncol = 6L)
    fields <- c("Version", "Priority", "Maintainer")
    for(i in seq_along(check_dirs)) {
        check_dir <- check_dirs[i]
        meta <- get_description_fields_as_utf8(file.path(check_dir,
                                                         "00package.dcf"))
        log <- readLines(check_logs[i], warn = FALSE)
        ## <FIXME>
        ## Get rid of invalid lines for now ...
        ## Re-encode eventually ...
        log <- log[!is.na(nchar(log, allowNA = TRUE))]
        ## </FIXME>
        status <- if(any(grep("ERROR$", log)))
            "ERROR"
        else if(any(grep("WARNING$", log)))
            "WARN"
        else if(any(grep("NOTE$", log)))
            "NOTE"
        else
            "OK"
        ## <FIXME>
        flags <-
            if(length(grep("^\\* this is a Windows-only package, skipping installation",
                           log))) {
                "--install=no"
            } else if(length(pos <-
                           grep("^\\* using options? ['‘].*['’]$", log))) {
                ## Run-time check et al option reporting in 2.10 or
                ## better.
                sub("^\\* using options? ['‘](.*)['’]$", "\\1", log[pos[1L]])
            } else ""
        ## ## <NOTE>
        ## ## R 2.10.0 or later has standardized this ...
        ## ## We really want the special flags used for checking.
        ## ## Can get them for the Linux runs for now.
        ## flags <- if(length(grep("linux|windows", basename(dir)))) {
        ##     if(length(grep("^\\* this is a Windows-only package, skipping installation",
        ##                    log)))
        ##         "--install=no"
        ##     else if(length(pos <-
        ##                    grep("^\\* using options? '.*'$", log))) {
        ##         ## Run-time check et al option reporting in 2.10 or
        ##         ## better.
        ##         sub("^\\* using options? '(.*)'$", "\\1", log[pos[1L]])
        ##     }
        ##     else {
        ##         log <- log[length(log)]
        ##         if(length(grep("^\\* using check arguments '.*'", log)))
        ##             sub("^\\* using check arguments '(.*)'$", "\\1", log)
        ##         else
        ##             ""
        ##     }
        ## }
        ## else {
        ##     ## Old style code.
        ##     if(any(grep("^\\*+ checking examples ", log))
        ##         || (status == "ERROR"))
        ##         ""
        ##     else if(any(grep("^\\*+ checking.*can be installed ", log)))
        ##         "--install=fake"
        ##     else
        ##         "--install=no"
        ## }
        ## ## </NOTE>
        ## </FIXME>
        summary[i, ] <-
            cbind(file_path_sans_ext(basename(check_dir)),
                  rbind(meta, deparse.level = 0),
                  status, flags)
    }
    colnames(summary) <- c("Package", fields, "Status", "Flags")
    
    data.frame(summary, stringsAsFactors = FALSE)
}

check_flavor_timings <-
function(dir = file.path("~", "tmp", "R.check", "r-devel-linux-ix86"))
{
    if(length(grep("windows", basename(dir)))) {
        status <- file.path(dir, "PKGS", "Status")
        if(!file.exists(status)) return()
        status <- read.table(status, header = TRUE)
        timings <- status[c("packages", "insttime", "checktime")]
    }
    else if(length(tfile <- Sys.glob(file.path(dir, "*-times.tab")))) {
        ## Only get total time in this case, hence return right away.
        timings <- read.table(tfile[1L], header = TRUE,
                              stringsAsFactors = FALSE)
        names(timings) <- c("Package", "T_total")
        timings$T_install <- NA_real_
        timings$T_check <- NA_real_
        return(timings)
    }
    else if(length(grep("macosx", basename(dir)))) {
        summary_file <- file.path(dir, "PKGS", "00_summary_info")
        if(!file.exists(summary_file)) return()
        t_i <- read.table(summary_file, sep = "|", header = FALSE)
        names(t_i) <-
            c("Package", "Version", "chk_result", "install_result",
              "install_start", "install_duration", "binary")
        ## Currently, number of fields is not always nine ...
        chkinfo_file <- file.path(dir, "PKGS", "00_summary_chkinfo")
        if(!file.exists(chkinfo_file)) return()
        n_of_fields <- count.fields(chkinfo_file, sep = "|")
        if(any(ind <- (n_of_fields < max(n_of_fields)))) {
            lines <- readLines(chkinfo_file)
            lines[ind] <-
                paste(lines[ind],
                      sapply(max(n_of_fields) - n_of_fields[ind],
                             function(n) paste(rep.int("|", n),
                                               collapse = "")),
                      sep = "")
            con <- textConnection(lines)
            on.exit(close(con))
            t_c <- read.table(con, sep = "|", header = FALSE)
        }
        else 
            t_c <- read.table(chkinfo_file, sep = "|", header = FALSE)
        names(t_c) <-
            c("Package", "Version", "chk_result", "has_error",
              "has_warnings", "has_notes", "check_start",
              "check_duration", "flags")
        timings <- merge(t_i[c("Package", "install_duration")],
                         t_c[c("Package", "check_duration")],
                         by = "Package", all = TRUE)
    }
    else if(file.exists(tfile <- file.path(dir, "timings.csv"))) {
        return(read.csv(tfile))
    }
    else {
        t_c <- get_timings_from_timings_files(file.path(dir,
                                                        "time_c.out"))
        t_i <- get_timings_from_timings_files(file.path(dir,
                                                        "time_i.out"))
        if(is.null(t_i) || is.null(t_c)) return()
        ## <NOTE>
        ## We get error information ('Command exited with non-zero
        ## status') from both timings files, but currently do not use
        ## this further.
        ## </NOTE>
        timings <- merge(t_i[c("Package", "T_total")],
                         t_c[c("Package", "T_total")],
                         by = "Package", all = TRUE)
    }
    names(timings) <- c("Package", "T_install", "T_check")
    timings$T_total <-
        rowSums(timings[, c("T_install", "T_check")], na.rm = TRUE)
    timings
}

get_timings_from_timings_files <-
function(tfile)
{
    timings_files <- c(tfile, paste(tfile, "prev", sep = "."))
    timings_files <- timings_files[file.exists(timings_files)]
    if(!length(timings_files)) return()
    x <- paste(readLines(timings_files[1L], warn = FALSE),
               collapse = "\n")
    ## Safeguard against possibly incomplete entries.
    ## (Could there be incomplete ones not at eof?)
    is_complete <- grepl("swaps$", x)
    x <- unlist(strsplit(x, "swaps(\n|$)"))
    if(!is_complete) x <- x[-length(x)]
    x <- paste(x, "swaps", sep = "")
    ## Eliminate 'Command exited with non-zero ...'
    bad <- rep("OK", length(x))
    bad[grep(": Command (exited|terminated)[^\n]*\n", x)] <- "ERROR"
    x <- sub(": Command (exited|terminated)[^\n]*\n", ": ", x)
    x <- sub("([0-9])system .*", "\\1", x)
    x <- sub("([0-9])user ", "\\1 ", x)
    x <- sub(": ", " ", x)
    ## <NOTE>
    ## This fails when for some reason there are duplicated entries, so
    ## let's be nice ...
    ##   con <- textConnection(c("User System", x))
    ##   x <- read.table(con)
    ## </NOTE>
    con <- textConnection(x)
    y <- tryCatch(scan(con, list("", 0, 0), quiet = TRUE),
                  error = function(e) return(NULL))
    close(con)
    if(is.null(y)) return()
    ind <- !duplicated(y[[1L]])
    t_u <- y[[2L]][ind]
    t_s <- y[[3L]][ind]
    data.frame(Package = y[[1L]][ind], Status = bad[ind],
               T_user = t_u, T_system = t_s, T_total = t_u + t_s,
               stringsAsFactors = FALSE)
}

check_results_db <-
function(dir = file.path("~", "tmp", "R.check"), flavors = NULL)
{
    if(is.null(flavors))
        flavors <- row.names(check_flavors_db)
    flavors <- flavors[file.exists(file.path(dir, flavors))]

    verbose <- interactive()
    
    results <- vector("list", length(flavors))
    names(results) <- flavors

    for(flavor in flavors) {
        if(verbose)
            message(sprintf("Getting check summary for flavor %s", flavor))
        summary <- check_flavor_summary(file.path(dir, flavor))
        if(verbose)
            message(sprintf("Getting check timings for flavor %s", flavor))
        timings <- check_flavor_timings(file.path(dir, flavor))
        ## Sanitize: if there are no results, skip this flavor.
        if(!NROW(summary)) next
        results[[flavor]] <- if(is.null(timings))
            cbind(Flavor = flavor,
                  summary, T_check = NA, T_install = NA, T_total = NA)
        else
            cbind(Flavor = flavor,
                  merge(summary,
                        timings[, c("Package", "T_install",
                                    "T_check", "T_total")],
                        by = "Package", all = TRUE))
    }
    names(results) <- NULL
    do.call(rbind, results)
}

check_summary_summary <-
function(results)
{
    status <- results$Status
    status[status == "NOTE"] <- "OK"
    status <- factor(status, levels = c("OK", "WARN", "ERROR"))
    tab <- table(results$Flavor, status)
    cbind(tab, Total = rowSums(tab))
}

check_timings_summary <-
function(results)
{
    tab <- aggregate(results[, c("T_check", "T_install", "T_total")],
                     list(Flavor = results$Flavor), sum, na.rm = TRUE)
    out <- as.matrix(tab[, -1L])
    rownames(out) <- tab$Flavor
    out
}

write_check_results_db_as_HTML <-
function(results, dir = file.path("~", "tmp", "R.check", "web"))
{
    if(is.null(results)) return()

    dir <- path.expand(dir)
    if(!file_test("-d", dir))
        dir.create(dir, recursive = TRUE)

    verbose <- interactive()

    ## HTMLify checks results.
    ## First, create a version with hyperlinked *and* commented status
    ## info (in case a full check was not performed).
    ## Also add hyperlinked package variable, and remove maintainer
    ## email addresses.
    results$Maintainer <-
        sub("[[:space:]]*<[^>]+@[^>]+>.*", "", results$Maintainer)
    results$Maintainer <-
        gsub("&", "&amp;", results$Maintainer, fixed = TRUE) 
    results$Maintainer <- 
        gsub("<", "&lt;", results$Maintainer, fixed = TRUE)
    results$Maintainer <-
        gsub(">", "&gt;", results$Maintainer, fixed = TRUE)
    package <- results$Package
    status <-
        ifelse(is.na(results$Status) | is.na(results$Flags), "",
               paste(results$Status,
                     ifelse(nzchar(results$Flags), "<sup>*</sup>", ""),
                     sep = ""))
    if(length(ind <- grep("^OK", status)))
        status[ind] <- sprintf("<font color=\"black\">%s</font>",
                               status[ind])
    if(length(ind <- grep("^(WARN|ERROR)", status)))
        status[ind] <- sprintf("<font color=\"red\">%s</font>",
                               status[ind])
    if(length(ind <- nzchar(status)))
        status[ind] <-
            paste("<a href=\"",
                  check_log_URL, results$Flavor[ind],
                  "/",
                  package[ind],
                  "-00check.html\">",
                  status[ind],
                  "</a>",
                  sep = "")
    ## <FIXME 2.7.0>
    ## sprintf() now is optimized for a length one format string.
    ## <NOTE>
    ## Using
    ##         sprintf("<a href=\"%s%s/%s-00check.html\">%s</a>",
    ##                 check_log_URL, results$Flavor[ind],
    ##                 package[ind], status[ind])
    ## is much clearer, but apparently also much slower ...
    ## <FIXME>
    ## This is because sprintf() is vectorized in its fmt argument, and
    ## hence coerces its argument for each line.  When using factors,
    ## coerce them to character right away:
    ##         sprintf("<a href=\"%s%s/%s-00check.html\">%s</a>",
    ##                 check_log_URL, as.character(results$Flavor[ind]),
    ##                 package[ind], status[ind])
    ## </FIXME>
    ## </NOTE>
    ## </FIXME>
    results <-
        cbind(results,
              Hyperpack =
              sprintf("<a href=\"../packages/%s/index.html\">%s</a>",
                      package, package),
              Hyperstat = status)

    ## Create a "flat" check summary db with one column per flavor.
    ## Do this here for efficiency in case we want to provide a flat
    ## summary by maintainer as well.
    ind <- !is.na(results$Status)
    db <- split(results[ind,
                        c("Package", "Version", "Hyperpack",
                          "Hyperstat", "Priority", "Maintainer")],
                results$Flavor[ind])
    ## Eliminate the entries with no check status right away for
    ## simplicity.
    for(i in seq_along(db)) names(db[[i]])[4L] <- names(db)[i]
    db <- Reduce(function(x, y) merge(x, y, all = TRUE), db)
    ## And replace NAs and turn to character.
    db[] <- lapply(db,
                   function(s) {
                       ifelse(is.na(s), "",
                              if(is.numeric(s)) sprintf("%.2f", s)
                              else as.character(s))
                   })

    ## Start by creating the check summary HTML file.
    out <- file(file.path(dir, "check_summary.html"), "w")
    writeLines(check_summary_html_header(), out)
    if(verbose) message("Writing check results summary")
    writeLines(c("<p>Status summary:</p>",
                 check_summary_html_summary(results)),
               out)
    writeLines(paste("<p>",
                     "<a href=\"check_summary_by_maintainer.html#summary_by_maintainer\">",
                     "Results by maintainer",
                     "</a>",
                     "</p>"),
               out)
    if(verbose) message("Writing check results details")
    writeLines(c("<p>Results by package:</p>",
                 check_results_html_details_by_package(db)),
               out)
    writeLines(check_summary_html_footer(), out)
    close(out)

    ## Also create check summary details by maintainer.
    out <- file(file.path(dir, "check_summary_by_maintainer.html"), "w")
    if(verbose) message("Writing check results summary by maintainer")
    writeLines(c(check_summary_html_header(),
                 paste("<p>",
                       "<a href=\"check_summary.html#summary_by_package\">",
                       "Results by package",
                       "</a>",
                       "</p>"),
                 "<p>Results by maintainer:</p>",
                 paste("<p>",
                       "Maintainers can directly adress their results via",
                       "<code>http://CRAN.R-project.org/web/checks/check_summary_by_maintainer.html#<var>id</var></code>,",
                       "where <var>id</var> is obtained from shown maintainer name",
                       "with spaces replaced by underscores.",
                       "</p>"),
                 check_results_html_details_by_maintainer(db),
                 check_summary_html_footer()),
               out)
    close(out)
    
    ## Remove the comment/flag info from hyperstatus.
    results$Hyperstat <- sub("<sup>\\*</sup>", "", results$Hyperstat)

    ## Overall check timings summary.
    out <- file.path(dir, "check_timings.html")
    if(verbose) message(sprintf("Writing %s", out))
    write_check_timings_summary_as_HTML(results, out)

    ## Individual timings for flavors.
    for(flavor in levels(results$Flavor)) {
        out <- file.path(dir, sprintf("check_timings_%s.html", flavor))
        if(verbose) message(sprintf("Writing %s", out))
        write_check_timings_for_flavor_as_HTML(results, flavor, out)
    }

    ## Results for each package.
    write_check_results_for_packages_as_HTML(results, dir)

    ## And finally, a little index.
    write_check_index(file.path(dir, "index.html"))
}

check_summary_html_header <-
function()
    c("<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">",
      "<html xmlns=\"http://www.w3.org/1999/xhtml\" lang=\"en\">",
      "<head>",
      "<title>CRAN Package Check Results</title>",
      "<link rel=\"stylesheet\" type=\"text/css\" href=\"../CRAN_web.css\"/>",
      "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\"/>",
      "</head>",
      "<body lang=\"en\">",
      "<h1>CRAN Package Check Results</h1>",
      "<p>",
      sprintf("Last updated on %s.", format(Sys.time())),
      "</p>",
      "<p>",
      "Results for installing and checking packages",
      "using the three current flavors of R on systems running",
      "Debian GNU/Linux, Fedora, MacOS X, Solaris and Windows.",
      "</p>")
    
check_summary_html_summary <-
function(results)
{
    tab <- check_summary_summary(results)
    flavors <- rownames(tab)
    fmt <- paste("<tr>",
                 "<td> <a href=\"check_flavors.html#%s\"> %s </a> </td>",
                 "<td align=\"right\"> %s </td>",
                 "<td align=\"right\"> %s </td>",
                 "<td align=\"right\"> %s </td>",
                 "<td align=\"right\"> %s </td>",
                 "<td> <a href=\"check_details_%s.html\"> Details </a> </td>",
                 "</tr>")
    c("<table border=\"1\" summary=\"CRAN check results summary.\">",
      paste("<tr>",
            "<th> Flavor </th>",
            "<th> OK </th>",
            "<th> WARN </th>",
            "<th> ERROR </th>",
            "<th> Total </th>",
            "<th> </th>",
            "</tr>"),
      sprintf(fmt,
              .valid_HTML_id_attribute(flavors), flavors,
              tab[, "OK"],
              tab[, "WARN"],
              tab[, "ERROR"],
              tab[, "Total"],
              flavors),
      "</table>")
}

check_results_html_details_by_package <-
function(db)
{
    flavors <- intersect(names(db), row.names(check_flavors_db))
    fmt <- paste("<tr>",
                 paste(rep.int("<td> %s </td>", length(flavors) + 4L),
                       collapse = " "),
                 "</tr>")
    package <- db$Package
    db <- db[order(package), ]

    ## Prefer to link to package check results pages (rather than
    ## package web pages) from the check summaries.  To change back, use
    ##   hyperpack <- db[, "Hyperpack"]
    hyperpack <- sprintf("<a href=\"check_results_%s.html\">%s</a>",
                         package, package)
    
    flavors_db <-
        check_flavors_db[flavors,
                         c("Flavor", "OS_type", "CPU_type", "Spec")]
    flavors_db$OS_type <- gsub(" ", "&nbsp;", flavors_db$OS_type)
    c("<table border=\"1\" id=\"summary_by_package\" summary=\"CRAN daily check summary by package.\">",
      paste("<tr>",
            "<th> Package </th>",
            "<th> Version </th>",
            paste(do.call(sprintf,
                          c(list(paste("<th>",
                                       "<a href=\"check_flavors.html#%s\">",
                                       "%s<br/>%s<br/>%s<br/>%s",
                                       "</a>",
                                       "</th>"),
                                 .valid_HTML_id_attribute(flavors)),
                            flavors_db)),
                  collapse = " "),
            "<th> Maintainer </th>",
            "<th> Priority </th>"),
      do.call(sprintf,
              c(list(fmt, hyperpack),
                db[c("Version", flavors, "Maintainer", "Priority")])),
      "</table>")
}

check_results_html_details_by_maintainer <-
function(db)
{
    ## Very similar to the above.
    ## Obviously, this could be generalized ...
    flavors <- intersect(names(db), row.names(check_flavors_db))
    fmt <- paste("<tr>",
                 paste(rep.int("<td> %s </td>", length(flavors) + 4L),
                       collapse = " "),
                 "</tr>")
    ## Drop entries with "missing" (empty, i.e., just email address)
    ## maintainer.
    db <- db[nzchar(db$Maintainer) & (db$Maintainer != "ORPHANED"), ]
    ## And sort according to maintainer.
    db <- db[order(db$Maintainer), ]

    ## Make maintainer results bookmarkable: ids must begin with a
    ## letter ([A-Za-z]) and may be followed by any number of letters,
    ## digits ([0-9]), hyphens, underscores, colons, and periods.
    ## Remove parenthesized material.
    maintainer <- gsub("\\([^)]*\\)", "", db$Maintainer)
    ## Remove trailing punctuations.
    maintainer <- gsub("[[:punct:]]+$", "", maintainer)
    maintainer <- gsub("[[:space:],;]+", "_", maintainer)
    ## Try transliterating what remains to canonicalize letters.
    maintainer <- iconv(maintainer, "", "ASCII//TRANSLIT")
    ## And remove everything that would be invalid id characters.
    maintainer <- gsub("[^[:alnum:]_:.-]", "", maintainer)
    ind <- split(seq_along(maintainer), tolower(maintainer))
    ## Use tolower() as some maintainer have entries with case diffs.
    nms <- maintainer[sapply(ind, `[`, 1L)]
    bad <- is.na(nms)
    if(any(bad)) {
        ind <- ind[!bad]
        nms <- nms[!bad]
    }

    package <- db$Package    
    ## Prefer to link to package check results pages (rather than
    ## package web pages) from the check summaries.  To change back, use
    ##   hyperpack <- db[, "Hyperpack"]
    hyperpack <- sprintf("<a href=\"check_results_%s.html\">%s</a>",
                         package, package)

    flavors_db <-
        check_flavors_db[flavors,
                         c("Flavor", "OS_type", "CPU_type", "Spec")]
    flavors_db$OS_type <- gsub(" ", "&nbsp;", flavors_db$OS_type)

    c("<table border=\"1\" id=\"summary_by_maintainer\" summary=\"CRAN check summary by maintainer.\">",
      paste("<tr>",
            "<th> Maintainer </th>",
            "<th> Package </th>",
            "<th> Version </th>",
            paste(do.call(sprintf,
                          c(list(paste("<th>",
                                       "<a href=\"check_flavors.html#%s\">",
                                       "%s<br/>%s<br/>%s<br/>%s",
                                       "</a>",
                                       "</th>"),
                                 .valid_HTML_id_attribute(flavors)),
                            flavors_db)),
                  collapse = " "),
            "<th> Priority </th>"),
      unlist(mapply(c,
                    sprintf("<tr id=\"%s\"/>", nms),
                    lapply(ind,
                           function(i) {
                               do.call(sprintf,
                                       c(list(fmt,
                                              db[i, "Maintainer"],
                                              hyperpack[i]),
                                         db[i, c("Version",
                                                 flavors,
                                                 "Priority")]))
                           })),
             use.names = FALSE),
      "</table>")
}

check_summary_html_footer <-
function()
    c("<p>",
      "Results with asterisks (<sup>*</sup>) indicate that checking",
      "was not fully performed.",
      "</p>",
      "</body>",
      "</html>")

write_check_timings_summary_as_HTML <-
function(results, out = "")
{
    if(!length(results)) return()

    if(out == "") 
        out <- stdout()
    else if(is.character(out)) {
        out <- file(out, "wt")
        on.exit(close(out))
    }
    if(!inherits(out, "connection")) 
        stop("'out' must be a character string or connection")
    
    writeLines(c("<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">",
                 "<html xmlns=\"http://www.w3.org/1999/xhtml\" lang=\"en\">",
                 "<head>",
                 "<title>CRAN Package Check Timings</title>",
                 "<link rel=\"stylesheet\" type=\"text/css\" href=\"../CRAN_web.css\"/>",
                 "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\"/>",
                 "</head>",
                 "<body lang=\"en\">",
                 "<h1>CRAN Package Check Timings</h1>",
                 "<p>",
                 sprintf("Last updated on %s.", format(Sys.time())),
                 "</p>",
                 "<p>",
                 "Available overall timings (in seconds) for installing and checking all CRAN packages.",
                 "</p>"),
               out)

    tab <- check_timings_summary(results)
    tab <- tab[tab[, "T_total"] > 0, ]
    flavors <- rownames(tab)
    fmt <- paste("<tr>",
                 "<td> <a href=\"check_flavors.html#%s\"> %s </a> </td>",
                 "<td align=\"right\"> %.2f </td>",
                 "<td align=\"right\"> %.2f </td>",
                 "<td align=\"right\"> %.2f </td>",
                 "<td> <a href=\"check_timings_%s.html\"> Details </a> </td>",
                 "</tr>")
    ## For some flavors we only have the total time: show nothing
    ## instead of 0.00 for the install or check times in this case.
    tab <- sprintf(fmt,
                   .valid_HTML_id_attribute(flavors), flavors,
                   tab[, "T_check"],
                   tab[, "T_install"],
                   tab[, "T_total"],
                   flavors)
    tab <- gsub(" 0.00", " ", tab)
    writeLines(c("<table border=\"1\" summary=\"CRAN check timings summary.\">",
                 paste("<tr>",
                       "<th> Flavor </th>",
                       "<th> T<sub>check</sub> </th>",
                       "<th> T<sub>install</sub> </th>",
                       "<th> T<sub>total</sub> </th>",
                       "<th> </th>",
                       "</tr>"),
                 tab,
                 "</table>",
                 "</body>",
                 "</html>"),
               out)
}

write_check_timings_for_flavor_as_HTML <-
function(results, flavor, out = "")
{
    db <- results[results$Flavor == flavor, ]
    if(nrow(db) == 0L || all(is.na(db$T_total))) return()

    db <- db[order(db$T_total, decreasing = TRUE), ]

    if(out == "") 
        out <- stdout()
    else if(is.character(out)) {
        out <- file(out, "wt")
        on.exit(close(out))
    }
    if(!inherits(out, "connection")) 
        stop("'out' must be a character string or connection")

    ## Need to efficiently replace missings in timings and flags.
    ## (Could we have a missing check time?)
    fields <- c("T_check", "T_install", "Flags")
    db[fields] <-
        lapply(db[fields],
               function(s)
               ifelse(is.na(s), "",
                      if(is.numeric(s)) sprintf("%.2f", s)
                      else as.character(s)))
    
    writeLines(c("<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">",
                 "<html xmlns=\"http://www.w3.org/1999/xhtml\">",
                 "<head>",
                 "<title>CRAN Package Check Timings</title>",
                 "<link rel=\"stylesheet\" type=\"text/css\" href=\"../CRAN_web.css\"/>",
                 "</head>",
                 "<body lang=\"en\">",
                 sprintf("<h2>CRAN Package Check Timings for %s</h2>",
                         flavor),
                 "<p>",
                 sprintf("Last updated on %s.", format(Sys.time())),
                 "</p>",
                 "<p>",
                 "Timings for installing and checking packages",
                 sprintf("for %s on a system running %s (CPU: %s).",
                         check_flavors_db[flavor, "Flavor"],
                         check_flavors_db[flavor, "OS_kind"],
                         check_flavors_db[flavor, "CPU_info"]),
                 "</p>",                 
                 "<p>",
                 sprintf("Total seconds: %.2f (%.2f hours).",
                         sum(db$T_total, na.rm = TRUE),
                         sum(db$T_total, na.rm = TRUE) / 3600),
                 "</p>",
                 "<table border=\"1\" summary=\"CRAN check timings details.\">",
                 paste("<tr>",
                       "<th> Package </th>",
                       "<th> T<sub>total</sub> </th>",
                       "<th> T<sub>check</sub> </th>",
                       "<th> T<sub>install</sub> </th>",
                       "<th> Status </th>",
                       "<th> Flags </th>",
                       "</tr>"),
                 do.call(sprintf,
                         c(list(paste("<tr>",
                                      "<td> %s </td>",
                                      "<td align=\"right\"> %.2f </td>",
                                      "<td align=\"right\"> %s </td>",
                                      "<td align=\"right\"> %s </td>",
                                      "<td> %s </td>",
                                      "<td> %s </td>")),
                           db[c("Hyperpack", "T_total", "T_check",
                                "T_install", "Hyperstat", "Flags")])),
                 "</table>",
                 "</body>",
                 "</html>"),
               out)
}

write_check_results_for_packages_as_HTML <-
function(results, dir)
{
    verbose <- interactive()

    ## Drop entries with no status.
    results <- results[!is.na(results$Status), ]
    ## Simplify results.
    results[] <-
        lapply(results,
               function(s) {
                   ifelse(is.na(s), "",
                          if(is.numeric(s)) sprintf("%.2f", s)
                          else as.character(s))
               })

    ind <- split(seq_len(nrow(results)), results$Package)
    nms <- names(ind)
    for(i in seq_along(ind)) {
        package <- nms[i]
        out <- file.path(dir, sprintf("check_results_%s.html", package))
        if(verbose) message(sprintf("Writing %s", out))
        write_check_results_for_package_as_HTML(package,
                                                results[ind[[i]], ,
                                                        drop = FALSE],
                                                out)
    }
}

write_check_results_for_package_as_HTML <-
function(package, entries, out = "")
{
    lines <-
        c("<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">",
          "<html xmlns=\"http://www.w3.org/1999/xhtml\" lang=\"en\">",
          "<head>",
          "<title>CRAN Package Check Results</title>",
          "<link rel=\"stylesheet\" type=\"text/css\" href=\"../CRAN_web.css\"/>",
          "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\"/>",
          "</head>",
          "<body lang=\"en\">",
          sprintf(paste("<h2>CRAN Package Check Results for Package",
                        "<a href=\"../packages/%s/index.html\"> %s </a>",
                        "</h2>"),
                  package, package),
          "<p>",
          sprintf("Last updated on %s.", format(Sys.time())),
          "</p>",
          sprintf("<table border=\"1\" summary=\"CRAN check results for package %s\">",
                  package),
          paste("<tr>",
                "<th> Flavor </th>",
                "<th> Version </th>",
                "<th> T<sub>install</sub> </th>",
                "<th> T<sub>check</sub> </th>",
                "<th> T<sub>total</sub> </th>",                
                "<th> Status </th>",
                "<th> Flags </th>",
                "</tr>"),
          do.call(sprintf,
                  c(list(paste("<tr>",
                               "<td>",
                               " <a href=\"check_flavors.html#%s\"> %s </a>",
                               "</td>",
                               "<td> %s </td>",
                               "<td align=\"right\"> %s </td>",
                               "<td align=\"right\"> %s </td>",
                               "<td align=\"right\"> %s </td>",
                               "<td> %s </td>",
                               "<td> %s </td>")),
                    list(.valid_HTML_id_attribute(entries$Flavor)),
                    entries[c("Flavor", "Version",
                              "T_install", "T_check", "T_total",
                              "Hyperstat", "Flags")])),
          "</table>",
          "</body>",
          "</html>")
    
    writeLines(lines, out)
}

write_check_index <-
function(out = "")
{
    writeLines(c(check_summary_html_header(),
                 paste("<p>",
                       "<a href=\"check_summary.html\">",
                       "Package check results by package",
                       "</a>",
                       "</p>",
                       sep = ""),
                 paste("<p>",
                       "<a href=\"check_summary_by_maintainer.html\">",
                       "Package check results by maintainer",
                       "</a>",
                       "</p>",
                       sep = ""),
                 paste("<p>",
                       "<a href=\"check_timings.html\">",
                       "Package check timings",
                       "</a>",
                       "</p>",
                       sep = ""),
                 paste("<p>",
                       "<a href=\"check_flavors.html\">",
                       "Package check flavors",
                       "</a>",
                       "</p>",
                       sep = ""),
                 "</body>",
                 "</html>"),
               out)
}

## <FIXME>
## Log files are tricky because these can be invalid in an MBCS.
## 2.7.0 has added
##  * using session charset: UTF-8
## lines which we could try to use.
## In general, we should check whether the lines read are invalid and
## try to reencode.  If this fails, we should perhaps fall back to using
## a C locale and indicate the problem (message ...).
## Note also that we currently hard-wire UTF-8 in the HTML header infos
## even though we really have no idea about the encoding ...
## </FIXME>

write_check_log_as_HTML <-
function(log, out = "", subsections = FALSE)
{
    if(out == "") 
        out <- stdout()
    else if(is.character(out)) {
        out <- file(out, "wt")
        on.exit(close(out))
    }
    if(!inherits(out, "connection")) 
        stop("'out' must be a character string or connection")
    
    lines <- readLines(log, warn = FALSE)[-1L]
    ## The first line says
    ##   using log directory '/var/www/R.check/......"
    ## which is really useless ...

    ## Encoding ...
    if(any(ind <- is.na(nchar(lines, allowNA = TRUE)))) {
        ## We could try re-encoding from latin1 first, but that is not
        ## too helpful in case of errors about invalid MBCS ...
        lines[ind] <- iconv(lines[ind], "", "", sub = "byte")
    }
    
    ## HTML escapes:
    lines <- gsub("&", "&amp;", lines)
    lines <- gsub("<", "&lt;", lines)
    lines <- gsub(">", "&gt;", lines)

    ## Fancy stuff:
    ind <- grep("^\\*\\*? ", lines)
    lines[ind] <- sub("(\\.\\.\\.( \\[.*\\])?) (WARNING|ERROR)$",
                      "\\1 <span class=\"boldred\">\\3</span>",
                      lines[ind])

    ## Convert pointers to install.log:
    ind <- grep("^See ['‘]http://.*['’] for details.$", lines)
    if(length(ind))
        lines[ind] <- sub("^See ['‘](.*)['’] for details.$",
                          "See <a href=\"\\1\">\\1</a> for details.",
                          lines[ind])

    if(subsections) {
        ## In the old days, we had bundles.
        ## Now, we have multiarch ...
        ## Sectioning.
        ## Somewhat tricky as we like to append closing </li> to the
        ## lines previous to new section starts, so that we can easily
        ## identify the "uninteresting" OK lines (see below).
        count <- rep.int(0L, length(lines))
        count[grep("^\\* ", lines)] <- 1L
        count[grep("^\\*\\* ", lines)] <- 2L
        ## Hmm, using substring() might be faster than grepping.
        ind <- (count > 0L)
        ## Lines with count zero are "continuation" lines, so the ones
        ## before these get a line break.
        pos <- which(!ind) - 1L
        if(length(pos))
            lines[pos] <- paste(lines[pos], "<br/>", sep = "")
        ## Lines with positive count start a new section.
        pos <- which(ind)
        lines[pos] <- sub("^\\*{1,2} ", "<li>", lines[pos])
        ## What happens to the previous line depends on whether a new
        ## subsection is started (bundles), and old same-level section
        ## or subsection is closed, or both a subsection and section are
        ## closed: these cases can be distinguished by looking at the
        ## count differences (values 1, 0, and -1, respectively).
        delta <- c(0, diff(count[pos]))
        pos <- pos - 1L
        if(length(p <- pos[delta > 0]))
            lines[p] <- paste(lines[p], "\n<ul>", sep = "")
        if(length(p <- pos[delta == 0]))
            lines[p] <- paste(lines[p], "</li>", sep = "")
        if(length(p <- pos[delta < 0]))
            lines[p] <- paste(lines[p], "</li>\n</ul></li>", sep = "")
        ## The last line always ends a section, and maybe also a
        ## subsection.
        len <- length(lines)
        lines[len] <- sprintf("%s</li>%s", lines[len],
                              if(count[pos[length(pos)] + 1L] > 1L)
                              "\n</ul></li>" else "")
    } else {
        ind <- substring(lines, 1L, 2L) == "* "
        if(!any(ind))
            lines <- character()
        ## Lines not starting with '* ' are "continuation" lines, so the
        ## ones before these get a line break.
        pos <- which(!ind) - 1L
        if(length(pos))
            lines[pos] <- paste(lines[pos], "<br/>", sep = "")
        ## Lines starting with '* ' start a new block, and end the old
        ## one unless first.
        pos <- which(ind)
        if(length(pos))
            lines[pos] <-
                sprintf("%s<li>%s",
                        c("", rep.int("</li>", length(pos) - 1L)),
                        substring(lines[pos], 3L))
        ## Could also make this prettier by appending </li> to the lines
        ## before the ones starting with '* '.
        ## The last line always ends the last block.
        len <- length(lines)
        lines[len] <- paste(lines[len], "</li>", sep = "")
    }
    
    ## Make things look nicer: ensure gray bullets as well.
    lines <-
        sub("^<li>( *(.*)\\.\\.\\. OK)</li>",
            "<li class=\"gray\"><span class=\"gray\">\\1</span></li>",
            lines)

    ## Header.
    writeLines(c("<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">",
                 "<html xmlns=\"http://www.w3.org/1999/xhtml\">",
                 "<head>",
                 sprintf("<title>Check results for '%s'</title>",
                         sub("-00check.(log|txt)$", "", basename(log))),
                 "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\"/>",
                 "<link rel=\"stylesheet\" type=\"text/css\" href=\"../R_check_log.css\"/>",
                 "</head>",
                 "<body>"),
               out)
    ## Body.
    if(!length(lines))
        writeLines("check results unavailable", out)
    else
        writeLines(c("<ul>", lines, "</ul>"), out)
    ## Footer.
    writeLines(c("</body>",
                 "</html>"),
               out)
}

check_results_diff_db <-
function(dir, files = NULL)
{
    if(is.null(files)) {
        ## Assume that both check.csv.prev and check.csv exist in dir.
        files <- file.path(dir, c("check.csv.prev", "check.csv"))
    }
    x <- read.csv(files[1L], colClasses = "character")
    x <- x[names(x) != "Maintainer"]
    y <- read.csv(files[2L], colClasses = "character")
    y <- y[names(y) != "Maintainer"]
    z <- merge(x, y, by = 1, all = TRUE)
    row.names(z) <- z$Package
    z
}

check_results_diffs <-
function(dir, files = NULL)
{
    db <- check_results_diff_db(dir, files)
    db <- db[, c("Version.x", "Status.x", "Version.y", "Status.y")]
    ## Show packages with one status missing (removed or added) as
    ## status change only.
    is_na_x <- is.na(db$Status.x)
    is_na_y <- is.na(db$Status.y)
    isc <- (is_na_x | is_na_y | (db$Status.x != db$Status.y))
                                        # Status change.
    ivc <- (!is_na_x & !is_na_y & (db$Version.x != db$Version.y))
                                        # Version change.
    names(db) <- c("V_Old", "S_Old", "V_New", "S_New")
    db <- cbind("S" = ifelse(isc, "*", ""),
                "V" = ifelse(ivc, "*", ""),
                db)
    db[c(which(isc & !ivc), which(isc & ivc), which(!isc & ivc)),
       c("S", "V", "S_Old", "S_New", "V_Old", "V_New")]
}

write_check_summary_diffs_to_con <-
function(dir, con = stdout())
{
    files <- c("summary.csv.prev", "summary.csv")
    db <- check_results_diffs(files = file.path(dir, files))
    lines <-
        c("Changes in check status (S) and/or version (V)",
          do.call(sprintf,
                  c(list("using R %s.%s (%s-%s-%s r%s):"),
                    R.version[c("major", "minor", "year",
                                "month", "day", "svn rev")])),
          "",
          do.call(paste,
                  c(list(format(c("", rownames(db)),
                                justify = "left")),
                    lapply(Map(c,
                               names(db),
                               lapply(db,
                                      function(e) {
                                          e <- as.character(e)
                                          e[is.na(e)] <- "<NA>"
                                          e
                                      })),
                           format,
                           justify = "right"))))
    writeLines(lines, con)
}

filter_results_by_status <-
function(results, status)
{
    status <- match.arg(status, c("ERROR", "WARN", "NOTE", "OK"))
    ind <- logical(NROW(results))
    flavors <- intersect(names(results), row.names(check_flavors_db))
    for(flavor in grep("linux", flavors, value = TRUE))
        ind <- ind | grepl(status, results[[flavor]])
    results[ind, ]
}

find_diffs_in_results <-
function(results, pos = c("r-devel-linux-ix86", "r-patched-linux-ix86"))
{
    ## Compare linux ix86 between versions.
    if(is.numeric(pos))
        pos <- names(results)[pos]
    results <- results[, c("Package", "Version", pos)]
    results[results[[3L]] != results[[4L]], ]
}

available_packages_in_local_repositories <-
function(dir)
{
    ## <NOTE>
    ## In R < 2.10.0, utils::available.packages() always filtered
    ## according to OS_type, with no way to turn this off.  R 2.10.0 has
    ## added a 'filters' argument, but we need a different duplicates
    ## filter (the ones with the highest available version only if not
    ## in CRAN), so we do things ourselves: alternatively, we could use
    ##    available <-
    ##      available.packages(curls, fields = fields,
    ##                         filters = "R_version")
    ## and then filter duplicates as needed.
    ## </NOTE>
    
    ## Set up repository info.
    ## <FIXME>
    ## Maybe add variables
    ##   Bioconductor_repository_dir
    ##   Omegahat_repository_dir
    ## eventually ...
    ## </FIXME>

    R_version <- getRversion()
    
    ## Try to infer the "right" BioC repository ...
    BioC_version <-
        if((getRversion() >= "2.10.0" &&
            exists(".BioC_version_associated_with_R_version",
                   envir = asNamespace("tools")))) {
            tools:::.BioC_version_associated_with_R_version
        } else {
            basename(dirname(grep("bioc$",
                                  scan(file.path(R.home("etc"),
                                                 "repositories"),
                                       character(),
                                       comment.char = "#",
                                       quiet = TRUE),
                                  value = TRUE)))
        }
    cdirs <-
        sprintf("/srv/R/Repositories/Bioconductor/%s/%s/src/contrib",
                BioC_version,
                c("bioc", "data/annotation", "data/experiment"))

    cdirs <- c(cdirs, "/srv/R/Repositories/Omegahat/src/contrib")
    
    ## Build db of available packages.
    ## Note that we can assume that version specific subdirectories of
    ## CRAN have already been expanded as needed.
    cdirs <- c(dir, cdirs)
    cdirs <- cdirs[file.exists(file.path(cdirs, "PACKAGES"))]
    curls <- sprintf("file://%s", cdirs)
    ## R 2.10.0 has added LinkingTo and License in the standard db ...
    fields <- unique(c(tools:::.get_standard_repository_db_fields(),
                       "LinkingTo", "License"))
    available <-
        mapply(cbind,
               lapply(file.path(cdirs, "PACKAGES"), read.dcf, fields),
               Repository = curls)
    available <- do.call("rbind", available)
    rownames(available) <- available[, "Package"]
    ## See above for not using utils::available.packages() with
    ## R_version filtering.
    .check_R_version <- function(x) {
        if(is.na(depends <- x["Depends"])) return(TRUE)
        depends <- tools:::.split_dependencies(depends)
        for(entry in depends[names(depends) == "R"]) {
            if(length(entry) > 1L
               && !(get(entry$op)(R_version, entry$version)))
                return(FALSE)
        }
        TRUE
    }
    available <-
        available[apply(available, 1L, .check_R_version), ,
                  drop = FALSE]

    ## Now this may have duplicated entries.
    ## We defininitely want all packages from CRAN.
    ## Otherwise, in case of duplication, we want the ones with the
    ## highest available version.
    package <- available[, "Package"]
    pos <- split(seq_along(package), package)
    pos <- pos[sapply(pos, length) > 1L]
    if(length(pos)) {
        bad <- lapply(pos, 
                      function(i) {
                          ## Determine the indices to drop.
                          ind <- available[i, "Repository"] == curls[1L]
                          keep <- if(any(ind))
                              which(ind)[1L]
                          else {
                              version <-
                                  package_version(available[i, "Version"])
                              which(version == max(version))[1L]
                          }
                          i[-keep]
                      })
        available <- available[- unlist(bad), ]
    }

    available
}

find_install_order <-
function(packages, dir, available = NULL, force_OS_type = TRUE)
{
    dir <- file_path_as_absolute(dir)
    
    if(is.null(available))
        available <- available_packages_in_local_repositories(dir)

    ## We know we cannot fully install packages with a different OS type
    ## than the current one (but do not enforce this for fake installs).
    if(force_OS_type) {
        pos <- which(!is.na(os_type <- available[, "OS_type"])
                     & (os_type != .Platform$OS.type))
        if(length(pos))
            available <- available[-pos, , drop = FALSE]
    }

    ## Now try to determine all packages which must be installed in
    ## order to be able to install the given packages to be installed.
    ## Try the following.
    ## For given packages, look at the available ones.
    ## For these, compute all dependencies (including the packages
    ## "only" suggested).
    ## Keep the available ones, and compute their dependencies.
    ## Repeat until convergence.
    p0 <- unique(packages[packages %in% available[, "Package"]])
    p1 <- unlist(utils:::.make_dependency_list(p0, available,
                                              c("Depends", "Imports",
                                                "LinkingTo", "Suggests")))
    repeat {
        p1 <- unique(c(p0, p1[p1 %in% available[, "Package"]]))
        if(length(p1) == length(p0)) break
        p0 <- p1
        p1 <- unlist(utils:::.make_dependency_list(p0, available))
    }
    ## And determine an install order from these.
    DL <- utils:::.make_dependency_list(p0, available)
    out <- utils:::.find_install_order(p0, DL)

    ## Packages which should be installed but are not in the install
    ## order are trouble.
    bad <- packages[! packages %in% out]

    ## Now check where to install from.
    ## For writing out the installation list:
    ## The ones available locally we can install by their name.
    ## The ones not must be path plus package_version.tar.gz
    ind <- available[out, "Repository"] != sprintf("file://%s", dir)
    if(any(ind)) {
        tmp <- out[ind]
        out[ind] <-
            sprintf("%s/%s_%s.tar.gz",
                    sub("file://", "", available[tmp, "Repository"]),
                    available[tmp, "Package"],
                    available[tmp, "Version"])
    }
                            
    list(out = out, bad = bad)
}

analyze_check_log_file <-
function(con, drop_ok = TRUE)
{
    ## Just making sure ...
    lc_ctype <- Sys.getlocale("LC_CTYPE")
    Sys.setlocale("LC_CTYPE", "en_US.UTF-8")
    on.exit(Sys.setlocale("LC_CTYPE", lc_ctype))

    make_results <- function(package, version, flags, chunks)
        list(Package = package, Version = version,
             Flags = flags, Chunks = chunks)

    drop_ok_status_tags <- c("OK", "NONE", "SKIPPED")

    ## Start by reading in.
    lines <- readLines(con, warn = FALSE)

    ## If there are invalid lines, try recoding from the session charset
    ## employed (actually, this could be simplified as we know the
    ## locales employed for checking).
    if(any(ind <- is.na(nchar(lines, allowNA = TRUE)))) {
        re <- "^\\* using session charset: "
        pos <- grep(re, lines[!ind])
        if(length(pos)) {
            scs <- sub(re, "", lines[!ind][pos])
            rlines <- iconv(lines[ind], scs, "")
            bad <- is.na(nchar(rlines, allowNA = TRUE)) | is.na(rlines)
            lines[ind][!bad] <- rlines[!bad]
            ind[!bad] <- FALSE
        }
        if(any(ind))
            lines[ind] <-  iconv(lines[ind], "", "", sub = "byte")
        ## In case we still have NA lines, let us drop them.
        ## (But would we really have such?)
        if(any(bad <- is.na(lines))) {
            message(sprintf("Dropping invalid line in %s", con))
            lines <- lines[!bad]
        }
    }

    ## Get header.
    re <- "^\\* this is package ['‘](.*)['’] version ['‘](.*)['’]$"
    pos <- grep(re, lines)
    if(length(pos)) {
        txt <- lines[pos]
        package <- sub(re, "\\1", txt)
        version <- sub(re, "\\2", txt)
        lines <- lines[-seq_len(pos)]
    } else return()

    ## Get footer.
    ## MacOSX checks should always have last line
    ##   * elapsed time ......
    len <- length(lines)
    if(grepl("^\\* elapsed time ", lines[len])) {
        lines <- lines[-len]
        len <- len - 1L
    }
    ## <FIXME>
    ## KH UL SU use
    ##   * using check arguments ......
    ## lines in case of special check arguments.
    ## But 2.10 or better reports these explicitly ...
    if(length(pos <- grep("^\\* using options? ['‘].*['’]$", lines))) {
        pos <- pos[1L]
        flags <- sub("^\\* using options? ['‘](.*)['’]$", "\\1", lines[pos])
        lines <- lines[-pos]
    } else {
        flags <- ""
    }
    ## else {
    ##     txt <- lines[len]
    ##     flags <- if(grepl("^\\* using check arguments '.*'", txt)) {
    ##         lines <- lines[-len]
    ##         sub("^\\* using check arguments '(.*)'$", "\\1", txt)
    ##     } else ""
    ## }
    ## </FIXME>

    analyze_lines <- function(lines) {
        ## We might still have
        ##   * package encoding:
        ## entries for packages declaring a package encoding.
        ## Hopefully all other log entries we still have are
        ##   * checking
        ##   * creating
        ## ones.
        ## So let's drop everything up to the first such entry.
        re <- "^\\*\\*? ((checking|creating) .*) \\.\\.\\.( (\\[[^ ]*\\]))? (.*)$"
        ind <- grepl(re, lines)
        csi <- cumsum(ind)
        ind <- (csi > 0)
        chunks <- 
            lapply(split(lines[ind], csi[ind]),
                   function(s) {
                       ## Note that setting
                       ##   _R_CHECK_TEST_TIMING_=yes
                       ##   _R_CHECK_VIGNETTE_TIMING_=yes
                       ## will result in a different chunk format ...
                       line <- s[1L]
                       list(check = sub(re, "\\1", line),
                            status = sub(re, "\\5", line),
                            output = paste(s[-1L], collapse = "\n"))
                   })

        status <- vapply(chunks, `[[`, "", "status")
        if(identical(drop_ok, TRUE) ||
           (is.na(drop_ok) && all(status != "ERROR")))
            chunks <- chunks[is.na(match(status, drop_ok_status_tags))]
        
        chunks
    }

    chunks <- analyze_lines(lines)
    if(!length(chunks) && is.na(drop_ok)) {
        chunks <- list(list(check = "*", status = "OK", output = ""))
    }

    make_results(package, version, flags, chunks)
}

check_details_db <-
function(dir = "/data/rsync/R.check", flavors = NA_character_,
         drop_ok = TRUE)
{
    ## Build a data frame with columns
    ##   Package Version Flavor Check Status Output Flags
    ## and some optimizations (in particular, Check Status Flags can be
    ## factors).

    db_from_logs <- function(logs, flavor) {
        out <- lapply(logs, analyze_check_log_file, drop_ok)
        out <- out[sapply(out, length) > 0L]
        if(!length(out)) return(NULL)
        chunks <- lapply(out, `[[`, "Chunks")
        package <- sapply(out, `[[`, "Package")
        lens <- sapply(chunks, length)
        cbind(rep.int(package, lens),
              rep.int(sapply(out, `[[`, "Version"), lens),
              flavor,
              matrix(unlist(chunks), ncol = 3L,
                     byrow = TRUE),
              rep.int(sapply(out, `[[`, "Flags"),
                      lens))
    }

    if(identical(flavors, NA_character_)) {
        logs <- Sys.glob(file.path(dir, "*.Rcheck", "00check.log"))
        db <- db_from_logs(logs, NA_character_)
    } else {
        db <- NULL
        if(is.null(flavors))
            flavors <- row.names(check_flavors_db)
        flavors <- flavors[file.exists(file.path(dir, flavors))]
        for(flavor in flavors) {
            if(interactive())
                message(sprintf("Getting check details for flavor %s",
                                flavor))
            logs <- Sys.glob(file.path(dir, flavor, "PKGS", "*",
                                       "00check.log"))
            db <- rbind(db, db_from_logs(logs, flavor))
        }
    }
    colnames(db) <- c("Package", "Version", "Flavor", "Check", "Status",
                      "Output", "Flags")
    ## Now some cleanups.
    checks <- db[, "Check"]
    checks <- sub("checking whether package ['‘].*['’] can be installed",
                  "checking whether package can be installed", checks)
    checks <- sub("creating .*-Ex.R",
                  "checking examples creation", checks)
    checks <- sub("creating .*-manual\\.tex",
                  "checking manual creation", checks)
    checks <- sub("checking .*-manual\\.tex", "checking manual", checks)
    checks <- sub("checking package vignettes in ['‘]inst/doc['’]",
                  "checking package vignettes", checks)
    checks <- sub("^checking *", "", checks)
    db[, "Check"] <- checks
    ## In fact, for tabulation purposes it would even be more convenient
    ## to shorten the check names ...
    
    db <- as.data.frame(db, stringsAsFactors = FALSE)
    db$Check <- as.factor(db$Check)
    db$Status <- as.factor(db$Status)

    db
}

inspect_check_details_db <-
function(db, con = stdout()) {
    flags <- db$Flags
    flavor <- db$Flavor
    if(is.null(flavor))
        flavor <- NA_character_
    out <- cbind(sprintf("Package: %s Version: %s%s",
                         db$Package, db$Version,
                         ifelse(is.na(flavor), "",
                                sprintf(" Flavor: %s", flavor))),
                 ifelse(nzchar(flags),
                        sprintf("Flags: %s\n", flags),
                        ""),
                 sprintf("Check: %s ... %s", db$Check, db$Status),
                 c(db$Output))
    cat(t(out), sep = c("\n", "", "\n", "\n\n"), file = con)
}

write_check_details_db_as_HTML <-
function(details, dir)
{
    for(flavor in unique(details$Flavor)) {
        out <- file.path(dir, sprintf("check_details_%s.html", flavor))
        write_check_details_for_flavor_as_HTML(details, flavor, out)
    }
}

write_check_details_for_flavor_as_HTML <-
function(details, flavor, con = stdout())
{
    tab <- table(subset(details,
                        Flavor == flavor,
                        c("Check", "Status")))
    ## Drop empty rows.
    tab <- tab[rowSums(tab) > 0, ]
    ## And add totals.
    tab <- rbind(tab, Total = colSums(tab))

    writeLines(c("<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">",
                 "<html xmlns=\"http://www.w3.org/1999/xhtml\">",
                 "<head>",
                 "<title>CRAN Package Check Details</title>",
                 "<link rel=\"stylesheet\" type=\"text/css\" href=\"../CRAN_web.css\"/>",
                 if(any(Encoding(rownames(tab)) == "UTF-8"))
                 "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\"/>",
                 "</head>",
                 "<body lang=\"en\">",
                 sprintf("<h2>CRAN Package Check Problem Summary for %s</h2>",
                         flavor),
                 "<p>",
                 sprintf("Last updated on %s.", format(Sys.time())),
                 "</p>",
                 "<p>",
                 sprintf("Check problems summary by check and status for %s on a system running %s (CPU: %s).",
                         check_flavors_db[flavor, "Flavor"],
                         check_flavors_db[flavor, "OS_kind"],
                         check_flavors_db[flavor, "CPU_info"]),
                 "</p>",                 
                 check_details_html_summary(tab),
                 "</body>",
                 "</html>"),
               con)
}

check_details_html_summary <-
function(tab)
{
    fmt <- paste("<tr>",
                 "<td> %s </td>", 
                 "<td align=\"right\"> %s </td>",
                 "<td align=\"right\"> %s </td>",
                 "<td align=\"right\"> %s </td>",
                 "</tr>")
    c("<table border=\"1\" summary=\"CRAN check details summary.\">",
      paste("<tr>",
            "<th> Check </th>",
            "<th> ERROR </th>",
            "<th> WARNING </th>",
            "<th> NOTE </th>",
            "</tr>"),
      sprintf(fmt, rownames(tab),
              tab[, "ERROR"], tab[, "WARNING"], tab[, "NOTE"]),
      "</table>"
      )
}

check_details_diff_db <-
function(dir, files = NULL)
{
    if(is.null(files)) {
        files <- file.path(dir, c("details.csv.prev", "details.csv"))
    }
    x <- read.csv(files[1L], colClasses = "character")
    y <- read.csv(files[2L], colClasses = "character")
    z <- merge(x, y, by = c("Package", "Check"), all = TRUE)
    names(z) <-
        c("Package", "Check", "V_old", "S_old", "V_new", "S_new")
    row.names(z) <- NULL
    z
}

check_details_diffs <-
function(dir, files = NULL)
{
    db <- check_details_diff_db(dir, files)

    ## Cosmetics.
    db$S_old[!is.na(s <- db$S_old) & (s == "WARNING")] <- "WARN"
    db$S_new[!is.na(s <- db$S_new) & (s == "WARNING")] <- "WARN"

    ## Split into package chunks, and process.
    chunks <- 
        lapply(split(db, db$Package),
               function(e) {
                   len <- nrow(e)
                   ## Complete missing entries.
                   ## If one check failed, we have the status of all
                   ## other checks that were run as well.
                   if(length(pos <- which(!is.na(e$V_old))))
                       e$V_old <- rep.int(e[pos[1L], "V_old"], len)
                   if(any(ind <- !is.na(e$S_old)) &&
                      (all(e$S_old[ind] != "ERROR")))
                       e$S_old[!ind] <- "OK"
                   if(length(pos <- which(!is.na(e$V_new))))
                       e$V_new <- rep.int(e[pos[1L], "V_new"], len)
                   if(any(ind <- !is.na(e$S_new)) &&
                      (all(e$S_new[ind] != "ERROR")))
                       e$S_new[!ind] <- "OK"
                   e
               })

    ## Put back together, and drop all stubs, details for packages only
    ## checked in old, and entries with no change.
    ## For packages only checked in new, keep all non-OK details.
    db <- do.call(rbind, chunks)
    db[((db$Check != "*") &
        !is.na(db$S_new) &
        ((is.na(db$S_old) & (db$S_new != "OK")) |
         (!is.na(db$S_old) & (db$S_old != db$S_new)))), ]
}

write_check_details_diffs_to_con <-
function(dir, con = stdout(), flavor = NULL)
{
    db <- check_details_diffs(dir)
    db$S_old[is.na(db$S_old)] <- "<NA>"
    chunks <- 
        split(sprintf("  %-s: %s => %s", db$Check, db$S_old, db$S_new),
              sprintf("Package %s%s:",
                      db$Package,
                      ifelse(!is.na(db$V_old) & (db$V_old != db$V_new),
                             sprintf(" [V_old: %s, V_new: %s]",
                                     db$V_old, db$V_new),
                             "")))
    writeLines(paste(sapply(Map(c,
                                names(chunks),
                                chunks,
                                if(!is.null(flavor))
                                sprintf("See <http://www.R-project.org/nosvn/R.check/%s/%s-00check.html>",
                                        flavor,
                                        sub("^Package ([^ :]+).*", "\\1",
                                            names(chunks)))
                                ),
                            paste,
                            collapse = "\n"),
                     collapse = "\n\n"),
               con)
}

get_run_time_test_timings_from_log_file <-
function(con)
{
    lines <- readLines(con, warn = FALSE)
    timings <- integer()
    for(check in
        c("examples",
          "running R code from vignettes",
          "re-building of vignette PDFs")) {
        re <- sprintf("^\\* checking %s \\.\\.\\. \\[(.*)\\].*", check)
        timings <-
            c(timings,
              if(length(ind <- grep(re, lines))) {
                  as.integer(sub("s$", "",
                                 unlist(strsplit(sub(re, "\\1", lines[ind]),
                                                 "/", fixed = TRUE))))
              } else {
                  rep.int(NA, 2L)
              })
    }
    timings
}

check_run_time_test_timings_db <-
function(dir = "/data/rsync/R.check",
         flavors = "r-devel-linux-x86_64-debian-clang")
{
    db <- NULL
    if(is.null(flavors))
        flavors <- row.names(check_flavors_db)
    flavors <- flavors[file.exists(file.path(dir, flavors))]
    
    for(flavor in flavors) {
        if(interactive())
            message(sprintf("Getting run time tests timings for flavor %s",
                            flavor))
        logs <- Sys.glob(file.path(dir, flavor, "PKGS", "*",
                                   "00check.log"))
        out <- lapply(logs, get_run_time_test_timings_from_log_file)
        db <- rbind(db,
                    data.frame(flavor,
                               sub("\\.Rcheck$", "",
                                   basename(dirname(logs))),
                               do.call(rbind, out),
                               stringsAsFactors = FALSE))
    }

    colnames(db) <- c("Flavor", "Package",
                      "Ex_T", "Ex_E", "VR_T", "VR_E", "VB_T", "VB_E")
    db
}

cache_check_results <-
function(dir, flavor)
{
    cpath <- file.path(dir, ".cache", flavor)
    if(!file_test("-d", cpath))
        dir.create(cpath,  recursive = TRUE)
    
    ## Get mtimes of check log files.
    files <-
        Sys.glob(file.path(dir, flavor, "PKGS", "*", "00check.log"))
    times <- file.info(files)$mtime
    t_max <- max(times)
    rds <- file.path(cpath, "t_all.rds")
    saveRDS(times, rds)
    Sys.setFileTime(rds, t_max)
    rds <- file.path(cpath, "t_max.rds")
    saveRDS(t_max, rds)
    Sys.setFileTime(rds, t_max)

    ## If necessary, update check results db.
    if(!file_test("-f", rds <- file.path(cpath, "results.rds")) ||
       t_max > file.info(rds)$mtime) {
        saveRDS(check_results_db(dir, flavor), rds)
    }

    ## If necessary, update check details db.
    if(!file_test("-f", rds <- file.path(cpath, "details.rds")) ||
       t_max > file.info(rds)$mtime) {
        saveRDS(check_details_db(dir, flavor), rds)
    }
}

.check_R_summary <-
function(cdir, wdir, tdir)
{
    flavors <- row.names(check_flavors_db)

    ## Update the cache.
    parallel::mcmapply(cache_check_results, cdir, flavors, mc.cores = 6L)

    ## Get the time stamps for each check flavor.
    files <- file.path(cdir, ".cache", flavors, "t_max.rds")
    timestamps <- do.call(c, lapply(files, readRDS))

    ## If there are no check results to update, update the flavors db
    ## material directly in tdir.

    mtime <- file.info(file.path(tdir, "index.html"))$mtime
    if(!is.na(mtime) && (max(timestamps) <= mtime)) {
        saveRDS(check_flavors_db,
                file = file.path(tdir, "check_flavors.rds"))
        out <- file.path(tdir, "check_flavors.html")
        write_check_flavors_db_as_HTML(out = out)
        unlink(wdir, recursive = TRUE)
    } else {
        saveRDS(check_flavors_db,
                file = file.path(wdir, "check_flavors.rds"))
        out <- file.path(wdir, "check_flavors.html")
        write_check_flavors_db_as_HTML(out = out)
        results <-
            lapply(file.path(cdir, ".cache", flavors, "results.rds"),
                   readRDS)
        results <- do.call(rbind, results)
        write_check_results_db_as_HTML(results, wdir)
        details <-
            lapply(file.path(cdir, ".cache", flavors, "details.rds"),
                   readRDS)
        details <- do.call(rbind, details)
        write_check_details_db_as_HTML(details, wdir)
    }
}
