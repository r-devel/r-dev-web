files <- dir(".", patt = "[.]out$")

for (f in files) {
    lines <- readLines(f, warn = FALSE)
    warn <- grep("\\[-Wbitwise-instead-of-logical|absolute-value\\]", lines,
                 useBytes = TRUE)
    ff <- file.path("/data/ftp/pub/bdr/clang14", f)
    if(length(warn))
        file.copy(f, "/data/ftp/pub/bdr/clang14",
                  overwrite = TRUE, copy.date = TRUE)
    else if(file.exists(ff)) file.remove(ff)
}

files <- list.files("/data/ftp/pub/bdr/clang14", pattern = "[.]out$", full.names = TRUE)
Package <- sub("[.]out$", "", basename(files))
Versions <- character()
for(f in files) {
    ver <- grep("^[*] this is package", readLines(f, n=20), value = TRUE)
    ver <- if(length(ver)) sub(".*version ‘([^’]+)’.*", "\\1", ver) else NA
    Versions <- c(Versions, ver)
}

DF <- data.frame(Package = Package,
                 Version = Versions,
                 kind = rep_len("clang14", length(files)),
                 href = paste0("https://www.stats.ox.ac.uk/pub/bdr/clang14/", basename(files), recycle0 = TRUE))

write.csv(DF, "/data/gannet/Rlogs/memtests/clang14.csv", row.names = FALSE, quote = FALSE)
