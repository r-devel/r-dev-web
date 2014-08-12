checkDeps <- function(pkg)
{
    owd <- setwd(paste0(pkg, ".Rcheck"))
    on.exit(setwd(owd))
    deps <- unique(c(tools::dependsOnPkgs(pkg),
                     tools::dependsOnPkgs(pkg, 'all', FALSE)))
    if(!length(deps)) {
        message("No dependents")
        return(invisible(NULL))
    }
    deps <- sort(deps)
    message("Checking ", length(deps), " dependents ...")

    av <- available.packages()[deps, , drop = FALSE]
    files <- paste0(deps, "_", av[, "Version"], ".tar.gz")
    names(files) <- deps

    Sys.setenv(R_LIBS = file.path(getwd(), ":~/R/test-3.2"))

    cmds <- paste("R_HOME= Rdev CMD check",
                     file.path("~/R/packages/contrib", files),
                     ">", paste0(deps, ".out"), "2>&1")
    parallel::mclapply(cmds, system, mc.cores = 8, mc.preschedule = FALSE)
    message("... Dependents checked")
    invisible(NULL)
}
pkg <- commandArgs(TRUE)
pkg <- basename(pkg)
pkg <- sub("_.*", "", pkg)
checkDeps(pkg)


