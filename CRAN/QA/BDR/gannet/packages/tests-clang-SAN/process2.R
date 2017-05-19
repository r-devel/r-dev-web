bpath <- "/data/ftp/pub/bdr/memtests/clang-ASAN"
Package <- list.dirs(bpath, FALSE, FALSE)
Versions <- character()
for(p in Package) {
    f <- file.path(bpath, p, "00check.log")
     if(file.exists(f))
         f <- file.path("/data/gannet/ripley/R/packages/tests-clang-SAN",
                        paste0(p, ".out"))
    ver <- if(file.exists(f)) {
        ver <- grep("^[*] this is package", readLines(f), value = TRUE, useBytes=TRUE)
        sub(".*version ‘([^’]+)’.*", "\\1", ver)
    } else NA_character_
    Versions <- c(Versions, ver)
}
href <- paste0("https://www.stats.ox.ac.uk/pub/bdr/memtests/clang-ASAN/", Package)
DF <- data.frame(Package = Package, Version = Versions,
                 kind = rep_len("clang-ASAN", length(Package)),
                 href = href, stringsAsFactors = TRUE)
write.csv(DF, paste0(bpath, ".csv"), row.names = FALSE, quote = FALSE)

bpath <- "/data/ftp/pub/bdr/memtests/clang-UBSAN"
files <- list.files(bpath, pattern = "[.]Rout$")
dirs <- list.dirs(bpath, FALSE, FALSE)
Package <- c(sub("-Ex[.]Rout$", "", files), dirs)
Versions <- character()
for(p in Package) {
    f <- file.path("/data/gannet/ripley/R/packages/tests-clang-SAN", paste0(p, ".out"))
    ver <- if(file.exists(f)) {
        ver <- grep("^[*] this is package", readLines(f), value = TRUE, useBytes=TRUE)
        sub(".*version ‘([^’]+)’.*", "\\1", ver)
    } else NA_character_
    Versions <- c(Versions, ver)
}
href <- paste0("https://www.stats.ox.ac.uk/pub/bdr/memtests/clang-UBSAN/",
              c(files, dirs))

DF <- data.frame(Package = Package, Version = Versions,
                 kind = rep_len("clang-UBSAN", length(Package)),
                 href = href, stringsAsFactors = TRUE)
DF <- DF[sort.list(Package), ]
write.csv(DF, paste0(bpath, ".csv"), row.names = FALSE, quote = FALSE)

