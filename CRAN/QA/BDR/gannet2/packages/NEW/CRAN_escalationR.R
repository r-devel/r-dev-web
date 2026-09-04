#! /usr/local/bin/Rscript
source("Before.R")
source("Lib.R")
source("cran_problems_escalation.R")


wrapper <- function()
{
    args <- commandArgs(TRUE)
    if (length(args) != 1L) stop("needs one argument")
    ## Might need wontfix = TRUE
    m <- CRAN_package_problem_escalation_message(args, recursive = TRUE)
    mailx_from_head_and_body_list(m) # add info header?
}

wrapper()
