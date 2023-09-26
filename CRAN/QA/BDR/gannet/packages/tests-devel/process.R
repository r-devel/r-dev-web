patt <- "[.]out$"
files <- dir(".", patt = patt)

patt2 <- "(installed.*WARNING|buffer overflow detected)"

gcc_warn <- character()
for (f in files) {
    lines <- readLines(f, warn = FALSE)
    warn <- grepl(patt2, lines, useBytes = TRUE)
    if(any(warn)) {
        ff <- file.path("../tests-clang-keep", f)
        if(file.exists(ff)) {
            lines <- readLines(ff, warn = FALSE)
            warn <- grepl(patt2, lines, useBytes = TRUE)
            if (!any(warn)) gcc_warn <- c(gcc_warn, f)
        }
    }
}
invisible(file.copy(gcc_warn, "/data/ftp/pub/bdr/gcc12", overwrite =  TRUE,
                    copy.date = TRUE))

ff <- list.files("/data/ftp/pub/bdr/gcc12", pattern = patt)

old <- setdiff(ff, gcc_warn)
unlink(file.path("/data/ftp/pub/bdr/gcc12", old))

ff <- list.files("/data/ftp/pub/bdr/gcc12", pattern = patt)
invisible(file.copy(ff, "/data/ftp/pub/bdr/gcc12", overwrite =  TRUE,
                    copy.date = TRUE))


Sys.setlocale("LC_COLLATE", "C") -> junk

files <- list.files("/data/ftp/pub/bdr/gcc12", pattern = patt, full.names = TRUE)
Package <- sub(patt, "", basename(files))
Versions <- character()
for(f in files) {
    ver <- grep("^[*] this is package", readLines(f, 20), value = TRUE)
    ver <- sub(".*version ‘([^’]+)’.*", "\\1", ver)
    if(!length(ver)) ver <- NA_character_
    Versions <- c(Versions, ver)
}
DF <- data.frame(Package = Package,
                 Version = Versions,
                  kind = rep_len("gcc12", length(files)),
                  href = paste0("https://www.stats.ox.ac.uk/pub/bdr/gcc12/", basename(files)),
                  stringsAsFactors = TRUE)

write.csv(DF, "/data/gannet/Rlogs/memtests/gcc12.csv",
          row.names = FALSE, quote = FALSE)

