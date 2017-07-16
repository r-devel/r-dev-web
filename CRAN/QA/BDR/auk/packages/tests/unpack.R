source('../common.R')
source('../list_tars.R')

tars <- foo <- list_tars('../contrib')
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
