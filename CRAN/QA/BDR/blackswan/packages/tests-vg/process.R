bpath <- "/data/ftp/pub/bdr/memtests/valgrind"
files <- list.files(bpath, pattern = "[.]Rout$")
dirs <- list.dirs(bpath, FALSE, FALSE)
Package <- c(sub("-Ex[.]Rout$", "", files), dirs)
Versions <- character()
Versions <- character()
for(p in Package) {
   f <- file.path("/data/blackswan/ripley/R/packages/tests-vg", paste0(p, ".out"))
    ver <- if(file.exists(f)) {
       ver <- grep("^[*] this is package", readLines(f, warn = FALSE),
		   value = TRUE, useBytes = TRUE)
       sub(".*version ‘([^’]+)’.*", "\\1", ver)
    } else NA_character_
    Versions <- c(Versions, ver)
}
href <- paste0("https://www.stats.ox.ac.uk/pub/bdr/memtests/valgrind/",
              c(files, dirs))

DF <- data.frame(Package = Package, Version = Versions,
                 kind = rep_len("valgrind", length(Package)),
                 href = href, stringsAsFactors = TRUE)
DF <- DF[sort.list(Package), ]
write.csv(DF, paste0(bpath, ".csv"), row.names = FALSE, quote = FALSE)

