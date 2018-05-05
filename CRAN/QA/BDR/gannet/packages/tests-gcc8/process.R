files <- list.files("/data/ftp/pub/bdr/gcc8", pattern = "[.](out|log)$", full.names = TRUE)
Package <- sub("[.](out|log)$", "", basename(files))
Versions <- character()
for(f in files) {
    ver <- grep("^[*] this is package", readLines(f), value = TRUE)
    ver <- if(length(ver)) sub(".*version ‘([^’]+)’.*", "\\1", ver) else NA
    Versions <- c(Versions, ver)
}
DF <- data.frame(Package = Package, Version = Versions,
                 kind = rep_len("gcc8", length(files)),
                 href = paste0("https://www.stats.ox.ac.uk/pub/bdr/gcc8/", basename(files)),
                 stringsAsFactors = TRUE)
write.csv(DF, "/data/gannet/Rlogs/memtests/gcc8.csv", row.names = FALSE, quote = FALSE)

