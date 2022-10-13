options(warn=1)

files <- dir(".", patt = "[.]out$")

keep <- paste0(c("kdtools"), ".out")

for (f in files) {
    if (f %in% keep) next
    lines <- readLines(f, warn = FALSE)
    warn <- grep("\\[-W(literal-conversion|empty-body|format|return-stack-address|sizeof-pointer-div|non-c-typedef-for-linkage|invalid-utf8|unneeded-internal-declaration|c\\+\\+..-attribute-extensions)\\]", lines,
                 useBytes = TRUE)
    ff <- file.path("/data/ftp/pub/bdr/clang15", f)
    if(length(warn)) {
        file.copy(f, "/data/ftp/pub/bdr/clang15",
                  overwrite = TRUE, copy.date = TRUE)
         f2 <-  sub("[.]out$", ".log", f)
        file.copy(f2, "/data/ftp/pub/bdr/clang15",
                  overwrite = TRUE, copy.date = TRUE)
    }
    else if(file.exists(ff)) {
        warn <- grep("\\[-W(strict-prototypes|deprecated-non-prototype)\\]", lines,
                 useBytes = TRUE)
        if(length(warn)) next
        message("removing ", f)
        file.remove(ff)
        fff <- sub("[.]out$", ".log", ff)
        if(file.exists(fff)) file.remove(fff)
    }
}

files <- list.files("/data/ftp/pub/bdr/clang15", pattern = "[.](out|log)$", full.names = TRUE)
junk <- file.copy(basename(files), files, overwrite=TRUE, copy.date = TRUE)
Package <- sub("[.](out|log)$", "", basename(files))
Versions <- character()
for(f in files) {
    ver <- grep("^[*] this is package", readLines(f, n=20), value = TRUE)
    ver <- if(length(ver)) sub(".*version ‘([^’]+)’.*", "\\1", ver) else NA
    Versions <- c(Versions, ver)
}
DF <- data.frame(Package = Package, Version = Versions,
                 kind = rep_len("clang15", length(files)),
                 href = paste0("https://www.stats.ox.ac.uk/pub/bdr/clang15/", basename(files)),
                 stringsAsFactors = FALSE)

ind <- is.na(DF$Version)
h <- DF$href[ind]
hh <- sub("[.]log", ".out", h)
ind2 <- match(hh, DF$href)
OK <- !is.na(ind2)
DF$Version[ind][OK]<- DF$Version[ind2[OK]]

write.csv(DF, "/data/gannet/Rlogs/memtests/clang15.csv", row.names = FALSE, quote = FALSE)

