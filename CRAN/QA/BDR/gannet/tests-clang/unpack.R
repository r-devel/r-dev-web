stoplist <- "RcppOctave"

list_tars <- function(dir='.')
{
    files <- list.files(dir, pattern="\\.tar\\.gz", full.names=TRUE)
    nm <- sub("_.*", "", basename(files))
    data.frame(name = nm, path = files, mtime = file.info(files)$mtime,
               row.names = nm, stringsAsFactors = FALSE)
}

foo1 <- list_tars('../contrib')
foo <- list_tars('../3.1.0/Other')
foo <- rbind(foo, foo1)
tars <- foo[!duplicated(foo$name), ]
nm <- tars$name
time1 <- file.info(tars[, "path"])$mtime
time2 <- file.info(paste0(nm, ".in"))$mtime
unpack <- is.na(time2) | (time1 > time2)
for(i in which(unpack)) {
    if(nm[i] %in% stoplist) next
    cat(nm[i], "\n", sep = "")
    unlink(nm[i], recursive = TRUE)
    system(paste("tar zxf", tars[i, "path"]))
    system(paste("touch -r", tars[i, "path"], paste0(nm[i], ".in")))
}
