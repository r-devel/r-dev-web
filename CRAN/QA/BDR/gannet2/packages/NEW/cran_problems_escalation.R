## If we have a package p with problems for which we know that the
## maintainer will not fix these, either implicitly by never following
## up on reminders, or explicitly by telling us so, and the package has
## reverse dependencies, we can either provide NMUs, or need to escalate
## the issue by informing the maintainers of the reverse depends.

## The code below generates the necessary materials.

## For CRAN_issue_info():
## source("~/lib/R/Scripts/mailx_CRAN_package_problems.R")


CRAN_package_problem_escalation_message <-
function(package, before = Before(21), recursive = FALSE,
         bounce = FALSE, wontfix = FALSE, problem = TRUE,
         macheck = FALSE, details = character(), collapse = FALSE)
{
    a <- available.packages()
    r <- unlist(tools::package_dependencies(package, a, reverse = TRUE,
                                            recursive = recursive))
    if(length(unlist(r)) > 75) stop("too many revdeps")
    j <- startsWith(a[r, "Repository"], getOption("repos")["CRAN"])

    db <- tools:::CRAN_package_maintainers_db()
    if(!all(j))
        db <- rbind(db,
                    tools:::CRAN_package_maintainers_db(tools:::BioC_package_db()))
    ## FIXME: BioC packages can have more than one maintainer, but
    ## tools:::CRAN_package_maintainers_only extracts the last address.
    info <- tools:::CRAN_package_maintainers_info(c(package, r),
                                                  db = db,
                                                  collapse = collapse)
    if(!all(j))
        info$body <- sub("the CRAN package",
                         "the CRAN/BioC package",
                         info$body)

    head <- info$head
    label <- if(recursive) "RRDEPENDS" else "RDEPENDS"
    s <- paste0("X-CRAN-Issue-Info: ",
                CRAN_issue_info(list(label = label,
                                     title = if(bounce && macheck)
                                                 "email_to_maintainer_is_undeliverable"
                                             else NULL),
                                before = before))
    if(collapse) {
        head[startsWith(head, "Subject:")] <-
            sprintf("Subject: CRAN package %s and its reverse dependencies",
                    package)
        head <- c(head, s)
    } else {
        head$Subject <-
            sprintf("CRAN package %s and its reverse dependencies",
                    package)
        head$headers <- s
    }

    s <- if(bounce && macheck)
             c(sprintf("We recently checked whether the maintainer contact address for package '%s' is still up to date (as mandated by the CRAN Policy), but unfortunately email to this address bounced.",
                       package),
               character())
         else
             c(paste("We",
                     if(bounce) "recently" else "have",
                     "asked for an update fixing"),
               if(problem)
                   c("the check problems shown on",
                     sprintf("<https://cran.r-project.org/web/checks/check_results_%s.html>",
                             package))
               else
                   sprintf("issues with package '%s',", package),
               if(bounce)
                   "but email to the maintainer bounced."
               else if(wontfix)
                   "and been informed that the maintainer will not be able to fix these."
               else
                   "with no successful update from the maintainer thus far.",
               character())
    s <- sub("^(<https://)", "  \\1", strwrap(paste(s, collapse = " ")))
    body <-
        c(info$body,
          "",
          s,
          "",
          if(length(details))
              c(details, ""),
          strwrap(paste(sprintf("Thus, package %s is now scheduled for archival on %s,",
                                package, before),
                        "and archiving this will necessitate also archiving its",
                        "CRAN strong reverse dependencies.")),
          "",
          "Please negotiate the necessary actions.",
          "",
          if(macheck)
              c(strwrap("Perhaps one of you knows how to reach the maintainer at a different address, and the maintainer can then submit a new version.  If not, perhaps one of you wants to take over as maintainer?"),
                ""),
#          "Best wishes,",
          "The CRAN Team"
          )

    list(head = head, body = body)
}
