source('../common.R')
stoplist <- c(stoplist, noclang)
source('../list_tars.R')

tars <- foo1 <- list_tars('../contrib')
foo0 <- list_tars('../contrib/3.4.0/Other')
foo <- list_tars('../contrib/3.5.0/Recommended')
foo <- rbind(foo, foo0, foo1)
tars <- foo[!duplicated(foo$name), ]
nm <- tars$name
time1 <- file.info(tars[, "path"])$mtime
time2 <- file.info(paste0(nm, ".in"))$mtime
unpack <- is.na(time2) | (time1 > time2)
for(i in which(unpack)) {
    if(nm[i] %in% stoplist) next
    cat(nm[i], "\n", sep = "")
    unlink(nm[i], recursive = TRUE)
    unlink(paste0(nm[i], ".out"))
    system(paste("tar zxf", tars[i, "path"]))
    system(paste("touch -r", tars[i, "path"], paste0(nm[i], ".in")))
}
