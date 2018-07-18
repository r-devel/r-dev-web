diff1 <- function(from, to)
{
    clean <- function(txt)
    {
        txt <- grep("^(\\* using R|Time|    libs|  installed size) ", txt, invert = TRUE, value = TRUE, useBytes = TRUE)
        txt <- grep("^\\* checking installed package size", txt, invert = TRUE, value = TRUE, useBytes = TRUE)
        gsub(" \\[[0-9]+[sm]/[0-9]+[sm]\\]", "", txt)
    }

    left <- clean(readLines(from, warn = FALSE))
    if(length(this)) left <- sub(paste0("tests-", this), "tests-devel", left)
    right <- clean(readLines(to, warn = FALSE))
    if(length(left) != length(right) || !all(left == right)) {
        cat("\n*** ", from, "\n", sep="")
        writeLines(left, a <- tempfile("Rdiffa"))
        writeLines(right, b <- tempfile("Rdiffb"))
        system(paste("diff -bw", shQuote(a), shQuote(b)))
    }
}

pkgdiff <- function(stoplist = NULL)
{
    l1 <- Sys.glob("*.out")
    l2 <- Sys.glob(file.path(ref, "*.out"))
    l3 <- basename(l2)
    options(stringsAsFactors = FALSE)
    m <- merge(data.frame(x=l1), data.frame(x=l3, y=l2))[,1]
    if(length(stoplist)) m <- setdiff(m, paste0(stoplist, ".out"))
    lapply(m, function(x) diff1(x, file.path(ref, x)))
}
