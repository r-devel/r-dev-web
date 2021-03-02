#! /usr/local/bin/Rscript.arm

setwd("~/R/M1mac")

ff <- dir('.', patt="[.]log")
for (f in ff) {
    lines <- readLines(f)
    if(!any(grepl("^ERROR:", lines))) message("no ERROR in ", f)
}

ff <- dir('.', patt="[.]out")
for (f in ff) {
    lines <- readLines(f)
    if(any(grepl("Cairo-based|cairo", lines))) next
    if(!any(grepl("Status.*(ERROR|WARNING)", lines))) message("no ERROR or WARN in ", f)
}
