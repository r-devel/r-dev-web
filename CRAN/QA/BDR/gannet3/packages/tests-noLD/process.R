files <- list.files("/vols/ftp/pub/bdr/noLD", pattern = "[.](out|log)$", full.names = TRUE)
Package <- sub("[.](out|log)$", "", basename(files))
Versions <- character()
for(f in files) {
    f <- sub("log$", "out", f)
    ver <- grep("^[*] this is package", readLines(f, 20), value = TRUE, useBytes = TRUE)
    ver <- sub(".*version ‘([^’]+)’.*", "\\1", ver)
    if(length(ver) == 0L) ver <-NA
    Versions <- c(Versions, ver)
}
DF <- data.frame(Package = Package, Version = Versions,
                 kind = rep_len("noLD", length(files)),
                 href = paste0("https://www.stats.ox.ac.uk/pub/bdr/noLD/", basename(files)),
                 stringsAsFactors = TRUE)
write.csv(DF, "~/Rlogs/memtests/noLD.csv", row.names = FALSE, quote = FALSE)

