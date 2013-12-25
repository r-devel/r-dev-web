files <- Sys.glob("*.Rcheck/*.Rout")

for(f in files) {
    l <- readLines(f)
    ll <- grep('runtime error', l, value = TRUE, useBytes = TRUE)
#    ll <- grep('division by zero', ll, invert = TRUE, value = TRUE, useBytes = TRUE)
    ll <- grep('/R-devel/src', ll, invert = TRUE, value = TRUE, useBytes = TRUE)
    if(length(ll)) {
	cat(".")
        file.copy(f, "/data/ftp/pub/bdr/memtests/UBSAN", overwrite=TRUE)
        Sys.setFileTime(file.path("/data/ftp/pub/bdr/memtests/UBSAN",
                                  basename(f)), file.info(f)$mtime)
    }
}
cat("\n")
