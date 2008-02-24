require("tools", quietly = TRUE)

check_log_URL <- "http://www.R-project.org/nosvn/R.check/"

r_patched_is_prelease <- FALSE
r_p_o_p <- if(r_patched_is_prelease) "r-prerel" else "r-patched"

## Adjust as needed, in particular for prerelease stages.
## <NOTE>
## Keeps this in sync with
##   lib/bash/check_R_cp_logs.sh
##   lib/bash/cran_daily_check_results.sh
## (or create a common data base eventually ...)
## </NOTE>

check_flavors_db <- local({
    db <- c("Flavor|OS_type|CPU_type|OS_kind|CPU_info",
            paste("r-devel-linux-ix86",
                  "r-devel", "Linux", "ix86",
                  "Debian GNU/Linux testing",
                  "AMD Athlon(tm) XP 2400+ (2GHz)",
                  sep = "|"),
            paste("r-devel-linux-x86_64",
                  "r-devel", "Linux", "x86_64",
                  "Debian GNU/Linux testing",
                  "Dual Core AMD Opteron(tm) Processor 280",
                  sep = "|"),
            paste("r-patched-linux-ix86",
                  r_p_o_p, "Linux", "ix86",
                  "Debian GNU/Linux testing",
                  "Intel(R) Pentium(R) 4 CPU 2.66GHz",
                  sep = "|"),
            paste("r-patched-linux-x86_64",
                  r_p_o_p, "Linux", "x86_64",
                  "Debian GNU/Linux testing",
                  "Dual Core AMD Opteron(tm) Processor 280",
                  sep = "|"),
##             paste("r-patched-macosx-ix86",
##                   r_p_o_p, "MacOS_X", "ix86",
##                   "MacOS X 10.4.7",
##                   "iMac, Intel Core Duo 1.83GHz",
##                   sep = "|"),
##             paste("r-patched-windows-x86_64",
##                   r_p_o_p, "Windows", "x86_64 (32bit)",
##                   "Windows Server 2003 SP2 (32bit)",
##                   "AMD Athlon64 X2 6000+",
##                   sep = "|"),            
            paste("r-release-linux-ix86",
                  "r-release", "Linux", "ix86",
                  "Debian GNU/Linux testing",
                  "Intel(R) Pentium(R) 4 CPU 2.66GHz",
                  sep = "|"),
            paste("r-release-macosx-ix86",
                  "r-release", "MacOS_X", "ix86",
                  "MacOS X 10.4.7",
                  "iMac, Intel Core Duo 1.83GHz",
                  sep = "|"),
            paste("r-release-windows-x86_64",
                  "r-release", "Windows", "x86_64 (32bit)",
                  "Windows Server 2003 SP2 (32bit)",
                  "AMD Athlon64 X2 6000+",
                  sep = "|"))
    con <- textConnection(db)
    db <- read.table(con, header = TRUE, sep = "|",
                     colClasses = "character")
    close(con)
    db
})

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

    flavors <- rownames(db)

    writeLines(c("<HTML>",
                 "<HEAD>",
                 "<TITLE>CRAN Daily Package Check Flavors</TITLE>",
                 "</HEAD>",
                 "<BODY LANG=\"en\">",
                 "<H2>CRAN Daily Package Check Flavors</H2>",
                 "<P>",
                 sprintf("Last updated on %s.", format(Sys.time())),
                 "</P>",
                 "<P>",
                 "Systems used for CRAN package checking.",
                 "</P>",
                 "<TABLE BORDER=1>",
                 paste("<TR>",
                       "<TH> Flavor </TH>",
                       "<TH> R&nbsp;Version </TH>",
                       "<TH> OS&nbsp;Type </TH>",
                       "<TH> CPU&nbsp;Type </TH>",
                       "<TH> OS&nbsp;Info </TH>",
                       "<TH> CPU&nbsp;Info </TH>",
                       "</TR>"),
                 do.call(sprintf,
                         c(list(paste("<TR ID=\"%s\">",
                                      paste(rep.int("<TD> %s </TD>",
                                                    ncol(db) + 1L),
                                            collapse = " "),
                                      "</TR>")),
                           list(flavors),
                           list(flavors),
                           db)),
                 "</TABLE>",
                 "</BODY>",
                 "</HTML>"),
               out)
}

check_results_db <-
function(dir = file.path("~", "tmp", "R.check"), check_flavors = NULL)
{
    if(is.null(check_flavors)) {
        check_flavors <- row.names(check_flavors_db)
    }
    check_flavors <-
        check_flavors[file.exists(file.path(dir, check_flavors))]

    results <- vector("list", length(check_flavors))
    names(results) <- check_flavors
    for(flavor in check_flavors) {
        message(sprintf("Getting check results for flavor %s", flavor))
        results[[flavor]] <- check_flavor_results(dir, flavor)
        ind <- which(colnames(results[[flavor]]) == "Status")
        if(length(ind))
            colnames(results[[flavor]])[ind] <- flavor
    }

    ## Now merge results.
    message("Merging check results into a flat db.")
    idx <- which(sapply(results, NROW) > 0L)
    if(!any(idx)) return()
    db <- as.data.frame(results[[idx[1L]]], stringsAsFactors = FALSE)
    check_flavors <- names(results)
    ## (Could have lost those for which check_flavor_results() gives
    ## NULL.)
    for(i in seq_along(check_flavors)[-idx[1L]]) {
        new <- as.data.frame(results[[i]], stringsAsFactors = FALSE)
	if(NROW(new))
            db <- merge(db, new, all = TRUE)
	else {
	    db <- cbind(db, rep.int("", NROW(db)))
	    names(db)[NCOL(db)] <- check_flavors[i]
	}
    }
    db[] <- lapply(db,
                   function(x) {
                       x <- as.character(x)
                       x[is.na(x)] <- ""
                       x
                   })
    db <- db[c("Package", "Version", check_flavors, "Maintainer", "Priority")]
    db[order(db$Package), ]
}

check_flavor_results <-
function(dir = file.path("~", "tmp", "R.check"), flavor = "r-devel",
         check_dirs_root = file.path(dir, flavor, "PKGS"))
{
    if(!file_test("-d", check_dirs_root)) return()

    get_description_fields_as_utf8 <-
        function(dfile, fields = c("Version", "Priority", "Maintainer"))
    {
        ## Assume R 2.6.0 or later.
        is_invalid_multibyte_string <- function(s)
            is.na(nchar(s, "c", allowNA = TRUE))
        
        lc_ctype <- Sys.getlocale("LC_CTYPE")
        Sys.setlocale("LC_CTYPE", "en_US.utf8")
        on.exit(Sys.setlocale("LC_CTYPE", lc_ctype))

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
            meta[i] <- iconv(meta[i], from, "utf8")
        }
        meta[fields]
    }
    
    check_dirs <- list.files(path = check_dirs_root,
                             pattern = "\\.Rcheck", full.names = TRUE)
    results <- matrix(character(), nrow = 0L, ncol = 5L)
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
        ## <FIXME>
        ## Get rid of invalid lines for now ...
        ## Re-encode eventually ...
        log <- log[!is.na(nchar(log, allowNA = TRUE))]
        status <- if(any(grep("ERROR$", log)))
            "ERROR"
        else if(any(grep("WARNING$", log)))
            "WARN"
        else if(any(grep("NOTE$", log)))
            "NOTE"
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
    
    results
}

check_results_summary <-
function(results)
{
    ## Create an executive summary of the results.
    pos <- grep("^r-", names(results))
    out <- matrix(0, length(pos), 4L)
    for(i in seq_along(pos)) {
        status <- results[[pos[i]]]
        totals <-
            c(length(grep("(OK|NOTE)( \\[\\*{1,2}\\])?", status)),
              length(grep("WARN( \\[\\*{1,2}\\])?", status)),
              length(grep("ERROR( \\[\\*{1,2}\\])?", status)))
        out[i, ] <- c(totals, sum(totals))
    }
    dimnames(out) <- list(names(results)[pos],
                          c("OK", "WARN", "ERROR", "Total"))
    out
}

write_check_results_db_as_HTML <-
function(results, dir = file.path("~", "tmp", "R.check", "web"))
{
    if(is.null(results)) return()

    dir <- path.expand(dir)
    if(!file_test("-d", dir))
        dir.create(dir, recursive = TRUE)

    out <- file(file.path(dir, "check_summary.html"), "w")

    ## Header.
    writeLines(c("<HTML LANG=\"en\">",
                 "<HEAD>",
                 "<TITLE>CRAN Daily Package Check Results</TITLE>",
                 "<META HTTP-EQUIV=\"Content-Type\" CONTENT=\"text/html; charset=utf8\">",
                 
                 "</HEAD>",
                 "<BODY LANG=\"en\">",
                 "<H1>CRAN Daily Package Check Results</H1>",
                 "<P>",
                 sprintf("Last updated on %s.", format(Sys.time())),
                 "</P>",
                 "<P>",
                 "Results for installing and checking packages",
                 "using the three current flavors of R on systems",
                 "running Debian GNU/Linux, MacOS X and Windows.",
                 "</P>"),
               out)
    
    ## Overall summary.
    message("Writing check results summary")
    writeLines("<P>Status summary:</P>", out)
    write_check_results_summary_as_HTML(results, out)

    ## HTMLify status info.
    package <- results[, "Package"]
    cnms <- colnames(results)
    ## Find the columns corresponding to the flavors.
    pos <- which(cnms %in% row.names(check_flavors_db))
    for(j in pos) {
        flavor <- cnms[j]
        status <- results[, j]
        if(length(ind <- grep("^OK", status)))
            status[ind] <- sprintf("<FONT COLOR=\"black\">%s</FONT>",
                                   status[ind])
        if(length(ind <- grep("^(WARN|ERROR)", status)))
            status[ind] <- sprintf("<FONT COLOR=\"red\">%s</FONT>",
                                   status[ind])
        if(length(ind <- nzchar(status)))
            status[ind] <-
                sprintf("<A HREF=\"%s%s/%s-00check.html\">%s</A>",
                        check_log_URL, flavor, package[ind], status[ind])
        results[, j] <- status
    }

    ## Overall details.
    message("Writing check results details")
    writeLines("<P>Results per package:</P>", out)
    write_check_results_details_as_HTML(results, out)

    ## Footer.
    writeLines(c("<P>",
                 "Results with [*] or [**] were obtained by checking",
                 "with <CODE>--install=fake</CODE>",
                 "and <CODE>--install=no</CODE>, respectively.",
                 "</P>",
                 "</BODY>",
                 "</HTML>"),
               out)

    close(out)

    ## Individual results for packages.

    ## Really flatten out results.
    ## This should be the format to use for all computations eventually.
    pos <- which(colnames(results) %in% row.names(check_flavors_db))
    mat <- as.matrix(results[, pos])
    ind <- which(mat != "", arr.ind = TRUE)
    mat <- cbind(Package = results$Package[ind[, 1L]],
                 Version = results$Version[ind[, 1L]],
                 Flavor = colnames(mat)[ind[, 2L]],
                 Status = mat[ind])
    ## Indices per package.
    ind <- split(seq_len(nrow(mat)), mat[, "Package"])
    nms <- names(ind)
    for(i in seq_along(ind)) {
        package <- nms[i]
        out <- file.path(dir, sprintf("check_results_%s.html", package))
        message(sprintf("Writing %s", out))
        write_check_results_for_package_as_HTML(package,
                                                mat[ind[[i]], ,
                                                    drop = FALSE],
                                                out)
    }
    
}

write_check_results_summary_as_HTML <-
function(results, out)
{
    tab <- check_results_summary(results)    
    flavors <- rownames(tab)
    fmt <- paste("<TR>",
                 "<TD> <A HREF=\"check_flavors.html#%s\"> %s </A> </TD>",
                 "<TD ALIGN=\"right\"> %s </TD>",
                 "<TD ALIGN=\"right\"> %s </TD>",
                 "<TD ALIGN=\"right\"> %s </TD>",
                 "<TD ALIGN=\"right\"> %s </TD>",                 
                 "</TR>")
    writeLines(c("<TABLE BORDER=1>",
                 paste("<TR>",
                       "<TH> Flavor </TH>",
                       "<TH> OK </TH>",
                       "<TH> WARN </TH>",
                       "<TH> ERROR </TH>",
                       "<TH> Total </TH>",
                       "</TR>"),
                 sprintf(fmt,
                         flavors, flavors,
                         tab[, "OK"],
                         tab[, "WARN"],
                         tab[, "ERROR"],
                         tab[, "Total"]),
                 "</TABLE>"),
               out)
}    

write_check_results_details_as_HTML <-
function(results, out)
{
    package <- results[, "Package"]
    ## HTMLify package, referring to the package web pages.
    hyper_package <-
        sprintf("<A HREF=\"../packages/%s/index.html\">%s</A>",
                package, package)

    pos <- which(row.names(check_flavors_db) %in% colnames(results))
    fmt <- paste("<TR ID=\"%s_%s\">",
                 paste(rep.int("<TD> %s </TD>", length(pos) + 4L),
                       collapse = " "),
                 "</TR>")
    writeLines(c("<TABLE BORDER=1>",
                 paste("<TR>",
                       "<TH> Package </TH>",
                       "<TH> Version </TH>",
                       paste(do.call(sprintf,
                                     c(list("<TH> %s\n%s\n%s </TH>"),
                                       check_flavors_db[pos,
                                                        c("Flavor",
                                                          "OS_type",
                                                          "CPU_type")])),
                             collapse = " "),
                       "<TH> Maintainer </TH>",
                       "<TH> Priority </TH>"),
                 do.call(sprintf,
                         c(list(fmt),
                           list(results[, "Package"]),
                           list(results[, "Version"]),
                           list(hyper_package),
                           results[, -1L])),
                 "</TABLE>"),
               out)
}

write_check_results_for_package_as_HTML <-
function(package, entries, out = "")
{
    lines <-
        c("<HTML LANG=\"en\">",
          "<HEAD>",
          "<TITLE>CRAN Daily Package Check Results</TITLE>",
          "<META HTTP-EQUIV=\"Content-Type\" CONTENT=\"text/html; charset=utf8\">",
          "</HEAD>",
          "<BODY LANG=\"en\">",
          sprintf("<H2>CRAN Daily Package Check Results for Package %s</H2>",
                  package),
          "<P>",
          sprintf("Last updated on %s.", format(Sys.time())),
          "</P>",
          "<TABLE BORDER=1>",
          "<TR> <TH> </TH> <TH> Version </TH> <TH> Status </TH> </TR>",
          sprintf(paste("<TR>",
                        "<TD>",
                        " <A HREF=\"check_flavors.html#%s\"> %s </A>",
                        "</TD>",
                        "<TD ALIGN=\"center\"> %s </TD>",
                        "<TD> %s </TD>",
                        "</TR>"),
                  entries[, "Flavor"],
                  entries[, "Flavor"],
                  entries[, "Version"],
                  entries[, "Status"]),
          "</TABLE>",
          if(length(grep("\\[\\*{1,2}\\]", entries[, "Status"])))
          c("<P>",
            "Results with [*] or [**] were obtained by checking",
            "with <CODE>--install=fake</CODE>",
            "and <CODE>--install=no</CODE>, respectively.",
            "</P>"),
          "</BODY>",
          "</HTML>")
    
    writeLines(lines, out)
}   

check_timings_db <-
function(dir = file.path("~", "tmp", "R.check"))
{
    ## Overall timings for all flavors.
    check_flavors <- row.names(check_flavors_db)
    timings <- vector("list", length = length(check_flavors))
    names(timings) <- check_flavors
    for(flavor in check_flavors) {
        message(sprintf("Getting check timings for flavor %s", flavor))
        timings[[flavor]] <-
            tryCatch(check_flavor_timings(dir, flavor),
                     error = function(e) NULL)
    }
    timings[sapply(timings, NROW) > 0L]
}    

check_flavor_timings <-
function(dir = file.path("~", "tmp", "R.check"),
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
    ## Add information on check mode.  If possible, use the results.
    ## <FIXME>
    ## Stop looking for old-style summary.rds files eventually.
    results_files <- file.path(dir, flavor,
                               c("results.rds", "results.rds.prev",
                                 "summary.rds", "summary.rds.prev"))
    ## </FIXME>
    results_files <- results_files[file.exists(results_files)]
    if(length(results_files)) {
        s <- .readRDS(results_files[1L])
        s <- as.data.frame(s[, -1L], row.names = s[, 1L])
        ## <FIXME>
        ## This should not be necessary for R 2.4.0 or later.
        s$Status <- as.character(s$Status)
        ## Need to recreate comments about install/check type.
        comment <- rep.int("", nrow(s))
        comment[grep("\\[\\*\\]", s$Status)] <- "[--install=fake]"
        comment[grep("\\[\\*\\*\\]", s$Status)] <- "[--install=no]"
        out <- merge(out,
                     data.frame(Comment = comment,
                                Version = s$Version,
                                row.names = row.names(s)),
                     by = 0)
        rownames(out) <- out$Row.names
        out$Row.names <- NULL
    } else {
        comment <- ifelse(is.na(out$Install), "[--install=no]", "")
        out <- cbind(out, Comment = comment, Version = "")
    }
    out[order(out$Total, decreasing = TRUE), ]
}

get_timings_from_timings_files <-
function(tfile)
{
    timings_files <- c(tfile, paste(tfile, "prev", sep = "."))
    timings_files <- timings_files[file.exists(timings_files)]
    if(!length(timings_files)) return()
    x <- paste(readLines(timings_files[1L]), collapse = "\n")
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
    ## This fails when for some reason there are duplicated entries, so
    ## let's be nice ...
    ##   con <- textConnection(c("User System", x))
    ##   x <- read.table(con)
    con <- textConnection(x)
    x <- scan(con, list("", 0, 0), quiet = TRUE)
    close(con)    
    ind <- !duplicated(x[[1L]])
    x <- data.frame(User = x[[2L]][ind], System = x[[3L]][ind],
                    row.names = x[[1L]][ind])
    x <- cbind(Total = rowSums(x), x, Status = bad[ind])
    x <- x[order(x$Total, decreasing = TRUE), ]
    x
}

check_timings_summary <-
function(timings)
{ 
    ## Create an executive summary of the timings.   
    if(!length(timings)) return(NULL)
    out <- sapply(timings,
                  function(x) colSums(x[, c("Check", "Install")],
                                      na.rm = TRUE))
    out <- rbind(out, Total = colSums(out))
    t(out)
}

write_check_timings_db_as_HTML <-
function(timings, dir = file.path("~", "tmp", "R.check", "web"))
{
    if(is.null(timings)) return()

    dir <- path.expand(dir)
    if(!file_test("-d", dir))
        dir.create(dir, recursive = TRUE)

    ## Overall summary.
    out <- file.path(dir, "check_timings.html")
    message(sprintf("Writing %s", out))
    write_check_timings_summary_as_HTML(timings, out)

    ## Individual timings for flavors.
    for(flavor in names(timings)) {
        out <- file.path(dir, sprintf("check_timings_%s.html", flavor))
        message(sprintf("Writing %s", out))
        write_check_timings_for_flavor_as_HTML(timings, flavor, out)
    }

    ## Individual timings for packages.

    ## Really flatten out timings.
    ## This should be the format to use for all computations eventually.
    timings <-
        do.call(rbind,
                lapply(seq_along(timings),
                       function(i) {
                           db <- timings[[i]]
                           cbind(Package = rownames(db),
                                 Flavor = names(timings)[i],
                                 db)
                       }))
    rownames(timings) <- NULL
    mat <- as.matrix(timings)
    mat[is.na(mat)] <- ""
    ## Indices per package.
    ind <- split(seq_len(nrow(mat)), mat[, "Package"])
    nms <- names(ind)
    for(i in seq_along(ind)) {
        package <- nms[i]
        out <- file.path(dir, sprintf("check_timings_%s.html", package))
        message(sprintf("Writing %s", out))
        write_check_timings_for_package_as_HTML(package,
                                                mat[ind[[i]], ,
                                                    drop = FALSE],
                                                out)
    }
   
}

write_check_timings_summary_as_HTML <-
function(timings, out = "")
{
    if(!length(timings)) return()

    if(out == "") 
        out <- stdout()
    else if(is.character(out)) {
        out <- file(out, "wt")
        on.exit(close(out))
    }
    if(!inherits(out, "connection")) 
        stop("'out' must be a character string or connection")
    
    writeLines(c("<HTML LANG=\"en\">",
                 "<HEAD>",
                 "<TITLE>CRAN Daily Package Check Timings</TITLE>",
                 "<META HTTP-EQUIV=\"Content-Type\" CONTENT=\"text/html; charset=utf8\">",
                 
                 "</HEAD>",
                 "<BODY LANG=\"en\">",
                 "<H1>CRAN Daily Package Check Timings</H1>",
                 "<P>",
                 sprintf("Last updated on %s.", format(Sys.time())),
                 "</P>",
                 "<P>",
                 "Available overall timings (CPU seconds) for installing and checking all CRAN packages.",
                 "</P>"),
               out)

    tab <- check_timings_summary(timings)
    flavors <- rownames(tab)
    fmt <- paste("<TR>",
                 "<TD> <A HREF=\"check_flavors.html#%s\"> %s </A> </TD>",
                 "<TD ALIGN=\"right\"> %s </TD>",
                 "<TD ALIGN=\"right\"> %s </TD>",
                 "<TD ALIGN=\"right\"> %s </TD>",
                 "<TD <A HREF=\"check_timings_%s.html\"> Details </A> </TD>",
                 "</TR>")
    writeLines(c("<TABLE BORDER=1>",
                 paste("<TR>",
                       "<TH> Flavor </TH>",
                       "<TH> Check </TH>",
                       "<TH> Install </TH>",
                       "<TH> Total </TH>",
                       "<TH> </TH>",
                       "</TR>"),
                 sprintf(fmt,
                         flavors, flavors,
                         tab[, "Check"],
                         tab[, "Install"],
                         tab[, "Total"],
                         flavors),
                 "</TABLE>",
                 "</BODY>",
                 "</HTML>"),
               out)
}

write_check_timings_for_flavor_as_HTML <-
function(timings, flavor, out = "")
{
    db <- timings[[flavor]]
    if(is.null(db)) return()

    if(out == "") 
        out <- stdout()
    else if(is.character(out)) {
        out <- file(out, "wt")
        on.exit(close(out))
    }
    if(!inherits(out, "connection")) 
        stop("'out' must be a character string or connection")

    package <- rownames(db)

    writeLines(c("<HTML>",
                 "<HEAD>",
                 "<TITLE>CRAN Daily Package Check Timings</TITLE>",
                 "</HEAD>",
                 "<BODY LANG=\"en\">",
                 sprintf("<H2>CRAN Daily Package Check Timings for %s</H2>",
                         flavor),
                 "<P>",
                 sprintf("Last updated on %s.", format(Sys.time())),
                 "</P>",
                 "<P>",
                 "Timings for installing and checking packages",
                 sprintf("for %s on a system running %s (CPU: %s).",
                         check_flavors_db[flavor, "Flavor"],
                         check_flavors_db[flavor, "OS_kind"],
                         check_flavors_db[flavor, "CPU_info"]),
                 "</P>",                 
                 "<P>",
                 sprintf("Total CPU seconds: %s (%s hours).",
                         sum(db$Total),
                         round(sum(db$Total) / 3600, 2)),
                 "</P>",
                 "<TABLE BORDER=1>",
                 paste("<TR>",
                       ## <FIXME>
                       ## Can do this more elegantly ...
                       "<TH> Package </TH>",
                       "<TH> Total </TH>",
                       "<TH> Check </TH>",
                       "<TH> Install </TH>",
                       "<TH> Status </TH>",
                       "<TH> Comment </TH>",
                       ## </FIXME>
                       "</TR>"),
                 do.call(sprintf,
                         c(list(paste("<TR>",
                                      "<TD> <A HREF=\"../packages/%s/index.html\">%s</A> </TD>",
                                      "<TD ALIGN=\"right\"> %.2f </TD>",
                                      "<TD ALIGN=\"right\"> %.2f </TD>",
                                      "<TD ALIGN=\"right\"> %.2f </TD>",
                                      "<TD> %s </TD>",
                                      "<TD> %s </TD>")),
                           list(package, package),
                           db)),
                 "</TABLE>",
                 "</BODY>",
                 "</HTML>"),
               out)
}

write_check_timings_for_package_as_HTML <-
function(package, entries, out = "")
{
    lines <-
        c("<HTML LANG=\"en\">",
          "<HEAD>",
          "<TITLE>CRAN Daily Package Check Timings</TITLE>",
          "<META HTTP-EQUIV=\"Content-Type\" CONTENT=\"text/html; charset=utf8\">",
          "</HEAD>",
          "<BODY LANG=\"en\">",
          sprintf("<H2>CRAN Daily Package Check Timings for Package %s</H2>",
                  package),
          "<P>",
          sprintf("Last updated on %s.", format(Sys.time())),
          "</P>",
          "<P>",
          "Available timings (CPU seconds) for installing and checking.",
          "</P>",
          "<TABLE BORDER=1>",
          paste("<TR>",
                "<TH> Flavor </TH>",
                "<TH> Version </TH>",
                "<TH> Total </TH>",
                "<TH> Check </TH>",
                "<TH> Install </TH>",
                "<TH> Status </TH>",
                "<TH> Comment </TH>",
                "</TR>"),
          do.call(sprintf,
                  list(paste("<TR>",
                             "<TD>",
                             " <A HREF=\"check_flavors.html#%s\"> %s </A>",
                             "</TD>",
                             "<TD ALIGN=\"center\"> %s </TD>",
                             "<TD ALIGN=\"right\"> %s </TD>",
                             "<TD ALIGN=\"right\"> %s </TD>",
                             "<TD ALIGN=\"right\"> %s </TD>",
                             "<TD> %s </TD>",
                             "<TD> %s </TD>",
                             "</TR>"),
                       entries[, "Flavor"],
                       entries[, "Flavor"],
                       entries[, "Version"],
                       entries[, "Total"],
                       entries[, "Check"],
                       entries[, "Install"],
                       entries[, "Status"],
                       entries[, "Comment"])),
          "</TABLE>",
          "</BODY>",
          "</HTML>")
    writeLines(lines, out)
}

write_check_log_as_HTML <-
function(log, out = "")
{
    if(out == "") 
        out <- stdout()
    else if(is.character(out)) {
        out <- file(out, "wt")
        on.exit(close(out))
    }
    if(!inherits(out, "connection")) 
        stop("'out' must be a character string or connection")
    
    lines <- readLines(log)[-1L]
    ## The first line says
    ##   using log directory '/var/www/R.check/......"
    ## which is really useless ...
    
    ## HTML escapes:
    lines <- gsub("&", "&amp;", lines)
    lines <- gsub("<", "&lt;", lines)
    lines <- gsub(">", "&gt;", lines)

    ## Fancy stuff:
    ind <- grep("^\\*\\*? ", lines)
    lines[ind] <- sub("\\.\\.\\. (WARNING|ERROR)",
                      "... <FONT COLOR=\"red\"><B>\\1</B></FONT>",
                      lines[ind])
##     ind <- grep("^\\*\\*? (.*)\\.\\.\\. OK$", lines)
##     lines[ind] <- sub("^(\\*\\*?) (.*)",
##                       "\\1 <FONT COLOR=\"gray\">\\2</FONT>",
##                       lines[ind])

    ## Convert pointers to install.log:
    ind <- grep("^See 'http://.*' for details.$", lines)
    if(length(ind))
        lines[ind] <- sub("^See '(.*)' for details.$",
                          "See <A HREF=\"\\1\">\\1</A> for details.",
                          lines[ind])

    ind <- regexpr("^\\*\\*? ", lines) > -1L
    pos <- c((which(ind) - 1L)[-1L], length(lines))
    lines[pos] <- paste(lines[pos], "</LI>", sep = "")
    pos <- which(!ind) - 1L
    if(any(pos)) {
        lines[pos] <- paste(lines[pos], "<BR>", sep = "")
    }
    
    ## Handle list items.
    count <- rep(0, length(lines))
    count[grep("^\\* ", lines)] <- 1
    count[grep("^\\*\\* ", lines)] <- 2
    pos <- which(count > 0)
    ## Need to start a new <UL> where diff(count[pos]) > 0, and to close
    ## it where diff(count[pos]) < 0.  Substitute the <LI>s first.
    ind <- grep("^\\*{1,2} ", lines)
    lines[ind] <- sub("^\\*{1,2} ", "<LI>", lines[ind])
    ind <- diff(count[pos]) > 0 
    lines[pos[ind]] <- paste(lines[pos[ind]], "\n<UL>")
    ind <- diff(count[pos]) < 0
    lines[pos[ind]] <- paste(lines[pos[ind]], "\n</UL>")
    if(sum(diff(count[pos])) > 0)
        lines <- c(lines, "</UL>")

    ## Make things look nicer: ensure gray bullets as well.
    ## Maybe we could also do the first <FONT> substitution later and
    ## match for
    ##   "^<LI> (.*)\\.\\.\\. OK($|\n)"
    ## lines <- sub("^(<LI>) *(<FONT COLOR=\"gray\">)", "\\2 \\1", lines)
    lines <- sub("^(<LI> *(.*)\\.\\.\\. OK</LI>)",
                 "<FONT COLOR=\"gray\">\\1</FONT>",
                 lines)

    ## Header.
    writeLines(c("<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">",
                 "<HTML>",
                 "<HEAD>",
                 sprintf("<TITLE>Check results for '%s'</TITLE>",
                         sub("-00check.(log|txt)$", "", basename(log))),
                 "<META HTTP-EQUIV=\"Content-Type\" CONTENT=\"text/html; charset=utf-8\">",
                 
                 "</HEAD>",
                 "<BODY>",
                 "<UL>"),
               out)
    ## Body.
    cat(lines, sep = "\n", file = out)
    ## Footer.
    writeLines(c("</BODY>",
                 "</HTML>"),
               out)
}

check_results_diff_db <-
function(dir)
{
    ## Assume that we know that both check.csv.prev and check.csv exist
    ## in dir.
    x <- read.csv(file.path(dir, "check.csv.prev"),
                  colClasses = "character")
    x <- x[names(x) != "Maintainer"]
    y <- read.csv(file.path(dir, "check.csv"),
                  colClasses = "character")
    y <- y[names(y) != "Maintainer"]
    z <- merge(x, y, by = 1, all = TRUE)
    row.names(z) <- z$Package
    z
}

check_results_diffs <-
function(dir)
{
    db <- check_results_diff_db(dir)
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

filter_results_by_status <-
function(results, status)
{
    status <- match.arg(status, c("ERROR", "WARN", "NOTE", "OK"))
    ind <- logical(NROW(results))
    flavors <- intersect(names(results), row.names(check_flavors_db))
    for(flavor in grep("linux", flavors, value = TRUE))
        ind <- ind | regexpr(status, results[[flavor]]) > -1L
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

find_install_order <-
function(packages, dir)
{
    ## Set up repository info.
    ## <FIXME>
    ## Maybe add variables
    ##   Bioconductor_repository_dir
    ##   Omegahat_repository_dir
    ## eventually ...
    ## </FIXME>
    ## Try to infer the "right" BioC repository ...
    dbf <- "/srv/R/Repositories/Bioconductor/release/bioc/REPOSITORY"
    cdirs <- if(file.exists(dbf)) {
        version <-
            sub(".*/", "", grep("^win.binary", readLines(dbf), value = TRUE))
        flavor <- if(as.package_version(paste(getRversion()$major,
                                              getRversion()$minor,
                                              sep = ".")) <= version)
            "release" else "devel"
        sprintf("/srv/R/Repositories/Bioconductor/%s/%s/src/contrib",
                flavor,
                c("bioc", "data/annotation", "data/experiment"))
    } else NULL
    cdirs <- c(cdirs, "/srv/R/Repositories/Omegahat/download/R/packages")
    cdirs <- Filter(file.exists, cdirs)
    curls <- sprintf("file://%s", c(dir, cdirs))

    ## Build db of available packages.
    avail <- available.packages(contriburl = curls)
    ## Now this may have duplicated entries.
    ## We defininitely want all packages from CRAN.
    ## Otherwise, in case of duplication, we want the ones with the
    ## highest available version.
    package <- avail[, "Package"]
    pos <- split(seq_along(package), package)
    pos <- pos[sapply(pos, length) > 1L]    
    bad <- lapply(pos, 
                  function(i) {
                      ## Determine the indices to drop.
                      ind <- avail[i, "Repository"] == curls[1L]
                      keep <- if(any(ind))
                          which(ind)[1L]
                      else {
                          version <- package_version(avail[i, "Version"])
                          which(version == max(version))[1L]
                      }
                      i[-keep]
                  })
    avail <- avail[- unlist(bad), ]

    ## Now try to determine all packages which must be installed in
    ## order to be able to install the given packages to be installed.
    ## Try the following.
    ## For given packages, look at the available ones.
    ## For these, compute all dependencies.
    ## Keep the available ones, and compute their dependencies.
    ## Repeat until convergence.
    p0 <- unique(packages[packages %in% avail[, "Package"]])
    repeat {
        p1 <- unlist(utils:::.make_dependency_list(p0, avail))
        p1 <- unique(c(p0, p1[p1 %in% avail[, "Package"]]))
        if(length(p1) == length(p0)) break
        p0 <- p1
    }
    ## And determine an install order from these.
    DL <- utils:::.make_dependency_list(p0, avail)
    out <- utils:::.find_install_order(p0, DL)

    ## Packages which should be installed but are not in the install
    ## order are trouble.
    bad <- packages[! packages %in% out]

    ## Now check where to install from.
    ## For writing out the installation list:
    ## The ones available locally we can install by their name.
    ## The ones not must be path plus package_version.tar.gz
    ind <- avail[out, "Repository"] != curls[1L]
    if(any(ind)) {
        tmp <- out[ind]
        out[ind] <- sprintf("%s/%s_%s.tar.gz",
                            sub("file://", "", avail[tmp, "Repository"]),
                            avail[tmp, "Package"],
                            avail[tmp, "Version"])
    }
                            
    list(out = out, bad = bad)
}
