packages <- sub("\\.Rcheck$", "", dir(".", pattern = "\\.Rcheck$"))
ans <- matrix("", length(packages), 6)
colnames(ans) <- c("Package", "Version", "Priority", "Maintainer", "Status","Comment")
ans[,1] <- packages
rownames(ans) <- packages
for(p in packages) {
    desc <- read.dcf(file.path(p, "DESCRIPTION"), c("Version", "Priority", "Maintainer"))[1L, ]
    ## remove double quotes in Maintainer field
    desc[3] <- gsub('"', "", desc[3])
    ans[p, 2:4] <- desc
    lines <- readLines(file.path(paste(p, "Rcheck", sep="."), "00check.log"), warn=FALSE)
    ans[p, 5] <- if(any(grepl("ERROR$", lines, useBytes=TRUE))) "ERROR" else if(any(grepl("WARNING$", lines, useBytes=TRUE))) "WARN" else "OK"
    ## and check for incomplete files
    if(!any(grepl("^Status: ", lines, useBytes=TRUE))) ans[p, 5] <- "FAIL"
#    if(!any(grepl("^\\* checking PDF version of manual", lines,
#                  useBytes=TRUE))) ans[p, 5] <- "FAIL"
    opts <- grep('^\\* using options', lines, useBytes=TRUE)
    if(length(opts)) {
        opts <- lines[opts[1L]]
        ans[p, 6] <- sub("\\* using options '([^']*)'", "\\1", opts)
    }
}
ans[is.na(ans)] <- ""
ans[,4] <- paste('"', gsub("\n", " ", ans[,4], useBytes=TRUE), '"', sep="")
write.csv(ans, 'check.csv', quote=FALSE, row.names=FALSE)
