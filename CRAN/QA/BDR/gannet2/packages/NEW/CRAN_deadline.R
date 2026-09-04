#! /usr/local/bin/Rscript

source("Lib.R")

wrapper <- function()
{
    args <- commandArgs(TRUE)
    if (length(args) != 2) stop("Two arguments are required")
    record_CRAN_package_issues(args[1], args[2]))
}

wrapper()
