files <- list.files("/data/ftp/pub/bdr/Intel", pattern = "[.](out|log)$", full.names = TRUE)
junk <- file.copy(basename(files), files, overwrite=TRUE, copy.date = TRUE)
Package <- sub("[.](out|log)$", "", basename(files))
Versions <- character()
for(f in files) {
    ver <- grep("^[*] this is package", readLines(f, n=20), value = TRUE, useBytes = TRUE)
    ver <- if(length(ver)) sub(".*version ‘([^’]+)’.*", "\\1", ver) else NA
    Versions <- c(Versions, ver)
}
DF <- data.frame(Package = Package, Version = Versions,
                 kind = rep_len("Intel", length(files)),
                 href = paste0("https://www.stats.ox.ac.uk/pub/bdr/Intel/", basename(files)),
                 stringsAsFactors = FALSE)

ind <- is.na(DF$Version)
h <- DF$href[ind]
hh <- sub("[.]log", ".out", h)
ind2 <- match(hh, DF$href)
OK <- !is.na(ind2)
DF$Version[ind][OK]<- DF$Version[ind2[OK]]

write.csv(DF, "/data/gannet/Rlogs/memtests/Intel.csv", row.names = FALSE, quote = FALSE)

