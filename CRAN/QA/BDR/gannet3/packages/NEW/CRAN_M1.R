#! /usr/local/bin/Rscript

source("Lib.R")
source("Before.R")
source("Snapshot.R")

d <- c(
    "There is a check service for M1mac issues: see",
    "https://www.stats.ox.ac.uk/pub/bdr/M1mac/README.txt .",
    "However, it is running a much older version of the OS",
    "and toolchain -- and the latter often matters."
    )

wrapper <- function()
{
    args <- commandArgs(TRUE)
    if (!length(args)) stop("no arguments")
    mailx_CRAN_package_problems(args, before = Before(21), details = d,
                                info = "Additional_issues:M1")
    for(p in args) snapshot(p)
}

wrapper()
