source('../common.R')
stoplist <- c(stoplist, noclang, "REBayes", "Rmosek")

list_tars <- function(dir='.')
{
    files <- list.files(dir, pattern="\\.tar\\.gz", full.names=TRUE)
    nm <- sub("_.*", "", basename(files))
    data.frame(name = nm, path = files, mtime = file.info(files)$mtime,
               row.names = nm, stringsAsFactors = FALSE)
}

tars <- foo1 <- list_tars('../contrib')
#foo0 <- list_tars('../contrib/3.4.0/Others')
#foo <- list_tars('../contrib/3.4.0/Recommended')
#foo <- rbind(foo, foo0, foo1)
#tars <- foo[!duplicated(foo$name), ]
nm <- tars$name
time1 <- file.info(tars[, "path"])$mtime
time2 <- file.info(paste0(nm, ".in"))$mtime
unpack <- is.na(time2) | (time1 > time2)

cxx <- readLines("../C++Users")
unpack <- unpack & (nm %in% cxx)

for(i in which(unpack)) {
    if(nm[i] %in% stoplist) next
    cat(nm[i], "\n", sep = "")
    unlink(nm[i], recursive = TRUE)
    system(paste("tar zxf", tars[i, "path"]))
    system(paste("touch -r", tars[i, "path"], paste0(nm[i], ".in")))
}