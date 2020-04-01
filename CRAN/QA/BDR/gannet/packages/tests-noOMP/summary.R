ex <- dir("/data/ftp/pub/bdr/noOMP", patt = "[.]log")

for(f in ex) {
    lines <- readLines(f)
    if(!any(grepl("ERROR:", lines, useBytes = TRUE))) {
        message("removing ", f)
        unlink(file.path("/data/ftp/pub/bdr/noOMP", f))
    }
}
