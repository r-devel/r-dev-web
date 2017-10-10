## --------- ASAN part

files <- Sys.glob("*.Rcheck/00check.log")
pat <- '(ASan internal:|^SUMMARY: AddressSanitizer:)'
for(f in files) {
    l <- readLines(f, warn = FALSE)
    ll <- grep(pat, l, value = TRUE, useBytes = TRUE)
    ll <- grep('SUMMARY: AddressSanitizer: (SEGV|bad-fre)', ll, value = TRUE, invert = TRUE)
    if(length(ll)) {
        cat(".")
        ff <- sub("[.]Rcheck/.*", "", f)
        if(ff %in% c("alphashape3d", "icosa", "qpcR", "rgl")) next
	f2 <- dirname(f)
        dir.create(file.path("/data/ftp/pub/bdr/memtests/gcc-ASAN", ff),
                             showWarnings = FALSE, recursive = TRUE)
        file.copy(f, file.path("/data/ftp/pub/bdr/memtests/gcc-ASAN", ff, "00check.log"),
                  overwrite=TRUE, copy.date = TRUE)
    }
}
cat("\n")


files <- Sys.glob("*.Rcheck/tests/*.Rout.fail")
for(f in files) {
    l <- readLines(f, warn = FALSE)
    ll <- grep(pat, l, value = TRUE, useBytes = TRUE)
    ll <- grep('SUMMARY: AddressSanitizer: (SEGV|bad-free)', ll, value = TRUE, invert = TRUE)
    if(length(ll)) {
	cat(".")
        ff <- sub("[.]Rcheck/.*", "", f)
        dir.create(d <- file.path("/data/ftp/pub/bdr/memtests/gcc-ASAN", ff, "tests"),
                             showWarnings = FALSE, recursive = TRUE)
        f2 <- sub(".*[.]Rcheck/", "", f)
        file.copy(f,file.path("/data/ftp/pub/bdr/memtests/gcc-ASAN", ff, f2), overwrite=TRUE, copy.date = TRUE)
	Sys.setFileTime(d, file.info(dirname(f))$mtime)

    }
}
cat("\n")

files <- c(Sys.glob("*.Rcheck/*.[RSrs]nw.log"),
           Sys.glob("*.Rcheck/*.[RSrs]tex.log"))
for(f in files) {
    l <- readLines(f, warn = FALSE)
    ll <- grep(pat, l, value = TRUE, useBytes = TRUE)
    ll <- grep('SUMMARY: AddressSanitizer: (SEGV|bad-free)', ll, value = TRUE, invert = TRUE)
    if(length(ll)) {
        cat(".")
        ff <- sub("[.]Rcheck/.*", "", f)
        dir.create(file.path("/data/ftp/pub/bdr/memtests/gcc-ASAN", ff),
                             showWarnings = FALSE, recursive = TRUE)
        f2 <- sub(".*[.]Rcheck/", "", f)
        file.copy(f,file.path("/data/ftp/pub/bdr/memtests/gcc-ASAN", ff, f2), overwrite=TRUE, copy.date = TRUE)
    }
}
cat("\n")

for(d in list.dirs('/data/ftp/pub/bdr/memtests/gcc-ASAN', TRUE, FALSE))
    Sys.setFileTime(d, file.info(paste0(basename(d), ".Rcheck"))$mtime)

## --------- UBSAN part

pat <- '(/R-devel/src|downcast of address)'

files <- Sys.glob("*.Rcheck/*.Rout")

for(f in files) {
    l <- readLines(f, warn = FALSE)
    ll <- grep('runtime error:', l, value = TRUE, useBytes = TRUE)
    ll <- grep('(Fortran runtime error|object in runtime error messages)', ll, invert = TRUE, value = TRUE, useBytes = TRUE)
#    ll <- grep('division by zero', ll, invert = TRUE, value = TRUE, useBytes = TRUE)
    ll <- grep(pat, ll, invert = TRUE, value = TRUE, useBytes = TRUE)
    if(length(ll)) {
	cat(".")
        ff <- sub("[.]Rcheck/.*", "", f)
        dest <- file.path("/data/ftp/pub/bdr/memtests/gcc-UBSAN", ff)
        dir.create(dest, showWarnings = FALSE, recursive = TRUE)
        file.copy(paste0(ff, ".Rcheck/00check.log"), dest,
                  overwrite = TRUE, copy.date = TRUE)
        file.copy(f, dest, overwrite = TRUE, copy.date = TRUE)
        Sys.setFileTime(file.path("/data/ftp/pub/bdr/memtests/gcc-UBSAN",
                                  basename(f)), file.info(f)$mtime)
    }
}
cat("\n")

files <- Sys.glob("*.Rcheck/tests/*.Rout")
for(f in files) {
    if(f == "robustbase.Rcheck/tests/tmcd.Rout") next
    l <- readLines(f, warn = FALSE)
    ll <- grep('runtime error:', l, value = TRUE, useBytes = TRUE)
    ll <- grep(pat, ll, invert = TRUE, value = TRUE, useBytes = TRUE)
    if(length(ll)) {
	cat(".")
        ff <- sub("[.]Rcheck/.*", "", f)
        dest <- file.path("/data/ftp/pub/bdr/memtests/gcc-UBSAN", ff)
        dir.create(d <- file.path(dest, "tests"),
                   showWarnings = FALSE, recursive = TRUE)
        file.copy(paste0(ff, ".Rcheck/00check.log"), dest,
                  overwrite = TRUE, copy.date = TRUE)
        f2 <- sub(".*[.]Rcheck/", "", f)
        file.copy(f, file.path(dest, f2), overwrite = TRUE, copy.date = TRUE)
	Sys.setFileTime(d, file.info(dirname(f))$mtime)
    }
}
cat("\n")

files <- c(Sys.glob("*.Rcheck/*.[RSrs]nw.log"),
           Sys.glob("*.Rcheck/*.[RSrs]tex.log"),
           Sys.glob("*.Rcheck/build_vignettes.log"))
for(f in files) {
    l <- readLines(f, warn = FALSE)
    ll <- grep('runtime error:', l, value = TRUE, useBytes = TRUE)
    ll <- grep(pat, ll, invert = TRUE, value = TRUE, useBytes = TRUE)
    if(length(ll)) {
        cat(".")
        ff <- sub("[.]Rcheck/.*", "", f)
        dest <- file.path("/data/ftp/pub/bdr/memtests/gcc-UBSAN", ff)
        dir.create(dest, showWarnings = FALSE, recursive = TRUE)
        file.copy(paste0(ff, ".Rcheck/00check.log"), dest,
                  overwrite = TRUE, copy.date = TRUE)
        f2 <- sub(".*[.]Rcheck/", "", f)
        file.copy(f, file.path(dest, f2), overwrite = TRUE, copy.date = TRUE)
    }
}
cat("\n")


for(d in list.dirs('/data/ftp/pub/bdr/memtests/gcc-UBSAN', TRUE, FALSE))
    Sys.setFileTime(d, file.info(paste0(basename(d), ".Rcheck"))$mtime)


