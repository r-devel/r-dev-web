R_scripts_dir <- normalizePath(file.path("~", "lib", "R", "Scripts"))

## <FIXME>
## Integrate into check.R eventually ...
source(file.path(R_scripts_dir, "check_extras.R"))
## </FIXME>

check_dir <- normalizePath(file.path("~", "tmp", "CRAN"))

## <NOTE>
## The R package check code currently does
##   check_incoming <- config_val_to_logical(Sys.getenv("_R_CHECK_CRAN_INCOMING_", "FALSE")) || as_cran
##   if (check_incoming) check_CRAN_incoming()
## where as_cran is turned on by the '--as-cran' command line option.
## Hence, if this is given there is currently no way to turn off running
## the incoming feasibility checks.
## To use a CRAN check profile without feasibility checks, we must thus
## set environment variables corresponding to (an approximation) of the
## CRAN check profile.
## We currently use '-c' to the effect of using '--as-cran' in the
## checks of the packages in the check dir (not their reverse depends),
## where '-c' is implied if the check dir is updated to the current CRAN
## incoming queue (i.e., unless '-n' is given).
## This clearly needs further thinking ...
## </NOTE>

Sys.setenv("_R_CHECK_CRAN_INCOMING_USE_ASPELL_" = "true",
           "R_GC_NGROWINCRFRAC" = 0.2,
           "R_GC_VGROWINCRFRAC" = 0.2,
           "R_C_BOUNDS_CHECK" = "yes")

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
        "  -c              use CRAN incoming check profile",
        "  -r              also check strong reverse depends",
        "  -r=WHICH        also check WHICH reverse depends",
        "  -N=N            use N CPUs",
        "",
        "The CRAN incoming check profile is always used for CRAN incoming",
        "checks (i.e., unless '-n' is given), and never when checking the",
        "reverse dependencies.",
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
use_CRAN_incoming_check_profile <- update_check_dir
if(any(ind <- (args == "-c"))) {
        use_CRAN_incoming_check_profile <- TRUE
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

check_args <- if(use_CRAN_incoming_check_profile) {
    list("--as-cran", character())
} else {
    character()
}

check_args_db <- if(use_check_stoplists) {
    check_args_db_from_stoplist_sh()    
} else {
    list()
}

if(!is.null(reverse))
    reverse$repos <- getOption("repos")["CRAN"]

options(available_packages_filters = NULL)

pfiles <- check_packages_in_dir(check_dir,
                                check_args = check_args,
                                check_args_db = check_args_db,
                                reverse = reverse,
                                env = 
                                c("LC_ALL=en_US.UTF-8",
                                  "_R_CHECK_WARN_BAD_USAGE_LINES_=TRUE"),
                                Ncpus = Ncpus)

if(length(pfiles)) {
    writeLines("\nDepends:")
    summarize_check_packages_in_dir_depends(check_dir)
    writeLines("\nTimings:")
    summarize_check_packages_in_dir_timings(check_dir)
    writeLines("\nResults:")
    summarize_check_packages_in_dir_results(check_dir)
}
