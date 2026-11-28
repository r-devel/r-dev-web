#! /usr/local/bin/Rscript

source("Lib.R")
source("Before.R")
source("Snapshot.R")


d <- c(
    "It seems we need to remind you of the CRAN policy:",
    "",
    "  'Packages which use Internet resources should fail gracefully",
    "   with an informative message if the resource is not available",
    "   or has changed (and not give a check warning nor error).'",
    "",
    "This needs correction whether or not the resource recovers."
)

wrapper <- function()
{
    args <- commandArgs(TRUE)
    if (!length(args)) stop("no arguments")
    mailx_CRAN_package_problems(args, before = Before(21), details = d,
                                info = "ERROR:web")
    for(p in args) snapshot(p)
}

wrapper()
