require("tools", quiet = TRUE)

## <FIXME>
## Remove eventually ...
## if(!exists("file_path_sans_ext", "package:tools", inherits = FALSE))
##     file_path_sans_ext <- filePathSansExt
## if(!exists("file_test", "package:tools", inherits = FALSE))
##     file_test <- fileTest
## </FIXME>

check_log_URL <- "http://www.R-project.org/nosvn/R.check/"

check_summarize_flavor <-
function(dir = file.path("~", "tmp", "R.check"), flavor = "r-devel")
{
    if(!file_test("-d", file.path(dir, flavor, "PKGS"))) return()

    get_description_fields_as_utf8 <-
        function(dfile, fields = c("Version", "Priority", "Maintainer"))
    {
        lc_ctype <- Sys.getlocale("LC_CTYPE")
        Sys.setlocale("LC_CTYPE", "en_US.utf8")
        on.exit(Sys.setlocale("LC_CTYPE", lc_ctype))
        
        meta <- try(read.dcf(dfile,
                             fields = unique(c(fields, "Encoding")))[1, ])
        ## What if this fails?  Grr ...
        if(inherits(meta, "try-error"))
            return(rep.int("", length(fields)))
        else if(any(i <- !is.na(meta) & is.na(nchar(meta, "c")))) {
            ## Try converting to UTF-8.
            from <- meta["Encoding"]
            if(is.na(from)) from <- "latin1"
            meta[i] <- iconv(meta[i], from, "utf8")
        }
        meta[fields]
    }
    
    check_dirs <- list.files(path = file.path(dir, flavor, "PKGS"),
                             pattern = "\\.Rcheck", full = TRUE)
    results <- matrix(character(), nr = 0, nc = 6)
    fields <- c("Version", "Priority", "Maintainer")
    ## (Want Package, Version, Priority, Maintainer, Status, Comment.)
    for(check_dir in check_dirs) {
        dfile <- file.path(check_dir, "00package.dcf")
        ## <FIXME>
        ## Remove eventually ...
        if(!file.exists(dfile))
            dfile <- file.path(file_path_sans_ext(check_dir),
                               "DESCRIPTION")
        ## </FIXME>
        meta <- get_description_fields_as_utf8(dfile)
        log <- readLines(file.path(check_dir, "00check.log"))
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
            "[--install=fake]"
        else
            "[--install=no]"
        results <- rbind(results,
                         cbind(file_path_sans_ext(basename(check_dir)),
                               rbind(meta, deparse.level = 0),
                               status, comment))
    }
    colnames(results) <- c("Package", fields, flavor, "Comment")
    idx <- which(results[, flavor] %in% c("ERROR", "WARN"))
    if(any(idx))
        results[idx, flavor] <-
            paste("<a href=\"", check_log_URL, flavor, "/",
                  results[idx, "Package"], "-00check.txt\">",
                  results[idx, flavor], "</a>",
                  sep = "")

    .saveRDS(results, file.path(dir, flavor, "summary.rds"))
    results
}
             
check_summary <-
function(dir = file.path("~", "tmp", "R.check"))
{
    R_flavors <- c("r-devel", "r-patched", "r-release")
    R_flavors <- R_flavors[file.exists(file.path(dir, R_flavors))]

    results <- vector("list", length(R_flavors))
    names(results) <- R_flavors
    for(flavor in R_flavors) {
        summary_files <-
            c(file.path(dir, flavor, "summary.rds"),
              file.path(dir, flavor, "summary.rds.prev"))
        summary_files <- summary_files[file.exists(summary_files)]
        results[[flavor]] <- if(length(summary_files))
            .readRDS(summary_files[1])
        else
            check_summarize_flavor(dir, flavor)
    }

    ## Now merge results.
    idx <- which(sapply(results, NROW) > 0)
    if(!any(idx)) return()
    summary <- data.frame(results[[idx[1]]])
    for(i in seq(along = R_flavors)[-idx[1]]) {
        new <- data.frame(results[[i]])
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
    }))
    for(flavor in R_flavors) {
        idx <- which(!is.na(match(names(summary),
                                  sub("-", ".", flavor))))
        names(summary)[idx] <- flavor
    }
    summary <- summary[c("Package", "Version", "Priority",
                         "Maintainer", R_flavors, "Comment")]
    summary[order(summary$Package), ]
}

write_check_summary_as_HTML <-
function(summary, file = file.path("~", "tmp", "checkSummary.html"))
{
    if(is.null(summary)) return()
    library("xtable")
    out <- file(file, "w")
    writeLines(c("<html lang=\"en\"><head>",
                 "<title>CRAN Daily Package Check</title>",
                 "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf8\">",
                 
                 "</head>",
                 "<body>",
                 "<h1>CRAN Daily Package Check Results</h1>",
                 "<p>",
                 paste("Last updated on", format(Sys.time())),
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
    writeLines(c("</body>", "</html>"), out)
    close(out)
}

check_timings <-
function(dir = file.path("~", "tmp", "R.check"), flavor = "r-devel",
         file = "time_c.out")
{
    timings_files <- file.path(dir, flavor,
                               c(file, paste(file, "prev", sep = ".")))
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

write_check_timings_as_HTML <-
function(timings, file = file.path("~", "tmp", "checkTimings.html"))
{
    if(is.null(timings)) return()
    library("xtable")
    out <- file(file, "w")
    writeLines(c("<html><head>",
                 "<title>CRAN Daily Package Check</title>",
                 "</head>",
                 "<body>",
                 "<h1>CRAN Daily Package Check Timings</h1>",
                 "<p>",
                 paste("Last updated on", format(Sys.time())),
                 "<p>",
		 paste("Timings for running <tt>R CMD check</tt>",
		       "from the current development version of R",
		       "on <em>installed</em> packages."),
		 "<p>",
		 paste("Total CPU seconds: ", sum(timings$Total),
		       " (", round(sum(timings$Total) / 3600, 2),
		       " hours)", sep = ""),
		 "<p>"),
               out)
    print(xtable(timings), type = "html", file = out, append = TRUE)
    writeLines(c("</body>", "</html>"), out)
    close(out)
}
