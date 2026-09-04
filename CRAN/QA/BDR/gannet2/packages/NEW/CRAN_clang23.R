#! /usr/local/bin/Rscript

source("Lib.R")
source("Before.R")
source("Snapshot.R")

d <- c("Do remember to look at the 'Additional issues'",
       "",
       "For further details, see",
       "<https://www.stats.ox.ac.uk/pub/bdr/clang23/README.txt>")

wrapper <- function()
{
    args <- commandArgs(TRUE)
    if (!length(args)) stop("no arguments")
    mailx_CRAN_package_problems(args, before = Before(21), details = d,
                                info = "Additional_issues:clang23")
    for(p in args) snapshot(p)
}

wrapper()
