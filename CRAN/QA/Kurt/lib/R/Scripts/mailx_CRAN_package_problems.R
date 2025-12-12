local({
    for(d in c(".", "~/lib/R/Scripts")) {
        if(file.exists(p <- file.path(d, "mailx.R")))
            source(p)
    }
})

CRAN_package_maintainers_addresses <-
function(packages, db = NULL)    
{
    if(is.null(db))
        db <- tools:::CRAN_package_maintainers_db()
    ind <- match(packages, db[, "Package"])
    addresses <- db[ind, "Address"]
    names(addresses) <- packages
    addresses
}

## <FIXME>
## This is not quite perfect.
## Perhaps best to have arguments for everything one can set, e.g.
##   id title before label
## and a
##   .list
## argument for conveniently specifying these from other functions.
## </FIXME>
CRAN_issue_info <-
function(info = NULL, before = NULL, final = FALSE) {
    if(is.null(info)) {
        .id <- .label <- .title <- NULL
    } else if(is.character(info)) {
        .id <- .label <- NULL
        .title <- info
    } else {
        .id <- info$id
        .label <- info$label
        .title <- info$title
    }
    .user <- Sys.info()["user"]
    if(is.null(.id))
        .id <- sprintf("%s_%s", format(Sys.time(), "%F_%T"), .user)

    if(final)
        .label <- "FINAL"
    
    info <- c(.id,
              if(!is.null(.title))
                  .title,
              "QUERIED",
              format(Sys.Date()),
              .user,
              if(!is.null(before))
                  c("BEFORE",
                    format(before)),
              if(!is.null(.label))
                  .label)
    info <- paste(info[nzchar(info)], collapse = ":")
    info
}
    
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
       (before >= as.Date("2025-12-23")) &&
       (before <= as.Date("2026-01-08")))
        before <- as.Date("2026-01-12")
    ## </FIXME>

    body_from_package_and_details <- function(p, d = character()) {
        c("Dear maintainer,",
          "",
          if(problem)
              c("Please see the problems shown on",
                sprintf("<https://cran.r-project.org/web/checks/check_results_%s.html>.",
                        p),
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
          "Best wishes,",
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

details_from_results_and_texts <- function(results,
                                           starter,
                                           trailer = character(),
                                           wrap = NULL) {
    wrap <- if(is.null(wrap))
                c(TRUE, TRUE)
            else
                rep_len(wrap, 2L)
    if(wrap[1L])
        starter <- strwrap(starter)
    if(wrap[2L])
        trailer <- strwrap(trailer)
    d <- lapply(results,
                function(r) {
                    c(starter,
                      "",
                      strrep("*", 72),
                      tools:::.eval_with_capture(print(r))$output,
                      strrep("*", 72),
                      if(length(trailer))
                          c("", trailer),
                      character())
                })
    names(d) <- names(results)
    d
}

close_CRAN_package_issues <-
function(packages, from = Sys.getenv("EMAIL"), verbose = TRUE)
{
    headers <-
        paste0("X-CRAN-Issue-Info: ",
               CRAN_issue_info(info = list(label = "CLOSE")))

    body <- c("Team: all issues closed.")

    Map(function(p) {
            mailx(paste("CRAN package", p),
                  "CRAN@R-project.org",
                  body = body,
                  from = from,
                  verbose = verbose,
                  headers = headers)
        },
        packages)
    
    invisible()
}

extend_CRAN_package_deadline <- 
function(packages, before, from = Sys.getenv("EMAIL"),
         verbose = TRUE)
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
    
    headers <-
        paste0("X-CRAN-Issue-Info: ",
               CRAN_issue_info(info = list(label = "EXTEND"),
                               before = before))

    body <- c("Dear maintainer",
              "",
              "This is to confirm that we have extended the deadline for your package.",
              "",
              paste("Please correct before",
                    format(before),
                    "to safely retain your package on CRAN."),
              "",
              "Best wishes,",
              "The CRAN Team"
              )
    
    cc <- "CRAN@R-project.org"

    Map(function(a, p) {
            mailx(paste("CRAN package", p),
                  a,
                  body = body,
                  from = from,
                  cc = cc,
                  replyto = cc,
                  verbose = verbose,
                  headers = headers)
        },
        addresses,
        packages)
    
    invisible()
}
