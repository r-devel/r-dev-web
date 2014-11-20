files <- Sys.glob("*.Rcheck/*.Rout")

for(f in files) {
    l <- readLines(f)
    ll <- grep('runtime error', l, value = TRUE, useBytes = TRUE)
#    ll <- grep('division by zero', ll, invert = TRUE, value = TRUE, useBytes = TRUE)
    ll <- grep('(/R-devel/src|downcast of address)', ll, invert = TRUE, value = TRUE, useBytes = TRUE)
    if(length(ll)) {
	cat(".")
        file.copy(f, "/data/ftp/pub/bdr/memtests/UBSAN", overwrite=TRUE, copy.date = TRUE)
        Sys.setFileTime(file.path("/data/ftp/pub/bdr/memtests/UBSAN",
                                  basename(f)), file.info(f)$mtime)
    }
}
cat("\n")

files <- Sys.glob("*.Rcheck/tests/*.Rout")
for(f in files) {
## in comment
    if(f == "robustbase.Rcheck/tests/tmcd.Rout") next
    l <- readLines(f)
    ll <- grep('runtime error', l, value = TRUE, useBytes = TRUE)
    ll <- grep('(/R-devel/src|downcast of address)', ll, invert = TRUE, value = TRUE, useBytes = TRUE)
    if(length(ll)) {
	cat(".")
        ff <- sub("[.]Rcheck/.*", "", f)
        dir.create(file.path("/data/ftp/pub/bdr/memtests/UBSAN", ff, "tests"),
                             showWarnings = FALSE, recursive = TRUE)
        f2 <- sub(".*[.]Rcheck/", "", f)
        file.copy(f,file.path("/data/ftp/pub/bdr/memtests/UBSAN", ff, f2), overwrite=TRUE, copy.date = TRUE)
    }
}
cat("\n")

files <- c(Sys.glob("*.Rcheck/*.[RSrs]nw.log"),
           Sys.glob("*.Rcheck/*.[RSrs]tex.log"))
for(f in files) {
    l <- readLines(f)
    ll <- grep('runtime error', l, value = TRUE, useBytes = TRUE)
    ll <- grep('(/R-devel/src|downcast of address)', ll, invert = TRUE, value = TRUE, useBytes = TRUE)
    if(length(ll)) {
        cat(".")
        ff <- sub("[.]Rcheck/.*", "", f)
        dir.create(file.path("/data/ftp/pub/bdr/memtests/UBSAN", ff),
                             showWarnings = FALSE, recursive = TRUE)
        f2 <- sub(".*[.]Rcheck/", "", f)
        file.copy(f,file.path("/data/ftp/pub/bdr/memtests/UBSAN", ff, f2), overwrite=TRUE, copy.date = TRUE)
    }
}
cat("\n")

for(d in list.dirs('/data/ftp/pub/bdr/memtests/UBSAN', TRUE, FALSE)) {
    Sys.setFileTime(d, file.info(paste0(basename(d), ".Rcheck"))$mtime)
}


