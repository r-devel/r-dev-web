## keep results for any packages which have been archived
CRAN <- 'file:///data/gannet/ripley/R/packages/contrib'
av <- row.names(available.packages(contriburl = CRAN))
av <- setdiff(av, "rcss")
for(type in c("ASAN")) {
    bpath <- paste0("/data/ftp/pub/bdr/memtests/clang-", type)
    Packages <- list.dirs(bpath, FALSE, FALSE)
    Av <- Packages[Packages %in% av]
    unlink(file.path(bpath, Av), recursive = TRUE)
}

## --------- ASAN part

files <- Sys.glob("*.Rcheck/00check.log")
for(f in files) {
    if(startsWith(f, "sf.Rcheck")) next
    l <- readLines(f, warn = FALSE)
    ll <- grep('(ASan internal:|AddressSanitizer: negative-size-param|SUMMARY: AddressSanitizer: alloc-dealloc-mismatch|SUMMARY: AddressSanitizer: memcpy-param-overlap)', l, value = TRUE, useBytes = TRUE)
    if(length(ll)) {
        cat(".")
        ff <- sub("[.]Rcheck/.*", "", f)
	## if(ff %in% c("alphashape3d", "icosa", "qpcR", "rgl")) next
	f2 <- dirname(f)
        dir.create(file.path("/data/ftp/pub/bdr/memtests/clang-ASAN", ff),
                             showWarnings = FALSE, recursive = TRUE)
        file.copy(f, file.path("/data/ftp/pub/bdr/memtests/clang-ASAN", ff, "00check.log"),
                  overwrite=TRUE, copy.date = TRUE)
    }
}
cat("\n")


files <- Sys.glob("*.Rcheck/tests/*.Rout.fail")
for(f in files) {
    if(startsWith(f, "sf.Rcheck")) next
    l <- readLines(f, warn = FALSE)
    ll <- grep('ASan internal:', l, value = TRUE, useBytes = TRUE)
    if(length(ll)) {
	cat(".")
        ff <- sub("[.]Rcheck/.*", "", f)
        dir.create(d <- file.path("/data/ftp/pub/bdr/memtests/clang-ASAN", ff, "tests"),
                             showWarnings = FALSE, recursive = TRUE)
        f2 <- sub(".*[.]Rcheck/", "", f)
        file.copy(f,file.path("/data/ftp/pub/bdr/memtests/clang-ASAN", ff, f2), overwrite=TRUE, copy.date = TRUE)
	Sys.setFileTime(d, file.info(dirname(f))$mtime)
    }
}
cat("\n")

files <- c(Sys.glob("*.Rcheck/*.[RSrs]nw.log"),
           Sys.glob("*.Rcheck/*.[RSrs]tex.log"),
	   Sys.glob("*.Rcheck/build_vignettes.log"))
for(f in files) {
    l <- readLines(f, warn = FALSE)
    ll <- grep('ASan internal:', l, value = TRUE, useBytes = TRUE)
    if(length(ll)) {
        cat(".")
        ff <- sub("[.]Rcheck/.*", "", f)
        dir.create(file.path("/data/ftp/pub/bdr/memtests/clang-ASAN", ff),
                             showWarnings = FALSE, recursive = TRUE)
        f2 <- sub(".*[.]Rcheck/", "", f)
        file.copy(f,file.path("/data/ftp/pub/bdr/memtests/clang-ASAN", ff, f2),
                  overwrite = TRUE, copy.date = TRUE)
    }
}
cat("\n")

files <- Sys.glob("*.Rcheck/00install.out")
for(f in files) {
    l <- readLines(f, warn = FALSE)
    ll <- grep('(ASan internal:|AddressSanitizer: odr-violation)', l, value = TRUE, useBytes = TRUE)
    ll2 <- grep(': undefined symbol:', l, value = TRUE, useBytes = TRUE)
    ll2 <- grep("Fortran", ll2, invert = TRUE, value = TRUE, useBytes = TRUE)
## seems to be missing -fopemp in link
##    ll2 <- ll2[!all(grepl("omp_in_parallel", ll2, useBytes = TRUE))]
    ll <- c(ll, ll2)
    if(length(ll)) {
        cat(".")
        ff <- sub("[.]Rcheck/.*", "", f)
        dir.create(d <- file.path("/data/ftp/pub/bdr/memtests/clang-ASAN", ff),
                                  showWarnings = FALSE, recursive = TRUE)
        file.copy(f, file.path("/data/ftp/pub/bdr/memtests/clang-ASAN", ff),
			      overwrite = TRUE, copy.date = TRUE)
        file.copy(sub("00install.out", "00check.log", f),
                  file.path("/data/ftp/pub/bdr/memtests/clang-ASAN", ff),
			      overwrite = TRUE, copy.date = TRUE)
        Sys.setFileTime(d, file.info(dirname(f))$mtime)
    }
}
cat("\n")


for(d in list.dirs('/data/ftp/pub/bdr/memtests/clang-ASAN', TRUE, FALSE)) {
    dpath <- paste0(basename(d), ".Rcheck")
    if(file.exists(dpath))
         Sys.setFileTime(d, file.info(dpath)$mtime)
}

