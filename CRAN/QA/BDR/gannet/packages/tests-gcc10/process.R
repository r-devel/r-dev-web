files <- list.files("/data/ftp/pub/bdr/gcc10", pattern = "[.](out|log)$", full.names = TRUE)
junk <- file.copy(basename(files), files, overwrite=TRUE, copy.date = TRUE)
Package <- sub("[.](out|log)$", "", basename(files))
Versions <- character()
for(f in files) {
    ver <- grep("^[*] this is package", readLines(f), value = TRUE)
    ver <- if(length(ver)) sub(".*version ‘([^’]+)’.*", "\\1", ver) else NA
    Versions <- c(Versions, ver)
}
DF <- data.frame(Package = Package, Version = Versions,
                 kind = rep_len("gcc10", length(files)),
                 href = paste0("https://www.stats.ox.ac.uk/pub/bdr/gcc10/", basename(files)),
                 stringsAsFactors = TRUE)
write.csv(DF, "/data/gannet/Rlogs/memtests/gcc10.csv", row.names = FALSE, quote = FALSE)

