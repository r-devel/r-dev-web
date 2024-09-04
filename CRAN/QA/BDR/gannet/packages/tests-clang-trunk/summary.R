patt <- "[.]out$"
files <- dir(".", patt = patt)

gcc_warn <- "PRTree.out" #character()
patt1 <- "(installed.*WARN|^Status.*ERROR)"
patt2 <- "installed.*(WARN|ERROR)"
patt3 <- "^Status.*ERROR"
warn18 <- character()
for (f in files) {
    lines <- readLines(f, warn = FALSE)
    warn <- grepl(patt2, lines, useBytes = TRUE)
    err <- grepl(patt3, lines, useBytes = TRUE)
    if(any(warn|err)) {
        ff <- file.path("../tests-clang", f)
        if(file.exists(ff)) {
            lines <- readLines(ff, warn = FALSE)
            we<- grepl(patt1, lines, useBytes = TRUE)
            if (!any(we)) {
	    gcc_warn <- c(gcc_warn, f)
	    if(any(warn)) gcc_warn <- c(gcc_warn, sub("out$", "log", f))
	    }
        }
    }
}
#print(gcc_warn)

invisible(file.copy(gcc_warn, "/data/ftp/pub/bdr/clang19", overwrite =  TRUE,
                    copy.date = TRUE))

ff <- list.files("/data/ftp/pub/bdr/clang19", pattern = patt)

old <- setdiff(ff, gcc_warn)
unlink(file.path("/data/ftp/pub/bdr/clang19", old))

ff <- list.files("/data/ftp/pub/bdr/clang19", pattern = patt)
invisible(file.copy(ff, "/data/ftp/pub/bdr/clang19", overwrite =  TRUE,
                    copy.date = TRUE))

