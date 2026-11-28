#! /usr/local/bin/Rscript

source("Lib.R")
source("Before.R")
source("Snapshot.R")

d <- c(
    "Packages in Suggests should be used conditionally: see 'Writing R Extensions'.",
    "This needs to be corrected even if the missing package(s) become available.",
    "It can be tested by checking with _R_CHECK_DEPENDS_ONLY_=true."
)

wrapper <- function()
{
    args <- commandArgs(TRUE)
    if (!length(args)) stop("no arguments")
    mailx_CRAN_package_problems(args, before = Before(21), details = d,
                                info = "Additional_issues:noSuggests")
    for(p in args) snapshot(p)
}

wrapper()
