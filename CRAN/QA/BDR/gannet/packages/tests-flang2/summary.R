
diff0  <- function(from, to)
{
    clean <- function(txt)
    {
        txt <- grep("^(\\* using R|Time|    libs|  installed size|    lib|    R) ", txt, invert = TRUE, value = TRUE, useBytes = TRUE)
        txt <- grep("^\\* checking (installed package size|for non-standard things|for detritus|LazyData.*OK|loading without being on the library search path)", txt, invert = TRUE, value = TRUE, useBytes = TRUE)
	txt <- grep("^ *<(bytecode|environment):", txt, invert = TRUE, value = TRUE, useBytes = TRUE)
	txt <- grep('[.]rds"[)]$', txt, invert = TRUE, value = TRUE, useBytes = TRUE)
	txt <- grep("^\\* (used|using) (C|Fortran)", txt, invert = TRUE, value = TRUE)
	txt <- grep("^\\* running under", txt, invert = TRUE, value = TRUE)
	txt <- grep("^(\\* R was compiled| *gcc| *clang| *GNU Fortran)", txt, invert = TRUE, value = TRUE)
	txt <- grep("-Wrange-loop-construct", txt, invert = TRUE, value = TRUE)
	txt <- grep("^  Specified C[+][+]", txt, invert = TRUE, value = TRUE)
#        txt <- grep("[*] checking HTML version of manual .* OK", txt, invert = TRUE, value = TRUE)
	txt <- grep("checking startup messages can be suppressed.*OK", txt,
                    invert = TRUE, value = TRUE)
        gsub(" \\[[0-9]+[sm]/[0-9]+[sm]\\]", "", txt, useBytes = TRUE)
    }

    left <- clean(readLines(from, warn = FALSE))
    left <-if(exists('this_c'))
        sub(paste0("tests-", this_c), "tests-clang", left, useBytes = TRUE)
    else 
	sub(paste0("tests-", this), "tests-devel", left, useBytes = TRUE)
    if (this == "MKL")
	left <- sub("/data/gannet2/ripley/R/test-MKL", "/data/gannet/ripley/R/test-dev", left, useBytes = TRUE)
    right <- clean(readLines(to, warn = FALSE))
    if(length(left) != length(right) || !all(left == right)) {
	from
    } else character()
}

diff1  <- function(from, to)
{
    clean <- function(txt)
    {
        txt <- grep("^(\\* using R|Time|    libs|  installed size|    lib|    R)", txt, invert = TRUE, value = TRUE, useBytes = TRUE)
        ## gcc8 has directional quotes
        txt <- grep("^\\* checking (installed package size|for non-standard things|for detritus)", txt, invert = TRUE, value = TRUE, useBytes = TRUE)
	        txt <- grep("^ *<(bytecode|environment):", txt, invert = TRUE, value = TRUE, useBytes = TRUE)
        txt <- grep('[.]rds"[)]$', txt, invert = TRUE, value = TRUE, useBytes = TRUE)
	txt <- grep("^\\* (used|using) (C|Fortran)", txt, invert = TRUE, value = TRUE)
	txt <- grep("^\\* running under", txt, invert = TRUE, value = TRUE)
	txt <- grep("^(\\* R was compiled| *gcc| *clang| *GNU Fortran)", txt, invert = TRUE, value = TRUE)
	txt <- grep("^  Specified C[+][+]", txt, invert = TRUE, value = TRUE)
#        txt <- grep("* checking HTML version of manual ... OK", txt, invert = TRUE, value = TRUE, fixed = TRUE)
        txt <- grep("checking startup messages can be suppressed.*OK", txt,
                    invert = TRUE, value = TRUE)
	gsub(" \\[[0-9]+[sm]/[0-9]+[sm]\\]", "", txt, useBytes = TRUE)
    }

    left <- clean(readLines(from, warn = FALSE))
    left <-if(exists('this_c'))
        sub(paste0("tests-", this_c), "tests-clang", left, useBytes = TRUE)
    else
        sub(paste0("tests-", this), "tests-devel", left, useBytes = TRUE)
    if (this == "MKL")
	 left <- sub("/data/gannet2/ripley/R/test-MKL", "/data/gannet/ripley/R/test-dev", left, useBytes = TRUE)
    right <- clean(readLines(to, warn = FALSE))
    if(length(left) != length(right) || !all(left == right)) {
        cat("\n*** ", from, "\n", sep="")
        writeLines(left, a <- tempfile("Rdiffa"))
        writeLines(right, b <- tempfile("Rdiffb"))
        system(paste("diff -b", shQuote(a), shQuote(b)))
    }
}

pkgdiff <- function(stoplist = NULL, extras = character())
{
    l1 <- Sys.glob("*.out")
    l2 <- Sys.glob(file.path(ref, "*.out"))
    l3 <- basename(l2)
    options(stringsAsFactors = FALSE)
    m <- merge(data.frame(x=l1), data.frame(x=l3, y=l2))[,1]
    if(length(stoplist))
	m <- setdiff(m, paste0(c(readLines(stoplist), extras), ".out"))
    unname(unlist(lapply(m, function(x) diff0(x, file.path(ref, x)))))
}

report <- function(op,extras = character())
{
    l1 <- Sys.glob(file.path(ref, "*.in"))
    l2 <- Sys.glob(file.path(ref, "*.out"))
    if(length(l2) < length(l1)) stop("ref run is incomplete")

    known <- dir(op, patt = "[.]out$")
    known2 <- dir("/data/ftp/pub/bdr/clang16", patt = "[.]out$")
    have <- dir('.', patt = "[.]out$")
    known <- intersect(known, have)

    foo <- pkgdiff("../stoplist3", extras)
    foo1 <- intersect(foo, known)
    file.copy(foo1, op, overwrite = TRUE, copy.date = TRUE)

    foo2 <- sub("[.]out", "", setdiff(known, foo))
    if(length(foo2)) {
        cat("\nRemoving stale:\n")
        cat(strwrap(paste(foo2, collapse = " "), indent = 4L, exdent = 4L),
	    sep = "\n")
	unlink(file.path(op, paste0(foo2, ".out")))
	unlink(file.path(op, paste0(foo2, ".log")))
    }

    foo3 <- setdiff(foo, c(known, known2))
    if(length(foo3)) {
        cat("\nNew:\n")
        cat(strwrap(paste(sub("[.]out", "", foo3), collapse = " "),
       	       	    indent = 4L, exdent = 4L), sep = "\n")
        junk <- lapply(foo3, function(x) diff1(x, file.path(ref, x)))
    }

}
ref <- "../tests-clang"
this <- ""
this_c <- "clang-trunk"
op <- file.path("/data/ftp/pub/bdr", "C23")
#source("pkgdiff2.R")
report(op)
