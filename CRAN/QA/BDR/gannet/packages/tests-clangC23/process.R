files <- list.files("/data/ftp/pub/bdr/C23", pattern = "[.]out$", full.names = TRUE)
Package <- sub("[.]out$", "", basename(files))
Versions <- character()
for(f in files) {
    ver <- grep("^[*] this is package", readLines(f, 20), value = TRUE, useBytes = TRUE)
    ver <- sub(".*version ‘([^’]+)’.*", "\\1", ver)
    Versions <- c(Versions, ver)
}
DF <- data.frame(Package = Package, Version = Versions,
                 kind = rep_len("C23", length(files)),
                 href = paste0("https://www.stats.ox.ac.uk/pub/bdr/C23/", basename(files)),
                 stringsAsFactors = TRUE)
write.csv(DF, "/data/gannet/Rlogs/memtests/C23.csv", row.names = FALSE, quote = FALSE)

