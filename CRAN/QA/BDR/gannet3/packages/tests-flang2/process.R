files <- dir(".", patt = "[.]out$")

for (f in files) {
    lines <- readLines(f, warn = FALSE)
    warn <- grep("\\[-Wbitwise-instead-of-logical|absolute-value\\]", lines,
                 useBytes = TRUE)
    ff <- file.path("/data/ftp/pub/bdr/clang14", f)
    if(length(warn)) {}
    else if(file.exists(ff)) file.remove(ff)
}
