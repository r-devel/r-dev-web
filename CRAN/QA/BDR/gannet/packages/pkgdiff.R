diff1 <- function(from, to)
{
    clean <- function(txt)
    {
        txt <- grep("^(\\* using R|Time|    libs|  installed size) ", txt, invert = TRUE, value = TRUE, useBytes = TRUE)
        txt <- grep("using platform",  txt, invert = TRUE, value = TRUE, useBytes = TRUE)
        txt <- grep("^\\* checking (installed package size|for non-standard things|for detritus|LazyData.*OK|loading without being on the library search path)", txt, invert = TRUE, value = TRUE, useBytes = TRUE)
	txt <- grep("^ *<(bytecode|environment):", txt, invert = TRUE, value = TRUE, useBytes = TRUE)
	txt <- grep('[.]rds"[)]$', txt, invert = TRUE, value = TRUE, useBytes = TRUE)
	txt <- grep("^\\* (used|using) (C|Fortran)", txt, invert = TRUE, value = TRUE)
	txt <- grep("^\\* running under:", txt, invert = TRUE, value = TRUE)
	txt <- grep("^(\\* R was compiled| *gcc| *clang| *GNU Fortran)", txt, invert = TRUE, value = TRUE)
	txt <- grep("^\\* checking C[+][+] specification", txt, invert = TRUE, value = TRUE)
	txt <- grep("^  Specified C[+][+]", txt, invert = TRUE, value = TRUE)
	#txt <- grep("checking HTML version of manual",txt, invert = TRUE, value = TRUE)
	txt <- grep(" *flang-new", txt, invert = TRUE, value = TRUE)
	txt <- grep("checking startup messages can be suppressed.*OK", txt,
                    invert = TRUE, value = TRUE)
	txt <- gsub("[‘’]", "'", txt)
        gsub(" \\[[0-9]+[sm]/[0-9]+[sm]\\]", "", txt, useBytes = TRUE)
    }

    left <- clean(readLines(from, warn = FALSE))
    if(length(this)) left <- sub(paste0("tests-", this), "tests-devel", left, useBytes = TRUE)
    if(exists('this_c')) left <- sub(paste0("tests-", this_c), "tests-clang", left, useBytes = TRUE)
    right <- clean(readLines(to, warn = FALSE))
    if(length(left) != length(right) || !all(left == right)) {
        cat("\n*** ", from, "\n", sep="")
        writeLines(left, a <- tempfile("Rdiffa"))
        writeLines(right, b <- tempfile("Rdiffb"))
        system(paste("diff -b", shQuote(a), shQuote(b)))
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
