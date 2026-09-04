#! /usr/local/bin/Rscript

source("Lib.R")
source("Snapshot.R")

wrapper <- function()
{
    args <- commandArgs(TRUE)
    if (length(args) != 2) stop("Two arguments are required")
    extend_CRAN_package_deadline(args[1], args[2])
    for(p in args) snapshot(p)
}

wrapper()
