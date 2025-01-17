dest <- "../../M1-SAN"
dirs <- dir(pattern = "[.]Rcheck$", include.dirs = TRUE)

for(d in dirs) {
    base <- sub("[.]Rcheck$", "", d)
    if(base %in% c("jqr", "RcppSimdJson", "PSPManalysis")) next
    old <- getwd(); setwd(d)
    patt <-"(00check.log|00install.out|[.]Ex.Rout$|build_vignettes.log|tests)"
    files <-list.files(full.names  = TRUE, recursive =  TRUE, no. = TRUE)
    files <- sub("^[.]/", "", files)
    keep <- character()
    for (f in files) {
        l <- readLines(f, warn = FALSE)
        l <- grep("(AddressSanitizer:|runtime error:)", l, value = TRUE, useBytes = TRUE)
        l <- grep("src/modules/internet/(soc|Rsock).c:", l, value = TRUE, invert = TRUE)
        ## From robustbase
        l <- grep("(## Fortran runtime error:)", l, value = TRUE, invert = TRUE)
        ## fropm round
        l <- grep("nexpected format specifier in printf interceptor", l, value = TRUE, invert = TRUE)
        ## from system ICU, probably via stringi ?
#        l <- grep("libicucore.A.dylib", l, value = TRUE, invert = TRUE)
        if(length(l)) keep <- c(keep, f)
    }
    if(length(keep)) {
        cat(".")
        dd <- file.path("..", dest, base)
        if(!dir.exists(dd)) dir.create(dd)
        file.copy("00check.log", dd, overwrite = TRUE, copy.date = TRUE)
        keep <- setdiff(keep, "00check.log")
        for(f in keep) {
            if(grepl("/", f)) {
                to <- file.path("..", dest, base, dirname(f))
                if(!dir.exists(to)) {
                    dir.create(to, showWarnings = FALSE, recursive = TRUE)
                    dpath <- dirname(f)
                    Sys.setFileTime(to, file.info(dpath)$mtime)
                }
            }
            file.copy(f, file.path(dd, f),
                      overwrite = TRUE, copy.date = TRUE)
        }
    } else {
        dd <- file.path("..", dest, base)
        if(dir.exists(dd)) {
            message("\nremoving ", sQuote(base))
            unlink(dd, recursive = TRUE)
        }
    }

    setwd(old)
}
cat("\n")

for(d in list.dirs(dest, TRUE, FALSE)) {
    dpath <- paste0(basename(d), ".Rcheck")
    if(file.exists(dpath))
         Sys.setFileTime(d, file.info(dpath)$mtime)
}
