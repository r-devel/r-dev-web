options(warn=1)

files <- dir(".", patt = "[.]out$")

keep <- paste0(c("kdtools"), ".out")

for (f in files) {
    if (f %in% keep) next
    lines <- readLines(f, warn = FALSE)
    warn <- grep("\\[-W(strict-prototypes|deprecated-non-prototype|literal-conversion|empty-body|format|return-stack-address|sizeof-pointer-div|non-c-typedef-for-linkage|invalid-utf8|unneeded-internal-declaration|c\\+\\+..-attribute-extensions)\\]", lines,
                 useBytes = TRUE)
    ff <- file.path("/data/ftp/pub/bdr/clang15", f)
    if(length(warn)) {
    }
    else if(file.exists(ff)) {
        warn <- grep("\\[-W(strict-prototypes|deprecated-non-prototype)\\]", lines,
                 useBytes = TRUE)
        if(length(warn)) next
        message("removing ", f, " from clang15")
        file.remove(ff)
        fff <- sub("[.]out$", ".log", ff)
        if(file.exists(fff)) file.remove(fff)
    }
}

