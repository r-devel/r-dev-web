do.one <- function(fn)
{
    lines <- try(readLines(fn, warn=FALSE), silent=TRUE)
    if(inherits(lines, "try-error")) return(NA_real_)
    ul <- grep("^Time", lines, useBytes = TRUE)
    if(length(ul) != 1) return(NA_real_)
    xx <- lines[ul]
    xx <- strsplit(xx, ", ", fixed = TRUE)[[1]][2]
    sum(as.numeric(strsplit(xx, " + ", fixed = TRUE)[[1]]))
}
packages <- sub("\\.Rcheck$", "", dir(".", pattern = "\\.Rcheck$"))
ans <- matrix("", length(packages), 2)
colnames(ans) <- c("Package", "T.total")
ans[,1] <- packages
rownames(ans) <- packages
for(p in packages) ans[p, 2] <- do.one(paste(p, ".out", sep=""))
write.table(ans, "timings.tab", quote=FALSE, row.names=FALSE)
