patt <- "[.]out$"
files <- dir(".", patt = patt)

patt2 <- "(installed.*WARNING|buffer overflow detected)"
#patt3 <- "#warning before C++23 is a GCC extension"

gcc_warn <- character()
for (f in files) {
    lines <- readLines(f, warn = FALSE)
#    if(any(grepl(patt3, lines, useBytes = TRUE, fixed = TRUE))) next
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
invisible(file.copy(gcc_warn, "/data/ftp/pub/bdr/gcc", overwrite =  TRUE,
                    copy.date = TRUE))

ff <- list.files("/data/ftp/pub/bdr/gcc", pattern = patt)

old <- setdiff(ff, gcc_warn)
unlink(file.path("/data/ftp/pub/bdr/gcc", old))

ff <- list.files("/data/ftp/pub/bdr/gcc", pattern = patt)
invisible(file.copy(ff, "/data/ftp/pub/bdr/gcc", overwrite =  TRUE,
                    copy.date = TRUE))


Sys.setlocale("LC_COLLATE", "C") -> junk

files <- list.files("/data/ftp/pub/bdr/gcc", pattern = patt, full.names = TRUE)
Package <- sub(patt, "", basename(files))
Versions <- character()
for(f in files) {
    ver <- grep("^[*] this is package", readLines(f, 20), value = TRUE)
    ver <- sub(".*version ‘([^’]+)’.*", "\\1", ver)
    if(!length(ver)) ver <- NA_character_
    Versions <- c(Versions, ver)
}
bn <- basename(files)
href <- if(length(bn)) paste0("https://www.stats.ox.ac.uk/pub/bdr/gcc/", bn) else character(0)
DF <- data.frame(Package = Package,
                 Version = Versions,
                 kind = rep_len("gcc", length(files)),
                 href = href,
                 stringsAsFactors = TRUE)

write.csv(DF, "/data/gannet/Rlogs/memtests/gcc.csv",
          row.names = FALSE, quote = FALSE)

