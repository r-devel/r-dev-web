check_dir <- file.path(normalizePath("~"), "tmp", "CRAN")

Sys.setenv("_R_CHECK_CRAN_INCOMING_USE_ASPELL_" = "true",
           "_R_CHECK_CRAN_STATUS_SUMMARY_" = "true",
           "R_C_BOUNDS_CHECK" = "yes",
           "R_GC_MEM_GROW" = "2",
           "_R_CHECK_EXAMPLE_TIMING_CPU_TO_ELAPSED_THRESHOLD_" = "2.5",
           "_R_CHECK_TEST_TIMING_CPU_TO_ELAPSED_THRESHOLD_" = "2.5",
           "_R_CHECK_VIGNETTE_TIMING_CPU_TO_ELAPSED_THRESHOLD_" = "2.5",
           "_R_CHECK_PACKAGE_DEPENDS_IGNORE_MISSING_ENHANCES_" = "true",
           "_R_TOOLS_C_P_I_D_ADD_RECOMMENDED_MAYBE_" = "true")

update_check_dir <- TRUE
use_check_stoplists <- FALSE
Ncpus <- 6

hostname <- system2("hostname", "-f", stdout = TRUE)
if(hostname == "xmanduin.wu.ac.at") {
    ## <FIXME>
    ## Change eventually?
    Sys.setenv("R_ENABLE_JIT" = "0")
    ## </FIXME>
    Sys.setenv("_R_CHECK_EXAMPLE_TIMING_THRESHOLD_" = "10")
    Ncpus <- 10
}

reverse <- NULL

## <FIXME>
## Perhaps add a -p argument to be passed to getIncoming?
## Currently, -p KH/*.tar.gz is hard-wired.
## </FIXME>

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
        "  -f=FLAVOR       use flavor FLAVOR ('g' or 'c' for the GCC or Clang",
        "                  defaults, 'g/v' or 'c/v' for the version 'v' ones)",
        "  -d=DIR          use DIR as check dir (default: ~/tmp/CRAN)",
        "  -l              run local incoming checks only",
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
if(any(ind <- (args == "-l"))) {
    Sys.setenv("_R_CHECK_CRAN_INCOMING_REMOTE_" = "false")
    args <- args[!ind]
}    
if(any(ind <- startsWith(args, "-r="))) {
    which <- substring(args[ind][1L], 4L)
    reverse <- if(which == "most") {
        list(which = list(c("Depends", "Imports", "LinkingTo"),
                          "Suggests"),
             reverse = c(TRUE, FALSE))
    } else {
        list(which = which)
    }
    args <- args[!ind]
}
if(any(ind <- startsWith(args, "-N="))) {
    Ncpus <- list(which = substring(args[ind][1L], 4L))
    args <- args[!ind]
}
if(any(ind <- startsWith(args, "-d="))) {
    check_dir <- substring(args[ind][1L], 4L)
    args <- args[!ind]
}
if(length(args)) {
    stop(paste("unknown option(s):",
               paste(sQuote(args), collapse = ", ")))
}

if(update_check_dir) {
    unlink(check_dir, recursive = TRUE)
    if(system2("getIncoming",
               c("-p KH/*.tar.gz", "-d", check_dir),
               stderr = FALSE)) {
        message("no packages to check")
        q("no", status = 1, runLast = FALSE)
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
check_env_common <-
    c("LANG=en_US.UTF-8",
      "LC_COLLATE=C",
      "LANGUAGE=en@quot",
      ## These could be conditionalized according to hostname.
      "R_SESSION_TIME_LIMIT_CPU=900",
      "R_SESSION_TIME_LIMIT_ELAPSED=1800",
      "_R_INSTALL_PACKAGES_ELAPSED_TIMEOUT_=1800",
      ## FIXME: remove eventually
      "_R_INSTALL_TIME_LIMIT_=1800",
      "_R_CHECK_ELAPSED_TIMEOUT_=1800",
      ## FIXME: remove eventually
      "_R_CHECK_TIME_LIMIT_=1800")
check_env <-
    list(c(check_env_common,
           "_R_CHECK_WARN_BAD_USAGE_LINES_=TRUE",
           sprintf("_R_CHECK_CRAN_INCOMING_SKIP_VERSIONS_=%s",
                   !run_CRAN_incoming_feasibility_checks),
           sprintf("_R_CHECK_CRAN_INCOMING_SKIP_DATES_=%s",
                   !run_CRAN_incoming_feasibility_checks),
           "_R_CHECK_LENGTH_1_CONDITION_=package:_R_CHECK_PACKAGE_NAME_"),
         c(check_env_common,
           "_R_CHECK_CRAN_INCOMING_=false"))

if(!is.null(reverse))
    reverse$repos <- getOption("repos")["CRAN"]

pfiles <-
    tools::check_packages_in_dir(check_dir,
                                 check_args = check_args,
                                 check_args_db = check_args_db,
                                 reverse = reverse,
                                 xvfb = TRUE,
                                 check_env = check_env,
                                 Ncpus = Ncpus)

if(length(pfiles)) {
    writeLines("\nDepends:")
    tools::summarize_check_packages_in_dir_depends(check_dir)
    writeLines("\nTimings:")
    tools::summarize_check_packages_in_dir_timings(check_dir)
    writeLines("\nResults:")
    tools::summarize_check_packages_in_dir_results(check_dir)
}
