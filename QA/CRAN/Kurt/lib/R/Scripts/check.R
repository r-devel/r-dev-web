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
            ## <NOTE>
            ## MacOS X checks now have the system info in
            ## '00_system_info'.
            paste("r-patched-macosx-ix86",
                  "r-patched", "MacOS X", "ix86",
                  "MacOS X 10.4.10 (8R2232)",
                  "iMac, Intel Core Duo 1.83GHz",
                  sep = "|"),
            ## </NOTE>
            paste("r-patched-windows-x86_64",
                  "r-patched", "Windows", "x86_64 (32bit)",
                  "Windows Server 2003 SP2 (32bit)",
                  "AMD Athlon64 X2 6000+",
                  sep = "|"),
            paste("r-release-linux-ix86",
                  "r-release", "Linux", "ix86",
                  "Debian GNU/Linux testing",
                  "Intel(R) Pentium(R) 4 CPU 2.66GHz",
                  sep = "|")
##             paste("r-oldrel-macosx-ix86",
##                   "r-oldrel", "MacOS X", "ix86",
##                   "MacOS X 10.4.10 (8R2232)",
##                   "iMac, Intel Core Duo 1.83GHz",
##                   sep = "|"),
##             paste("r-oldrel-windows-x86_64",
##                   "r-oldrel", "Windows", "x86_64 (32bit)",
##                   "Windows Server 2003 SP2 (32bit)",
##                   "AMD Athlon64 X2 6000+",
##                   sep = "|")
            )
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
                 "<TITLE>CRAN Package Check Flavors</TITLE>",
                 "<LINK REL=\"stylesheet\" TYPE=\"text/css\" HREF=\"../CRAN_web.css\">",
                 "</HEAD>",
                 "<BODY LANG=\"en\">",
                 "<H2>CRAN Package Check Flavors</H2>",
                 "<P>",
                 sprintf("Last updated on %s.", format(Sys.time())),
                 "</P>",
                 "<P>",
                 "Systems used for CRAN package checking.",
                 "</P>",
                 "<TABLE BORDER=\"1\">",
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

check_flavor_summary <-
function(dir = file.path("~", "tmp", "R.check", "r-devel-linux-ix86"),
         check_dirs_root = file.path(dir, "PKGS"))
{
    if(!file_test("-d", check_dirs_root)) return()

    ## <FIXME>
    ## Should really do this globally.
    lc_ctype <- Sys.getlocale("LC_CTYPE")
    Sys.setlocale("LC_CTYPE", "en_US.utf8")
    on.exit(Sys.setlocale("LC_CTYPE", lc_ctype))
    ## </FIXME>

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
            meta[i] <- iconv(meta[i], from, "utf8")
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
        status <- if(any(grep("ERROR$", log)))
            "ERROR"
        else if(any(grep("WARNING$", log)))
            "WARN"
        else if(any(grep("NOTE$", log)))
            "NOTE"
        else
            "OK"
        ## <FIXME>
        ## We really want the special flags used for checking.
        ## Can get them for the Linux runs for now.
        flags <- if(length(grep("linux|windows", basename(dir)))) {
            log <- log[length(log)]
            if(length(grep("^\\* using check arguments '.*'", log)))
                sub("^\\* using check arguments '(.*)'$", "\\1", log)
            else
                ""
        }
        else {
            ## Old style code.
            if(any(grep("^\\*+ checking examples ", log))
                || (status == "ERROR"))
                ""
            else if(any(grep("^\\*+ checking.*can be installed ", log)))
                "--install=fake"
            else
                "--install=no"
        }
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
    is_complete <- regexpr("swaps$", x) > -1L
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
            message(sprintf("Getting summary for flavor %s", flavor))
        summary <- check_flavor_summary(file.path(dir, flavor))
        if(verbose)
            message(sprintf("Getting timings for flavor %s", flavor))
        timings <- check_flavor_timings(file.path(dir, flavor))
        ## Sanitize: if there are no results, skip this flavor.
        if(is.null(summary)) next
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
        sub("[[:space:]]*<[^>]+@[^>]+>", "", results$Maintainer)
    package <- results$Package
    status <-
        ifelse(is.na(results$Status) | is.na(results$Flags), "",
               paste(results$Status,
                     ifelse(nzchar(results$Flags), "<SUP>*</SUP>", ""),
                     sep = ""))
    if(length(ind <- grep("^OK", status)))
        status[ind] <- sprintf("<FONT COLOR=\"black\">%s</FONT>",
                               status[ind])
    if(length(ind <- grep("^(WARN|ERROR)", status)))
        status[ind] <- sprintf("<FONT COLOR=\"red\">%s</FONT>",
                               status[ind])
    if(length(ind <- nzchar(status)))
        status[ind] <-
            paste("<A HREF=\"",
                  check_log_URL, results$Flavor[ind],
                  "/",
                  package[ind],
                  "-00check.html\">",
                  status[ind],
                  "</A>",
                  sep = "")
    ## <FIXME 2.7.0>
    ## sprintf() now is optimized for a length one format string.
    ## <NOTE>
    ## Using
    ##         sprintf("<A HREF=\"%s%s/%s-00check.html\">%s</A>",
    ##                 check_log_URL, results$Flavor[ind],
    ##                 package[ind], status[ind])
    ## is much clearer, but apparently also much slower ...
    ## <FIXME>
    ## This is because sprintf() is vectorized in its fmt argument, and
    ## hence coerces its argument for each line.  When using factors,
    ## coerce them to character right away:
    ##         sprintf("<A HREF=\"%s%s/%s-00check.html\">%s</A>",
    ##                 check_log_URL, as.character(results$Flavor[ind]),
    ##                 package[ind], status[ind])
    ## </FIXME>
    ## </NOTE>
    ## </FIXME>
    results <-
        cbind(results,
              Hyperpack =
              sprintf("<A HREF=\"../packages/%s/index.html\">%s</A>",
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
    writeLines(c("<P>Status summary:</P>",
                 check_summary_html_summary(results)),
               out)
    writeLines(paste("<P>",
                     "<A HREF=\"check_summary_by_maintainer.html#summary_by_maintainer\">",
                     "Results by maintainer",
                     "</A>",
                     "</P>"),
               out)
    if(verbose) message("Writing check results details")
    writeLines(c("<P>Results by package:</P>",
                 check_results_html_details_by_package(db)),
               out)
    writeLines(check_summary_html_footer(), out)
    close(out)

    ## Also create check summary details by maintainer.
    out <- file(file.path(dir, "check_summary_by_maintainer.html"), "w")
    if(verbose) message("Writing check results summary by maintainer")
    writeLines(c(check_summary_html_header(),
                 paste("<P>",
                       "<A HREF=\"check_summary.html#summary_by_package\">",
                       "Results by package",
                       "</A>",
                       "</P>"),
                 "<P>Results by maintainer:</P>",
                 check_results_html_details_by_maintainer(db),
                 check_summary_html_footer()),
               out)
    close(out)
    
    ## Remove the comment/flag info from hyperstatus.
    results$Hyperstat <- sub("<SUP>\\*</SUP>", "", results$Hyperstat)

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

    ## And finally, results for each package.
    write_check_results_for_packages_as_HTML(results, dir)
}

check_summary_html_header <-
function()
    c("<HTML LANG=\"en\">",
      "<HEAD>",
      "<TITLE>CRAN Package Check Results</TITLE>",
      "<LINK REL=\"stylesheet\" TYPE=\"text/css\" HREF=\"../CRAN_web.css\">",
      "<META HTTP-EQUIV=\"Content-Type\" CONTENT=\"text/html; charset=utf8\">",
      "</HEAD>",
      "<BODY LANG=\"en\">",
      "<H1>CRAN Package Check Results</H1>",
      "<P>",
      sprintf("Last updated on %s.", format(Sys.time())),
      "</P>",
      "<P>",
      "Results for installing and checking packages",
      "using the three current flavors of R on systems",
      "running Debian GNU/Linux, MacOS X and Windows.",
      "</P>")
    
check_summary_html_summary <-
function(results)
{
    tab <- check_summary_summary(results)
    flavors <- rownames(tab)
    fmt <- paste("<TR>",
                 "<TD> <A HREF=\"check_flavors.html#%s\"> %s </A> </TD>",
                 "<TD ALIGN=\"right\"> %s </TD>",
                 "<TD ALIGN=\"right\"> %s </TD>",
                 "<TD ALIGN=\"right\"> %s </TD>",
                 "<TD ALIGN=\"right\"> %s </TD>",                 
                 "</TR>")
    c("<TABLE BORDER=\"1\">",
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
      "</TABLE>")
}

check_results_html_details_by_package <-
function(db)
{
    flavors <- intersect(names(db), row.names(check_flavors_db))
    fmt <- paste("<TR>",
                 paste(rep.int("<TD> %s </TD>", length(flavors) + 4L),
                       collapse = " "),
                 "</TR>")
    db <- db[order(db$Package), ]
    flavors_db <- check_flavors_db[flavors,
                                   c("Flavor", "OS_type", "CPU_type")]
    flavors_db$OS_type <-
        sub("MacOS X", "MacOS&nbsp;X", flavors_db$OS_type)
    c("<TABLE BORDER=\"1\" ID=\"summary_by_package\">",
      paste("<TR>",
            "<TH> Package </TH>",
            "<TH> Version </TH>",
            paste(do.call(sprintf,
                          c(list(paste("<TH>",
                                       "<A HREF=\"check_flavors.html#%s\">",
                                       "%s<BR/>%s<BR/>%s",
                                       "</A>",
                                       "</TH>"),
                                 flavors),
                            flavors_db)),
                  collapse = " "),
            "<TH> Maintainer </TH>",
            "<TH> Priority </TH>"),
      do.call(sprintf,
              c(list(fmt),
                db[c("Hyperpack", "Version", flavors,
                     "Maintainer", "Priority")])),
      "</TABLE>")
}

check_results_html_details_by_maintainer <-
function(db)
{
    ## Very similar to the above.
    ## Obviously, this could be generalized ...
    flavors <- intersect(names(db), row.names(check_flavors_db))
    fmt <- paste("<TR>",
                 paste(rep.int("<TD> %s </TD>", length(flavors) + 4L),
                       collapse = " "),
                 "</TR>")
    ## Drop entries with "missing" (empty, i.e., just email address)
    ## maintainer.
    db <- db[nzchar(db$Maintainer) & (db$Maintainer != "ORPHANED"), ]
    ## And sort according to maintainer.
    db <- db[order(db$Maintainer), ]

    flavors_db <- check_flavors_db[flavors,
                                   c("Flavor", "OS_type", "CPU_type")]
    flavors_db$OS_type <-
        sub("MacOS X", "MacOS&nbsp;X", flavors_db$OS_type)

    c("<TABLE BORDER=\"1\" ID=\"summary_by_maintainer\">",
      paste("<TR>",
            "<TH> Maintainer </TH>",
            "<TH> Package </TH>",
            "<TH> Version </TH>",
            paste(do.call(sprintf,
                          c(list(paste("<TH>",
                                       "<A HREF=\"check_flavors.html#%s\">",
                                       "%s<BR/>%s<BR/>%s",
                                       "</A>",
                                       "</TH>"),
                                 flavors),
                            flavors_db)),
                  collapse = " "),
            "<TH> Priority </TH>"),
      do.call(sprintf,
              c(list(fmt),
                db[c("Maintainer", "Hyperpack", "Version",
                     flavors, "Priority")])),
      "</TABLE>")
}

check_summary_html_footer <-
function()
    c("<P>",
      "Results with asterisks (<SUP>*</SUP>) indicate that checking",
      "was not fully performed.",
      "</P>",
      "</BODY>",
      "</HTML>")

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
    
    writeLines(c("<HTML LANG=\"en\">",
                 "<HEAD>",
                 "<TITLE>CRAN Package Check Timings</TITLE>",
                 "<LINK REL=\"stylesheet\" TYPE=\"text/css\" HREF=\"../CRAN_web.css\">",
                 "<META HTTP-EQUIV=\"Content-Type\" CONTENT=\"text/html; charset=utf8\">",
                 "</HEAD>",
                 "<BODY LANG=\"en\">",
                 "<H1>CRAN Package Check Timings</H1>",
                 "<P>",
                 sprintf("Last updated on %s.", format(Sys.time())),
                 "</P>",
                 "<P>",
                 "Available overall timings (in seconds) for installing and checking all CRAN packages.",
                 "</P>"),
               out)

    tab <- check_timings_summary(results)
    tab <- tab[tab[, "T_total"] > 0, ]
    flavors <- rownames(tab)
    fmt <- paste("<TR>",
                 "<TD> <A HREF=\"check_flavors.html#%s\"> %s </A> </TD>",
                 "<TD ALIGN=\"right\"> %.2f </TD>",
                 "<TD ALIGN=\"right\"> %.2f </TD>",
                 "<TD ALIGN=\"right\"> %.2f </TD>",
                 "<TD <A HREF=\"check_timings_%s.html\"> Details </A> </TD>",
                 "</TR>")
    writeLines(c("<TABLE BORDER=\"1\">",
                 paste("<TR>",
                       "<TH> Flavor </TH>",
                       "<TH> T<SUB>check</SUB> </TH>",
                       "<TH> T<SUB>install</SUB> </TH>",
                       "<TH> T<SUB>total</SUB> </TH>",
                       "<TH> </TH>",
                       "</TR>"),
                 sprintf(fmt,
                         flavors, flavors,
                         tab[, "T_check"],
                         tab[, "T_install"],
                         tab[, "T_total"],
                         flavors),
                 "</TABLE>",
                 "</BODY>",
                 "</HTML>"),
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
    
    writeLines(c("<HTML>",
                 "<HEAD>",
                 "<TITLE>CRAN Daily Package Check Timings</TITLE>",
                 "<LINK REL=\"stylesheet\" TYPE=\"text/css\" HREF=\"../CRAN_web.css\">",
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
                 sprintf("Total seconds: %.2f (%.2f hours).",
                         sum(db$T_total, na.rm = TRUE),
                         sum(db$T_total, na.rm = TRUE) / 3600),
                 "</P>",
                 "<TABLE BORDER=\"1\">",
                 paste("<TR>",
                       "<TH> Package </TH>",
                       "<TH> T<SUB>total</SUB> </TH>",
                       "<TH> T<SUB>check</SUB> </TH>",
                       "<TH> T<SUB>install</SUB> </TH>",
                       "<TH> Status </TH>",
                       "<TH> Flags </TH>",
                       "</TR>"),
                 do.call(sprintf,
                         c(list(paste("<TR>",
                                      "<TD> %s </TD>",
                                      "<TD ALIGN=\"right\"> %.2f </TD>",
                                      "<TD ALIGN=\"right\"> %s </TD>",
                                      "<TD ALIGN=\"right\"> %s </TD>",
                                      "<TD> %s </TD>",
                                      "<TD> %s </TD>")),
                           db[c("Hyperpack", "T_total", "T_check",
                                "T_install", "Hyperstat", "Flags")])),
                 "</TABLE>",
                 "</BODY>",
                 "</HTML>"),
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
        c("<HTML LANG=\"en\">",
          "<HEAD>",
          "<TITLE>CRAN Package Check Results</TITLE>",
          "<LINK REL=\"stylesheet\" TYPE=\"text/css\" HREF=\"../CRAN_web.css\">",
          "<META HTTP-EQUIV=\"Content-Type\" CONTENT=\"text/html; charset=utf8\">",
          "</HEAD>",
          "<BODY LANG=\"en\">",
          sprintf(paste("<H2>CRAN Package Check Results for Package",
                        "<A HREF=\"../packages/%s/index.html\"> %s </A>",
                        "</H2>"),
                  package, package),
          "<P>",
          sprintf("Last updated on %s.", format(Sys.time())),
          "</P>",
          "<TABLE BORDER=\"1\">",
          paste("<TR>",
                "<TH> Flavor </TH>",
                "<TH> Version </TH>",
                "<TH> T<SUB>install</SUB> </TH>",
                "<TH> T<SUB>check</SUB> </TH>",
                "<TH> T<SUB>total</SUB> </TH>",                
                "<TH> Status </TH>",
                "<TH> Flags </TH>",
                "</TR>"),
          do.call(sprintf,
                  c(list(paste("<TR>",
                               "<TD>",
                               " <A HREF=\"check_flavors.html#%s\"> %s </A>",
                               "</TD>",
                               "<TD> %s </TD>",
                               "<TD ALIGN=\"right\"> %s </TD>",
                               "<TD ALIGN=\"right\"> %s </TD>",
                               "<TD ALIGN=\"right\"> %s </TD>",
                               "<TD> %s </TD>",
                               "<TD> %s </TD>")),
                    entries[c("Flavor", "Flavor", "Version",
                              "T_install", "T_check", "T_total",
                              "Hyperstat", "Flags")])),
          "</TABLE>",
          "</BODY>",
          "</HTML>")
    
    writeLines(lines, out)
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
    
    lines <- readLines(log, warn = FALSE)[-1L]
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

available_packages_in_local_repositories <-
function(dir)
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
        version <- sub(".*/", "",
                       grep("^win.binary", readLines(dbf), value = TRUE))
        flavor <- if(as.package_version(paste(getRversion()$major,
                                              getRversion()$minor,
                                              sep = ".")) <= version)
            "release" else "devel"
        sprintf("/srv/R/Repositories/Bioconductor/%s/%s/src/contrib",
                flavor,
                c("bioc", "data/annotation", "data/experiment"))
    } else NULL
    cdirs <- c(cdirs, "/srv/R/Repositories/Omegahat/src/contrib")
    cdirs <- Filter(file.exists, cdirs)
    curls <- sprintf("file://%s", c(dir, cdirs))

    ## Build db of available packages.
    available <- available.packages(contriburl = curls)
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
function(packages, dir, available = NULL)
{
    dir <- file_path_as_absolute(dir)
    
    if(is.null(available))
        available <- available_packages_in_local_repositories(dir)

    ## Now try to determine all packages which must be installed in
    ## order to be able to install the given packages to be installed.
    ## Try the following.
    ## For given packages, look at the available ones.
    ## For these, compute all dependencies.
    ## Keep the available ones, and compute their dependencies.
    ## Repeat until convergence.
    p0 <- unique(packages[packages %in% available[, "Package"]])
    repeat {
        p1 <- unlist(utils:::.make_dependency_list(p0, available))
        p1 <- unique(c(p0, p1[p1 %in% available[, "Package"]]))
        if(length(p1) == length(p0)) break
        p0 <- p1
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
