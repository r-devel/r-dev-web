source("../tests/exceptions.R")

list_tars <- function(dir='.')
{
    files <- list.files(dir, pattern="\\.tar\\.gz", full.names=TRUE)
    nm <- sub("_.*", "", basename(files))
    data.frame(name = nm, path = files, mtime = file.info(files)$mtime,
               row.names = nm, stringsAsFactors = FALSE)
}

foo1 <- list_tars('c:/R/addlibs/dist')
foo <- list_tars('c:/R/packages/contrib')
foo <- rbind(foo1, foo)
tars <- foo[!duplicated(foo$name), ]

available <-
    available.packages(contriburl="file:///R/packages/contrib")
nm <- rownames(available)
nm <- nm[!nm %in% c(stoplist, biarch, multi, nomulti)]

Sys.setenv(R_INSTALL_TAR = "tar.exe",
           R_LIBS = "c:/R/test-2.15;c:/R/BioC-2.9")
install.packages(nm, Ncpus=4, type = 'source',
                 contriburl='file:///R/packages/contrib',
                 INSTALL_opts = '--compact-docs')


for(f in c(biarch, multi, nomulti)) {
    unlink(f, recursive = TRUE)
    system2("tar.exe", c("xf", tars[f, "path"]))
    cat(sprintf('installing %s', f))
    opt <- character()
    if (f %in% biarch) opt <- "--force-biarch"
    if (f %in% multi) opt <- "--merge-multiarch"
    if (f %in% nomulti) opt <- "--no-multiarch"
    args <- c("-f", '"Time %E"',
              "rcmd INSTALL --pkglock --compact-docs", opt, tars[f, "path"])
    logfile <- paste(f, ".log", sep = "")
    res <- system2("time", args, logfile, logfile, env = '')
    if(res) cat("  failed\n") else cat("\n")
}

ex <- dir("/R/addlibs/extras", full.names = TRUE)
for(f in ex)
    system(paste("R CMD INSTALL --compact-docs", shQuote(f)))

