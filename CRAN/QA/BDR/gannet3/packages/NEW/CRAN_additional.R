#! /usr/local/bin/Rscript

source("Lib.R")
source("Before.R")
source("Snapshot.R")

d <- "Do remember to look at the 'Additional issues'"
wrapper <- function()
{
    args <- commandArgs(TRUE)
    if (!length(args)) stop("no arguments")
    mailx_CRAN_package_problems(args, before = Before(21), details = d,
                                info = "Additional_issues")
    for(p in args) snapshot(p)
}

wrapper()
