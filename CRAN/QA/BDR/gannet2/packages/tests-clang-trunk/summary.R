patt <- "[.]out$"
files <- dir(".", patt = patt)

gcc_warn <-  character()
patt1 <- "(installed.*WARN|^Status.*ERROR)"
patt2 <- "installed.*(WARN|ERROR)"
patt3 <- "^Status.*ERROR"
for (f in files) {
    lines <- readLines(f, warn = FALSE)
    warn <- grepl(patt2, lines, useBytes = TRUE)
    err <- grepl(patt3, lines, useBytes = TRUE)
    if(any(warn|err)) {
        ff <- file.path("../tests-clang", f)
        if(file.exists(ff)) {
            lines <- readLines(ff, warn = FALSE)
            we<- grepl(patt1, lines, useBytes = TRUE)
            if (!any(we) || f == "image.dlib.out") {
	    gcc_warn <- c(gcc_warn, f)
	    if(any(warn)) gcc_warn <- c(gcc_warn, sub("out$", "log", f))
	    }
        }
    }
}
#print(gcc_warn)

invisible(file.copy(gcc_warn, "/vols/ftp/pub/bdr/clang23", overwrite =  TRUE,
                    copy.date = TRUE))

ff <- list.files("/vols/ftp/pub/bdr/clang23", pattern = patt)

old <- setdiff(ff, gcc_warn)
old <- c(old, sub("out$", "log", old))
#old <- setdiff(old, c("TBRDist.out", "TBRDist.log", "edgemodelr.out", "edgemodelr.log"))
if(length(old)) print(old)
unlink(file.path("/vols/ftp/pub/bdr/clang23", old))

ff <- list.files("/vols/ftp/pub/bdr/clang23", pattern = patt)
invisible(file.copy(ff, "/vols/ftp/pub/bdr/clang23", overwrite =  TRUE,
                    copy.date = TRUE))

