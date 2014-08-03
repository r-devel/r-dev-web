files <- Sys.glob("*.Rcheck/00check.log")
for(f in files) {
    l <- readLines(f)
    ll <- grep('(ASan internal:|SUMMARY: AddressSanitizer: alloc-dealloc-mismatch)', l, value = TRUE, useBytes = TRUE)
    if(length(ll)) {
        cat(".")
        ff <- sub("[.]Rcheck/.*", "", f)
	f2 <- dirname(f)
        dir.create(file.path("/data/ftp/pub/bdr/memtests/ASAN", ff),
                             showWarnings = FALSE, recursive = TRUE)
        file.copy(f, file.path("/data/ftp/pub/bdr/memtests/ASAN", ff, "00check.log"), 
                  overwrite=TRUE, copy.date = TRUE)
    }
}
cat("\n")


files <- Sys.glob("*.Rcheck/tests/*.Rout.fail")
for(f in files) {
    l <- readLines(f)
    ll <- grep('ASan internal:', l, value = TRUE, useBytes = TRUE)
    if(length(ll)) {
	cat(".")
        ff <- sub("[.]Rcheck/.*", "", f)
        dir.create(file.path("/data/ftp/pub/bdr/memtests/ASAN", ff, "tests"),
                             showWarnings = FALSE, recursive = TRUE)
        f2 <- sub(".*[.]Rcheck/", "", f)
        file.copy(f,file.path("/data/ftp/pub/bdr/memtests/ASAN", ff, f2), overwrite=TRUE, copy.date = TRUE)
    }
}
cat("\n")

files <- c(Sys.glob("*.Rcheck/*.[RSrs]nw.log"),
           Sys.glob("*.Rcheck/*.[RSrs]tex.log"))
for(f in files) {
    l <- readLines(f)
    ll <- grep('ASan internal:', l, value = TRUE, useBytes = TRUE)
    if(length(ll)) {
        cat(".")
        ff <- sub("[.]Rcheck/.*", "", f)
        dir.create(file.path("/data/ftp/pub/bdr/memtests/ASAN", ff),
                             showWarnings = FALSE, recursive = TRUE)
        f2 <- sub(".*[.]Rcheck/", "", f)
        file.copy(f,file.path("/data/ftp/pub/bdr/memtests/ASAN", ff, f2), overwrite=TRUE, copy.date = TRUE)
    }
}
cat("\n")

for(d in dir('/data/ftp/pub/bdr/memtests/ASAN')) {
    Sys.setFileTime(file.path("/data/ftp/pub/bdr/memtests/ASAN", d),
                    file.info(paste0(d, ".Rcheck"))$mtime)
}

