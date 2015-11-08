R_scripts_dir <- normalizePath(file.path("~", "lib", "R", "Scripts"))

## Set as needed.
Ncpus <- 1
## Set as needed.
check_repository_root <- "/srv/R/Repositories"
## Set as needed.
check_packages_via_parallel_make <- "no"
## Set as needed.
libdir <- Sys.getenv("_CRAN_CHECK_REGULAR_LIBDIR_",
                     file.path(R.home(), "Packages"))

xvfb_run <- "xvfb-run -a --server-args=\"-screen 0 1280x1024x24\""

if(!interactive()) {
    ## Command line handling.
    args <- commandArgs(trailingOnly = TRUE)
    pos <- which(args == "-j")
    if(length(pos)) {
        Ncpus <- as.integer(args[pos + 1L])
        args <- args[-c(pos, pos + 1L)]
    }
    pos <- which(args == "-m")
    if(length(pos)) {
        check_packages_via_parallel_make <- args[pos + 1L]
        args <- args[-c(pos, pos + 1L)]
    }
    ## That's all for now ...
    ## <NOTE>
    ## Could also add a command line argument for setting
    ## check_repository_root.
    ## </NOTE>
}

check_packages_via_parallel_make <-
    tolower(check_packages_via_parallel_make) %in% c("1", "yes", "true")

## Compute repository URLs to be used as repos option for checking,
## assuming local CRAN, BioC and Ohat mirrors rooted at dir.
check_repository_URLs <-
function(dir)
{
    ## Could make this settable to smooth transitions ...
    BioC_version <-
        if(is.function(tools:::.BioC_version_associated_with_R_version)) {
            tools:::.BioC_version_associated_with_R_version()
        } else {
            tools:::.BioC_version_associated_with_R_version
        }
    BioC_names <- c("BioCsoft", "BioCann", "BioCexp")
    BioC_paths <- c("bioc", "data/annotation", "data/experiment")

    ## Assume that all needed src/contrib directories really exist.
    repos <- sprintf("file://%s/%s",
                     normalizePath(dir),
                     c("CRAN",
                       file.path("Bioconductor",
                                 BioC_version,
                                 BioC_paths),
                       "Omegahat"))
    names(repos) <- c("CRAN", BioC_names, "Omegahat")
    repos
}

format_timings_from_ts0_and_ts1 <-
function(dir)
{
    ts0 <- Sys.glob(file.path(dir, "*.ts0"))
    ts1 <- Sys.glob(file.path(dir, "*.ts1"))
    ## These should really have the same length, but who knows.
    mt0 <- file.info(ts0)$mtime
    mt1 <- file.info(ts1)$mtime
    timings <-
        merge(data.frame(Package = sub("\\.ts0$", "", basename(ts0)),
                         mt0 = mt0, stringsAsFactors = FALSE),
              data.frame(Package = sub("\\.ts1$", "", basename(ts1)),
                         mt1 = mt1, stringsAsFactors = FALSE))
    sprintf("%s %f", timings$Package, timings$mt1 - timings$mt0)
}

install_packages_with_timings <-
function(pnames, available, libdir, Ncpus = 1)
{
    ## If we only wanted to copy the CRAN install logs, we could record
    ##    the ones needed here, e.g. via
    ##    ilogs <- paste0(pnames, "_i.out")
    
    ## Use make -j for this.
    
    tmpd <- tempfile()
    dir.create(tmpd)
    conn <- file(file.path(tmpd, "Makefile"), "wt")

    ## Want to install the given packages and their available
    ## dependencies including Suggests.
    pdepends <- tools::package_dependencies(pnames, available,
                                            which = "most")
    pnames <- unique(c(pnames,
                       intersect(unlist(pdepends[pnames],
                                        use.names = FALSE),
                                 rownames(available))))
    ## Need to install these and their recursive dependencies.
    pdepends <- tools::package_dependencies(rownames(available),
                                            available,
                                            recursive = TRUE)
    ## Could also use utils:::.make_dependency_list(), which is a bit
    ## faster (if recursive = TRUE, this drops base packages).
    pnames <- unique(c(pnames,
                       intersect(unlist(pdepends[pnames],
                                        use.names = FALSE),
                                 rownames(available))))
    ## Drop base packages from the dependencies.
    pdepends <- lapply(pdepends, setdiff,
                       tools:::.get_standard_package_names()$base)

    cmd0 <- sprintf("env MAKEFLAGS= R_LIBS=%s %s %s CMD INSTALL --pkglock",
                    shQuote(libdir),
                    xvfb_run,
                    shQuote(file.path(R.home("bin"), "R")))
    deps <- paste(paste0(pnames, ".ts1"), collapse = " ")
    deps <- strwrap(deps, width = 75, exdent = 2)
    deps <- paste(deps, collapse=" \\\n")
    cat("all: ", deps, "\n", sep = "", file = conn)
    verbose <- interactive()
    for(p in pnames) {
        cmd <- paste(cmd0,
                     available[p, "Iflags"],
                     shQuote(available[p, "Path"]),
                     ">", paste0(p, "_i.out"),
                     "2>&1")
        deps <- pdepends[[p]]
        deps <- if(length(deps))
            paste(paste0(deps, ".ts1"), collapse=" ") else ""
        cat(paste0(p, ".ts1: ", deps),
            if(verbose) {
                sprintf("\t@echo begin installing package %s",
                    sQuote(p))
            },
            sprintf("\t@touch %s.ts0", p),
            sprintf("\t@-%s", cmd),
            sprintf("\t@touch %s.ts1", p),
            "",
            sep = "\n", file = conn)
    }
    close(conn)

    cwd <- setwd(tmpd)
    on.exit(setwd(cwd))

    system2(Sys.getenv("MAKE", "make"),
            c("-k -j", Ncpus))

    ## Copy the install logs.
    file.copy(Sys.glob("*_i.out"), cwd)

    ## This does not work:
    ##   cannot rename file ........ reason 'Invalid cross-device link'
    ## ## Move the time stamps.
    ## ts0 <- Sys.glob("*.ts0")
    ## file.rename(ts0,
    ##             file.path(cwd,
    ##                       sub("\\.ts0$", "", ts0),
    ##                       ".install_timestamp"))

    ## Compute and return install timings.
    timings <- format_timings_from_ts0_and_ts1(tmpd)

    timings
}

check_packages_with_timings <-
function(pnames, available, libdir, Ncpus = 1, make = FALSE)
{
    if(make)
        check_packages_with_timings_via_make(pnames, available,
                                             libdir, Ncpus)
    else
        check_packages_with_timings_via_fork(pnames, available,
                                             libdir, Ncpus)
}

check_packages_with_timings_via_fork <-
function(pnames, available, libdir, Ncpus = 1)
{
    ## Use mclapply() for this.

    verbose <- interactive()

    do_one <- function(pname, available, libdir) {
        if(verbose) message(sprintf("checking %s ...", pname))
        ## Do not use stdout/stderr ...
        system.time(system2(file.path(R.home("bin"), "R"),
                            c("CMD", "check",
                              "-l", shQuote(libdir),
                              available[pname, "Cflags"],
                              pname),
                            stdout = FALSE, stderr = FALSE,
                            env =
                            c(sprintf("R_LIBS=%s", shQuote(libdir)),
                              "_R_CHECK_LIMIT_CORES_=true")
                            ))
    }

    timings <- parallel::mclapply(pnames, do_one, available,
                                  libdir, mc.cores = Ncpus)
    timings <- sprintf("%s %f", pnames, sapply(timings, `[[`, 3L))

    timings
}

check_packages_with_timings_via_make <-
function(pnames, available, libdir, Ncpus = 1)
{
    verbose <- interactive()

    ## Write Makefile for parallel checking.
    con <- file("Makefile", "wt")
    ## Note that using $(shell) is not portable:
    ## Alternatively, compute all sources from R and write them out.
    ## Using
    ##   SOURCES = `ls *.in`
    ## does not work ...
    lines <-
        c("SOURCES = $(shell ls *.in)",
          "OBJECTS = $(SOURCES:.in=.ts1)",
          ".SUFFIXES:",
          ".SUFFIXES: .in .ts1",
          "all: $(OBJECTS)",
          ".in.ts1:",
          if(verbose)
          "\t@echo checking $* ...",
          "\t@touch $*.ts0",
          ## <FIXME>
          ## As of Nov 2013, the Xvfb started from check-R-ng keeps
          ## crashing [not entirely sure what from].
          ## Hence, fall back to running R CMD check inside xvfb-run.
          ## Should perhaps make doing so controllable ...
          sprintf("\t@-R_LIBS=%s _R_CHECK_LIMIT_CORES_=true %s %s CMD check -l %s $($*-cflags) $* >$*_c.out 2>&1",
                  shQuote(libdir),
                  xvfb_run,
                  shQuote(file.path(R.home("bin"), "R")),
                  shQuote(libdir)),
          ## </FIXME>
          "\t@touch $*.ts1",
          sprintf("%s-cflags = %s",
                  pnames,
                  available[pnames, "Cflags"]))
    writeLines(lines, con)
    close(con)

    file.create(paste0(pnames, ".in"))

    system2(Sys.getenv("MAKE", "make"),
            c("-k -j", Ncpus))

    ## Compute check timings.
    timings <- format_timings_from_ts0_and_ts1(getwd())
    
    ## Clean up (should this use wildcards?)
    file.remove(c(paste0(pnames, ".in"),
                  paste0(pnames, ".ts0"),
                  paste0(pnames, ".ts1"),
                  "Makefile"))

    timings
}

check_args_db_from_stoplist_sh <-
function()
{
    x <- system(". ~/lib/bash/check_R_stoplists.sh; set", intern = TRUE)
    x <- grep("^check_args_db_", x, value = TRUE)
    db <- sub("^check_args_db_([^=]*)=(.*)$", "\\2", x)
    db <- sub("'(.*)'", "\\1", db)
    names(db) <-
        chartr("_", ".", sub("^check_args_db_([^=]*)=.*", "\\1", x))
    db
}

## Compute available packages as used for CRAN checking:
## Use CRAN versions in preference to versions from other repositories
## (even if these have a higher version number);
## For now, also exclude packages according to OS requirement: to
## change, drop 'OS_type' from the list of filters below.
filters <- c("R_version", "OS_type", "CRAN", "duplicates")
repos <- check_repository_URLs(check_repository_root)
## Needed for CRAN filtering below.
options(repos = repos)
## Also pass this to the profile used for checking:
Sys.setenv("_CHECK_CRAN_REGULAR_REPOSITORIES_" =
           paste(sprintf("%s=%s", names(repos), repos), collapse = ";"))

curls <- contrib.url(repos)
available <- available.packages(contriburl = curls, filters = filters)
## Recommended packages require special treatment: the versions in the
## version specific CRAN subdirectories are not listed as available.  So
## create the corresponding information from what is installed in the
## system library, and merge this in by removing duplicates (so that for 
## recommended packages we check the highest "available" version, which
## for release/patched may be in the main package area).
installed <- installed.packages(lib.loc = .Library)
ind <- (installed[, "Priority"] == "recommended")
pos <- match(colnames(available), colnames(installed), nomatch = 0L)
nightmare <- matrix(NA_character_, sum(ind), ncol(available),
                    dimnames = list(installed[ind, "Package"],
                                    colnames(available)))
nightmare[ , pos > 0] <- installed[ind, pos]
## Compute where the recommended packages came from.
## Could maybe get this as R_VERSION from the environment.
R_version <- sprintf("%s.%s", R.version$major, R.version$minor)
if(R.version$status == "Patched")
    R_version <- sub("\\.[[:digit:]]*$", "-patched", R_version)
nightmare[, "Repository"] <-
    file.path(repos["CRAN"], "src", "contrib", R_version, "Recommended")

ind <- (!is.na(priority <- available[, "Priority"]) &
        (priority == "recommended"))

available <- 
    rbind(tools:::.remove_stale_dups(rbind(nightmare, available[ind, ])),
          available[!ind, ])

## Paths to package tarballs.
pfiles <- substring(sprintf("%s/%s_%s.tar.gz",
                            available[, "Repository"],
                            available[, "Package"],
                            available[, "Version"]),
                    8L)
available <- cbind(available, Path = pfiles)

## Unpack all CRAN packages to simplify checking via Make.
CRAN <- repos["CRAN"]
ind <- substring(available[, "Repository"], 1L, nchar(CRAN)) == CRAN
results <-
    parallel::mclapply(pfiles[ind],
                       function(p)
                       system2("tar", c("zxf", p),
                               stdout = FALSE, stderr = FALSE),
                       mc.cores = Ncpus)
## <NOTE>
## * Earlier version also installed the CRAN packages from the unpacked
##   sources, to save the resources of the additional unpacking when
##   installing from the tarballs.  This complicates checking (and made
##   it necessary to use an .install_timestamp mechanism to identify
##   files in the unpacked sources created by installation): hence, we
##   no longer do so.
## * We could easily change check_packages_with_timings_via_fork() to
##   use the package tarballs for checking: simply replace 'pname' by
##   'available[pname, "Path"]' in the call to R CMD check.
##   For check_packages_with_timings_via_make(), we would need to change
##   '$*' in the Make rule by something like $(*-path), and add these
##   PNAME-path variables along the lines of adding the PNAME-cflags
##   variables.
## </NOTE>

## Add information on install and check flags.
## Keep things simple, assuming that the check args db entries are one
## of '--install=fake', '--install=no', or a combination of other
## arguments to be used for full installs.
check_args_db <- check_args_db_from_stoplist_sh()
pnames <- rownames(available)[ind]
pnames_using_install_no <-
    intersect(names(check_args_db)[check_args_db == "--install=no"],
              pnames)
pnames_using_install_fake <-
    intersect(names(check_args_db)[check_args_db == "--install=fake"],
              pnames)
pnames_using_install_full <-
    setdiff(pnames,
            c(pnames_using_install_no, pnames_using_install_fake))
## For simplicity, use character vectors of install and check flags.
iflags <- character(length(pfiles))
names(iflags) <- rownames(available)
cflags <- iflags
iflags[pnames_using_install_fake] <- "--fake"
## Packages using a full install are checked with '--install=check:OUT',
## where OUT is the full/fake install output file.
## Packages using a fake install are checked with '--install=fake'.
## (Currently it is not possible to re-use the install output file.)
cflags[pnames_using_install_no] <- "--install=no"
cflags[pnames_using_install_fake] <- "--install=fake"
pnames <- intersect(pnames_using_install_full, names(check_args_db))
cflags[pnames] <- sprintf("--install='check:%s_i.out' %s", pnames,
                          check_args_db[pnames])
pnames <- setdiff(pnames_using_install_full, names(check_args_db))
cflags[pnames] <- sprintf("--install='check:%s_i.out'", pnames)
## Now add install and check flags to available db.
available <- cbind(available, Iflags = iflags, Cflags = cflags)

## Should already have been created by the check-R-ng shell code.
if(!utils::file_test("-d", libdir)) dir.create(libdir)

## For testing purposes:
## pnames <-
##     c(head(pnames_using_install_full, 50),
##       pnames_using_install_fake,
##       pnames_using_install_no)
pnames <-
    c(pnames_using_install_full,
      pnames_using_install_fake,
      pnames_using_install_no)

timings <- 
    install_packages_with_timings(setdiff(pnames,
                                          pnames_using_install_no),
                                  available,
                                  libdir,
                                  Ncpus)
writeLines(timings, "timings_i.tab")

## Some packages fail when using SNOW to create socket clusters
## simultaneously, with
##   In socketConnection(port = port, server = TRUE, blocking = TRUE,  :
##     port 10187 cannot be opened
## These must be checked serially (or without run time tests).
pnames_to_be_checked_serially <-
    c("MSToolkit", "MSwM", "NHPoission", "gdsfmt",
      "geneSignatureFinder", "simFrame", "snowFT")

timings <- 
    check_packages_with_timings(setdiff(pnames,
                                        pnames_to_be_checked_serially),
                                available, libdir, Ncpus,
                                check_packages_via_parallel_make)
if(length(pnames_to_be_checked_serially)) {
    timings <-
        c(timings,
          check_packages_with_timings(intersect(pnames,
                                                pnames_to_be_checked_serially),
                                      available, libdir, 1,
                                      check_packages_via_parallel_make))

}
writeLines(timings, "timings_c.tab")

## Copy the package DESCRIPTION metadata over to the directories with
## the check results.
dpaths <- file.path(sprintf("%s.Rcheck", pnames), "00package.dcf")
invisible(file.copy(file.path(pnames, "DESCRIPTION"), dpaths))
Sys.chmod(dpaths, "644")                # Avoid rsync permission woes.

## Summaries.

## Source to get check_flavor_summary() and check_details_db().
source(file.path(R_scripts_dir, "check.R"))

cwd <- getwd()

## Check summary.
summary <- as.matrix(check_flavor_summary(check_dirs_root = cwd))
## Change NA priority to empty.
summary[is.na(summary)] <- ""
## Older versions also reported all packages with NOTEs as OK.
## But why should we not want to see new NOTEs?
write.csv(summary,
          file = "summary.csv", quote = 4L, row.names = FALSE)

## Check details.
dir <- dirname(cwd)
details <- check_details_db(dirname(dir), basename(dir), drop_ok = NA)
write.csv(details[c("Package", "Version", "Check", "Status")],
          file = "details.csv", quote = 3L, row.names = FALSE)
## Also saveRDS details without flavor column and and ok results left in
## from drop_ok = NA (but keep ok stubs).
details <-
    details[(details$Check == "*") |
                is.na(match(details$Status,
                            c("OK", "NONE", "SKIPPED"))), ]
details$Flavor <- NULL
saveRDS(details, "details.rds")

## Check timings.
timings <- merge(read.table(file.path(cwd, "timings_i.tab")),
                 read.table(file.path(cwd, "timings_c.tab")),
                 by = 1L, all = TRUE)
names(timings) <- c("Package", "T_install", "T_check")
timings$"T_total" <-
    rowSums(timings[, c("T_install", "T_check")], na.rm = TRUE)
write.csv(timings,
          file = "timings.csv", quote = FALSE, row.names = FALSE)
