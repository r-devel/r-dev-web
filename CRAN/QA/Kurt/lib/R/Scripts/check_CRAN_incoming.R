require("tools", quietly = TRUE)

check_dir <- file.path(normalizePath("~"), "tmp", "CRAN")

Sys.setenv("_R_CHECK_CRAN_INCOMING_USE_ASPELL_" = "true",
           "R_C_BOUNDS_CHECK" = "yes",
           "R_GC_MEM_GROW" =  2)

update_check_dir <- TRUE
use_check_stoplists <- FALSE
Ncpus <- 4

reverse <- NULL

usage <- function() {
    cat("Usage: check_CRAN_incoming [options]",
        "",
        "Run KH CRAN incoming checks.",
        "",
        "Options:",
        "  -h, --help      print short help message and exit",
        "  -n              do not update check dir",
        "  -s              use stop lists",
        "  -c              run CRAN incoming feasibility checks",
        "  -r              also check strong reverse depends",
        "  -r=WHICH        also check WHICH reverse depends",
        "  -N=N            use N CPUs",
        "",
        "The CRAN incoming feasibility checks are always used for CRAN",
        "incoming checks (i.e., unless '-n' is given), and never when",
        "checking the reverse dependencies.",
        sep = "\n")
}

check_args_db_from_stoplist_sh <-
function()
{
    x <- system(". ~/lib/bash/check_R_stoplists.sh; set", intern = TRUE)
    x <- grep("^check_args_db_", x, value = TRUE)
    db <- sub(".*='(.*)'$", "\\1", x)
    names(db) <-
        chartr("_", ".", sub("^check_args_db_([^=]*)=.*", "\\1", x))
    db
}

args <- commandArgs(trailingOnly = TRUE)
if(any(ind <- (args %in% c("-h", "--help")))) {
    usage()
    q("no", runLast = FALSE)
}
if(any(ind <- (args == "-n"))) {
    update_check_dir <- FALSE
    args <- args[!ind]
}
if(any(ind <- (args == "-s"))) {
    use_check_stoplists <- TRUE
    args <- args[!ind]
}
run_CRAN_incoming_feasibility_checks <- update_check_dir
if(any(ind <- (args == "-c"))) {
    run_CRAN_incoming_feasibility_checks <- TRUE
    args <- args[!ind]
}
if(any(ind <- (args == "-r"))) {
    reverse <- list()
    args <- args[!ind]
}
if(any(ind <- grepl("^-r=", args))) {
    reverse <- list(which = substring(args[ind][1L], 4L))
    args <- args[!ind]
}
if(any(ind <- grepl("^-N=", args))) {
    Ncpus <- list(which = substring(args[ind][1L], 4L))
    args <- args[!ind]
}
if(length(args)) {
    stop(paste("unknown option(s):",
               paste(sQuote(args), collapse = ", ")))
}

if(update_check_dir) {
    unlink(check_dir, recursive = TRUE)
    if(system2("getIncoming")) {
        message("no packages to check")
        q("no", runLast = FALSE)
    }
    message("")
}

## Always use CRAN check profile.
check_args <- "--as-cran"
check_args_db <- if(use_check_stoplists) {
    check_args_db_from_stoplist_sh()    
} else {
    list()
}
check_env <-
    list(c("LC_ALL=en_US.UTF-8",
           "_R_CHECK_WARN_BAD_USAGE_LINES_=TRUE",
           sprintf("_R_CHECK_CRAN_INCOMING_=%s",
                   run_CRAN_incoming_feasibility_checks)),
         c("LC_ALL=en_US.UTF-8",
           "_R_CHECK_CRAN_INCOMING_=false"))

if(!is.null(reverse))
    reverse$repos <- getOption("repos")["CRAN"]

## Use the system default for available packages filtering.
options(available_packages_filters = NULL)

pfiles <- check_packages_in_dir(check_dir,
                                check_args = check_args,
                                check_args_db = check_args_db,
                                reverse = reverse,
                                xvfb = TRUE,
                                check_env = check_env,
                                Ncpus = Ncpus)

if(length(pfiles)) {
    writeLines("\nDepends:")
    summarize_check_packages_in_dir_depends(check_dir)
    writeLines("\nTimings:")
    summarize_check_packages_in_dir_timings(check_dir)
    writeLines("\nResults:")
    summarize_check_packages_in_dir_results(check_dir)
}
