files <- list.files("/data/ftp/pub/bdr/noOMP", pattern = "[.]log$", full.names = TRUE)
Package <- sub("[.]log$", "", basename(files))
Versions <- character()
for(f in files) {
    ver <- grep("^[*] this is package", readLines(f), value = TRUE, useBytes = TRUE)
    ver <- sub(".*version ‘([^’]+)’.*", "\\1", ver)
    Versions <- c(Versions, ver)
}
DF <- data.frame(Package = Package,
                  Version = rep_len(NA_character_, length(files)),
                  kind = rep_len("noOMP", length(files)),
                  href = paste0("https://www.stats.ox.ac.uk/pub/bdr/noOMP/", basename(files)),
                  stringsAsFactors = TRUE)
write.csv(DF, "/data/gannet/Rlogs/memtests/noOMP.csv", row.names = FALSE, quote = FALSE)

