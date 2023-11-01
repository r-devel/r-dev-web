#! /opt/R/arm64/bin/Rscript

setwd("~/R/M1mac")

ff <- dir('.', patt="[.]log")
for (f in ff) {
    lines <- readLines(f)
    if(any(grepl("[-W", lines, fixed = TRUE))) next
    if(!any(grepl("^ERROR:", lines))) message("no ERROR in ", f)
}

ff <- dir('.', patt="[.]out")
for (f in ff) {
    lines <- readLines(f, warn = FALSE)
    if(any(grepl("Comparing.*Rout.*Rout.save.*[1-9]", lines))) next
    if(any(grepl(" detritus in the temp directory ... NOTE", lines))) next
    if(any(grepl("of manual .* WARNING", lines))) next
    if(any(grepl("examples .* ERROR", lines))) next
    if(!any(grepl("Status.*(ERROR|WARNING)", lines))) message("no ERROR or WARN in ", f)
}
