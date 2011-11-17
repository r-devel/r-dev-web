source("../tests/exceptions.R")

stoplist <- c(stoplist, # and for 32-bit
              "rggobi", "gcmrec", "magnets", "WMTregions", "beadarrayMSV", "clusterfly",
              "hdf5", "satin",
              "BiGGR") # rsbml
nomulti <- character()

oldtc <- c("GenSA", "OjaNP", "VPdtw", "cda", "crs", "distory", "gmp",
           "kernelPop", "mRm", "maxLinear", "planar", "rmetasim", "zic",
           "rgdal", "rgeos", # need 32-bit external softwware
           "ifa", "isa2", "rjags")
Rcpp <- c("ANN", "GUTS", "KernSmoothIRT", "LaF", "NetworkAnalysis", "RInside",
          "RProtoBuf", "RQuantLib", "RSNNS", "RVowpalWabbit", "Rclusterpp",
          "Rcpp", "RcppArmadillo", "RcppBDT", "RcppClassic", "RcppDE",
          "RcppEigen", "RcppExamples", "RcppGSL", "SBSA", "VIM", "auteur",
          "bcp", "bfa", "bifactorial", "cda", "fdaMixed", "highlight",
          "hyperSpec", "inline", "maxent", "minqa", "multmod", "mvabund",
          "nfda", "orQA", "parser", "phylobase", "planar", "rgam", "rococo",
          "rugarch", "sdcTable", "simFrame", "spacodiR", "termstrc",
          "unmarked", "wordcloud")
oldtc <- c(oldtc, Rcpp)

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

logs <- list.files('.', pattern = "\\.log$")
logs <- logs[logs != "script.log"]
fi <- file.info(logs)
nm <- sub("\\.log$", "", logs)
logs <- data.frame(name = nm, mtime = fi$mtime, stringsAsFactors = FALSE)
old <- nm[! nm %in% c(tars$name, extras)]
for(f in old) {
    cat('removing ', f, '\n', sep='')
    unlink(c(f, Sys.glob(paste(f, ".*", sep=""))), recursive = TRUE)
    unlink(file.path("c:/R/test-2.15", f), recursive = TRUE)
}

# inst <- basename(dirname(Sys.glob(file.path(rlib, "*", "DESCRIPTION"))))

foo <- merge(logs, tars, by='name', all.y = TRUE)
row.names(foo) <- foo$name
keep <- with(foo, mtime.x < mtime.y)
old <- foo[keep %in% TRUE, ]

new <- foo[is.na(foo$mtime.x), ]
nm <- c(row.names(old), row.names(new))
nm <- nm[! nm %in% stoplist]
available <-
    available.packages(contriburl="file:///R/packages/contrib")
nm <- nm[nm %in% rownames(available)]
if(!length(nm)) q('no')
DL <- utils:::.make_dependency_list(nm, available)
nm <- utils:::.find_install_order(nm, DL)

Sys.setenv(R_INSTALL_TAR = "tar.exe",
           R_LIBS = "c:/R/test-2.15;c:/R/BioC-2.9")
for(f in nm) {
    unlink(f, recursive = TRUE)
    system2("tar.exe", c("xf", tars[f, "path"]))
    cat(sprintf('installing %s', f))
    opt <- character()
    if (f %in% biarch) opt <- "--force-biarch"
    if (f %in% multi) opt <- "--merge-multiarch"
    if (f %in% nomulti) opt <- "--no-multiarch"
    args <- c("-f", '"Time %E"',
              "rcmd",
              # if(f %in% oldtc) "/R/Rduo2/bin/i386/rcmd" else "rcmd",
              "INSTALL --pkglock --compact-docs", opt, tars[f, "path"])
    logfile <- paste(f, ".log", sep = "")
    res <- system2("time", args, logfile, logfile, env = '')
    if(res) cat("  failed\n") else cat("\n")
}
