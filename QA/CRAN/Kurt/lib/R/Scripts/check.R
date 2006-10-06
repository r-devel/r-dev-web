require("tools", quiet = TRUE)

check_log_URL <- "http://www.R-project.org/nosvn/R.check/"

check_summarize_flavor <-
function(dir = file.path("~", "tmp", "R.check"), flavor = "r-devel",
         check_dirs_root = file.path(dir, flavor, "PKGS"))
{
    if(!file_test("-d", check_dirs_root)) return()

    get_description_fields_as_utf8 <-
        function(dfile, fields = c("Version", "Priority", "Maintainer"))
    {
        lc_ctype <- Sys.getlocale("LC_CTYPE")
        Sys.setlocale("LC_CTYPE", "en_US.utf8")
        on.exit(Sys.setlocale("LC_CTYPE", lc_ctype))

        meta <- if(file.exists(dfile))
            try(read.dcf(dfile,
                         fields = unique(c(fields, "Encoding")))[1, ],
                silent = TRUE)
        else
            NULL
        ## What if this fails?  Grr ...
        if(inherits(meta, "try-error") || is.null(meta))
            return(rep.int("", length(fields)))
        else if(any(i <- !is.na(meta) & is.na(nchar(meta, "c")))) {
            ## Try converting to UTF-8.
            from <- meta["Encoding"]
            if(is.na(from)) from <- "latin1"
            meta[i] <- iconv(meta[i], from, "utf8")
        }
        meta[fields]
    }
    
    check_dirs <- list.files(path = check_dirs_root,
                             pattern = "\\.Rcheck", full = TRUE)
    results <- matrix(character(), nr = 0, nc = 5)
    fields <- c("Version", "Priority", "Maintainer")
    ## (Want Package, Version, Priority, Maintainer, Status.)
    for(check_dir in check_dirs) {
        dfile <- file.path(check_dir, "00package.dcf")
        ## <FIXME>
        ## Remove eventually ...
        if(!file.exists(dfile))
            dfile <- file.path(file_path_sans_ext(check_dir),
                               "DESCRIPTION")
        ## </FIXME>
        meta <- get_description_fields_as_utf8(dfile)
        logfile <- file.path(check_dir, "00check.log")
        if(!file.exists(logfile))
            next
        log <- readLines(logfile)
        status <- if(any(grep("ERROR$", log)))
            "ERROR"
        else if(any(grep("WARNING$", log)))
            "WARN"
        else
            "OK"
        comment <- if(any(grep("^\\*+ checking examples ", log))
                      || (status == "ERROR"))
            ""
        else if(any(grep("^\\*+ checking.*can be installed ", log)))
            " [*]"
        else
            " [**]"
        status <- paste(status, comment, sep = "")
        results <- rbind(results,
                         cbind(file_path_sans_ext(basename(check_dir)),
                               rbind(meta, deparse.level = 0),
                               status))
    }
    colnames(results) <- c("Package", fields, "Status")
    idx <- grep("^(WARN|ERROR)", results[, "Status"])
    if(any(idx))
        results[idx, "Status"] <-
            paste("<a href=\"", check_log_URL, flavor, "/",
                  results[idx, "Package"], "-00check.txt\">",
                  results[idx, "Status"], "</a>",
                  sep = "")

    ## .saveRDS(results, file.path(dir, flavor, "summary.rds"))
    results
}
             
check_summary <-
function(dir = file.path("~", "tmp", "R.check"), R_flavors = NULL)
{
    if(is.null(R_flavors)) {
        ## Our current defaults:
        ## R_flavors <- c("r-devel", "r-patched", "rosuda", "r-release")
        ## R_flavors <- c("r-devel", "rosuda", "r-release")
        R_flavors <- c("r-devel-linux-ix86",
                       "r-devel-linux-x86_64",
                       "r-patched-linux-ix86",
                       "r-release-linux-ix86",
                       "r-release-macosx-ix86")
    }
    R_flavors <- R_flavors[file.exists(file.path(dir, R_flavors))]

    results <- vector("list", length(R_flavors))
    names(results) <- R_flavors
    for(flavor in R_flavors) {
        ## <FIXME>
        ## For the time being, always rebuild ...
##         summary_files <-
##             c(file.path(dir, flavor, "summary.rds"),
##               file.path(dir, flavor, "summary.rds.prev"))
##         summary_files <- summary_files[file.exists(summary_files)]
##         results[[flavor]] <- if(length(summary_files))
##             .readRDS(summary_files[1])
##         else
##             check_summarize_flavor(dir, flavor)
        results[[flavor]] <- check_summarize_flavor(dir, flavor)
        ind <- which(colnames(results[[flavor]]) == "Status")
        if(length(ind))
            colnames(results[[flavor]])[ind] <- flavor
    }

    ## Now merge results.
    idx <- which(sapply(results, NROW) > 0)
    if(!any(idx)) return()
    ## <FIXME>
    ## Use stringsAsFactors once 2.4.0 is out ...
    summary <- data.frame(results[[idx[1]]], check.names = FALSE)
    summary <- lapply(summary, as.character)
    for(i in seq(along = R_flavors)[-idx[1]]) {
        new <- data.frame(results[[i]], check.names = FALSE)
        new <- lapply(new, as.character)
	if(NROW(new))
            summary <- merge(summary, new, all = TRUE)
	else {
	    summary <- cbind(summary, rep.int("", NROW(summary)))
	    names(summary)[NCOL(summary)] <- R_flavors[i]
	}
    }
    summary <- data.frame(lapply(summary, function(x) {
        x <- as.character(x)
        x[is.na(x)] <- ""
        x
    }),
                          check.names = FALSE)
    ## </FIXME>
    ## <FIXME>
    ## Most likely this is no longer needed when using
    ## data.frame(check.names = FALSE).
    ## It is, because merge() does name mangling ...
    for(flavor in R_flavors) {
        idx <- which(!is.na(match(names(summary), make.names(flavor))))
        names(summary)[idx] <- flavor
    }
    ## </FIXME>
    summary <- summary[c("Package", "Version", "Priority",
                         R_flavors, "Maintainer")]
    summary[order(summary$Package), ]
}

write_check_summary_as_HTML <-
function(summary, file = file.path("~", "tmp", "checkSummary.html"))
{
    if(is.null(summary)) return()
    ## <NOTE>
    ## Adjust as needed ...
    ## In particular for prerelease stages ...
    if(any(ind <- names(summary) == "r-devel-linux-ix86"))
        names(summary)[ind] <- "r-devel\nLinux\nix86"
    if(any(ind <- names(summary) == "r-devel-linux-x86_64"))
        names(summary)[ind] <- "r-devel\nLinux\nx86_64"
    if(any(ind <- names(summary) == "r-patched-linux-ix86"))
        names(summary)[ind] <- "r-patched\nLinux\nix86"
    if(any(ind <- names(summary) == "r-release-linux-ix86"))
        names(summary)[ind] <- "r-release\nLinux\nix86"
    if(any(ind <- names(summary) == "r-release-macosx-ix86"))
        names(summary)[ind] <- "r-release\nMacOSX\nix86"
    ## </NOTE>
    library("xtable")
    out <- file(file, "w")
    writeLines(c("<html lang=\"en\"><head>",
                 "<title>CRAN Daily Package Check</title>",
                 "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf8\">",
                 
                 "</head>",
                 "<body lang=\"en\">",
                 "<h1>CRAN Daily Package Check Results</h1>",
                 "<p>",
                 paste("Last updated on", format(Sys.time())),
                 "<p>",
                 "Results for installing and checking packages",
                 "using the three current flavors of R",
                 "on systems running Debian GNU/Linux testing",
                 "(r-devel ix86: AMD Athlon(tm) XP 2400+ (2GHz),",
                 "r-devel x86_64: Dual Core AMD Opteron(tm) Processor 280,",
                 ## <FIXME>
                 "r-patched/r-release:",
                 ## "r-prerelease/r-release:",
                 ## </FIXME>
                 "Intel(R) Pentium(R) 4 CPU 2.66GHz),",
                 "and MacOS X 10.4.7 (iMac, Intel Core Duo 1.83GHz).",
                 "<p>"),
               out)
    ## Older versions of package xtable needed post-processing as
    ## suggested by Uwe Ligges, reducing checkSummary.html from 370 kB
    ## to 120 kB ...
    ##    lines <- capture.output(print(xtable(summary), type = "html"),
    ##                            file = NULL)
    ##    lines <- gsub("  *", " ", lines)
    ##    lines <- gsub(" align=\"left\"", "", lines)
    ##    writeLines(lines, out)
    ## (Oh no, why does print.xtable() want to write to a *file*?)
    ## Seems that this is no longer necessary in 1.2.995 or better, so
    ## let's revert to the original code.
    print(xtable(summary), type = "html", file = out, append = TRUE)
    writeLines(c("<p>",
                 "Results with [*] or [**] were obtained by checking",
                 "with <CODE>--install=fake</CODE>",
                 "and <CODE>--install=no</CODE>, respectively.",
                 "</body>",
                 "</html>"),
               out)
    close(out)
}

get_timings_from_timings_files <-
function(tfile)
{
    timings_files <- c(tfile, paste(tfile, "prev", sep = "."))
    timings_files <- timings_files[file.exists(timings_files)]
    if(!length(timings_files)) return()
    x <- paste(readLines(timings_files[1]), collapse = "\n")
    ## Safeguard against possibly incomplete entries.
    x <- sub("(.*swaps(\n|$))*.*", "\\1", x)
    x <- paste(unlist(strsplit(x, "swaps(\n|$)")), "swaps", sep = "")
    ## Eliminate 'Command exited with non-zero ...'
    bad <- rep("OK", length(x))
    bad[grep(": Command exited[^\n]*\n", x)] <- "ERROR"
    x <- sub(": Command exited[^\n]*\n", ": ", x)
    x <- sub("([0-9])system .*", "\\1", x)
    x <- sub("([0-9])user ", "\\1 ", x)
    x <- sub(": ", " ", x)
    x <- read.table(textConnection(c("User System", x)))
    x <- cbind(Total = rowSums(x), x, Status = bad)
    x <- x[order(x$Total, decreasing = TRUE), ]
    x
}

check_timings <-
function(dir = file.path("~", "tmp", "R.check"),
##         flavor = "r-devel")
         flavor = "r-devel-linux-ix86")
{
    t_c <- get_timings_from_timings_files(file.path(dir, flavor,
                                                    "time_c.out"))
    t_i <- get_timings_from_timings_files(file.path(dir, flavor,
                                                    "time_i.out"))
    if(is.null(t_i) || is.null(t_c)) return()
    db <- merge(t_c[c("Total", "Status")], t_i["Total"],
                by = 0, all = TRUE)
    db$Total <- rowSums(db[, c("Total.x", "Total.y")], na.rm = TRUE)
    out <- db[, c("Total", "Total.x", "Total.y", "Status")]
    names(out) <- c("Total", "Check", "Install", "Status")
    rownames(out) <- db$Row.names    
    ## Add information on check mode.  If possible, use the summary.
    summary_files <- file.path(dir, flavor,
                               c("summary.rds", "summary.rds.prev"))
    summary_files <- summary_files[file.exists(summary_files)]
    if(length(summary_files)) {
        s <- .readRDS(summary_files[1])
        s <- as.data.frame(s[, -1], row.names = s[, 1])
        ## Need to recreate comments about install/check type.
        comment <- rep.int("", nrow(s))
        comment[grep("\\[\\*\\]", s$Status)] <- "[--install=fake]"
        comment[grep("\\[\\*\\*\\]", s$Status)] <- "[--install=no]"
        out <- merge(out,
                     data.frame(Comment = comment,
                                row.names = row.names(s)),
                     by = 0)
        rownames(out) <- out$Row.names
        out$Row.names <- NULL
    } else {
        comment <- ifelse(is.na(out$Install), "[--install=no]", "")
        out <- cbind(out, Comment = comment)
    }
    out[order(out$Total, decreasing = TRUE), ]
}

write_check_timings_as_HTML <-
function(db, file = file.path("~", "tmp", "checkTimings.html"))
{
    if(is.null(db)) return()
    library("xtable")
    out <- file(file, "w")
    writeLines(c("<html><head>",
                 "<title>CRAN Daily Package Check Timings</title>",
                 "</head>",
                 "<body lang=\"en\">",
                 "<h1>CRAN Daily Package Check Timings</h1>",
                 "<p>",
                 paste("Last updated on", format(Sys.time())),
                 "<p>",
                 paste("Timings for installing and checking packages",
                       "using the current development version of R",
                       "on an AMD Athlon(tm) XP 2400+ (2GHz) system",
                       "running Debian GNU/Linux testing."),
                 "<p>",
                 paste("Total CPU seconds: ", sum(db$Total),
                       " (", round(sum(db$Total) / 3600, 2),
                       " hours)", sep = ""),
                 "<p>"),
               out)
    print(xtable(db), type = "html", file = out, append = TRUE)
    writeLines(c("</body>", "</html>"), out)
    close(out)
}

