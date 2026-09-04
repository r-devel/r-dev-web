#! /usr/local/bin/Rscript

source("Lib.R")
source("Before.R")
source("Snapshot.R")

mailx_CRAN_package_problems <-
function(packages, cran = TRUE, verbose = TRUE, before = NULL,
         details = character(), final = FALSE, problem = TRUE,
         info = NULL, from = Sys.getenv("EMAIL"))
{
    addresses <-
        CRAN_package_maintainers_addresses(packages)
    ind <- is.na(addresses) | (addresses == "orphaned")
    if(any(ind))
        message(c("Found no maintainer addresses for packages:",
                  strwrap(paste(packages[ind], collapse = " "),
                          indent = 2L, exdent = 2L)))
    addresses <- addresses[!ind]
    packages <- names(addresses)

    if(!is.list(details)) {
        details <- rep_len(list(details), length(packages))
        names(details) <- packages
    } else {
        ind <- !(packages %in% names(details))
        if(any(ind))
            stop(c("Found no details for packages:",
                   strwrap(paste(packages[ind], collapse = " "),
                           indent = 2L, exdent = 2L)))
        ## Could also subscript addresses and packages ...
        details <- details[packages]
    }

    before <- if(is.null(before) || isTRUE(before)) {
                  if(final)
                      Sys.Date() + 14
                  else
                      Sys.Date() + 21
              } else if(is.logical(before))
                  NULL
              else
                  as.Date(before)

    ## <FIXME>
    ## Adjust for upcoming CRAN holidays.
    if(!is.null(before) &&
       (before >= as.Date("2026-08-05")) &&
       (before <= as.Date("2026-08-19")))
        before <- as.Date("2026-08-21")
    ## </FIXME>

    body_from_package_and_details <- function(p, d = character()) {
        c("Dear maintainer,",
          "",
          if(problem)
              c("Please see the problems shown on",
                sprintf("<https://www.stats.ox.ac.uk/pub/bdr/M1-SAN/%s>", p),
                ""),
          if(length(d))
              c(d, ""),
          if(!is.null(before))
              c(paste("Please correct before",
                      format(before),
                      "to safely retain your package on CRAN."),
                ""),
          if(final)
              c("Note that this will be the *final* reminder.",
                ""),
##          "Best wishes,",
          "The CRAN Team")
    }

    cc <- if(is.character(cran))
              cran
          else if(cran)
              "CRAN@R-project.org"
          else
              character()

    headers <-
        paste0("X-CRAN-Issue-Info: ",
               CRAN_issue_info(info, before, final))

    Map(function(a, p, d) {
            mailx(paste("CRAN package", p),
                  a,
                  ## "Kurt.Hornik@wu.ac.at",
                  body = body_from_package_and_details(p, d),
                  from = from,
                  cc = cc,
                  replyto = cc,
                  verbose = verbose,
                  headers = headers)
        },
        addresses,
        packages,
        details)

    message(c("Sent messages to maintainer of packages:\n",
              strwrap(paste(packages, collapse = " "),
                      indent = 2L, exdent = 2L)))

    invisible()
}

d <- "There is a README.txt in the parent of that directory."

wrapper <- function()
{
    args <- commandArgs(TRUE)
    if (!length(args)) stop("no arguments")
    mailx_CRAN_package_problems(args, before = Before(21), details = d,
                                info = "ERROR:M1-SAN")
    for(p in args) snapshot(p)
}

wrapper()
