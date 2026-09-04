#! /usr/local/bin/Rscript

source("Lib.R")

wrapper <- function()
{
    args <- commandArgs(TRUE)
    if (!length(args)) stop("no arguments")
    close_CRAN_package_issues(args)
}

wrapper()
