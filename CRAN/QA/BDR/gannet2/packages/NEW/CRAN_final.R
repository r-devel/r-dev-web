#! /usr/local/bin/Rscript

source("Lib.R")
source("Before.R")
source("Snapshot.R")

wrapper <- function()
{
    args <- commandArgs(TRUE)
    if (!length(args)) stop("no arguments")
    mailx_CRAN_package_problems(args, before = Before(14), final = TRUE)
}

wrapper()
