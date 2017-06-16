massageFile <- function(file)
{
    lines <- readLines(file, warn = FALSE)
    head <- gsub("(==[0-9]+==) .*", "\\1", lines[1])
    lines <- lines[-(1:6)]
    l <- grep("HEAP SUMMARY:$", lines, useBytes = TRUE)
    if(length(l) && l[1L] > 2L) lines <- lines[seq_len(l[1L] - 2L)]
    l <- grep("Process terminating", lines, useBytes = TRUE)
    if(length(l) && l[1L] > 2L) lines <- lines[seq_len(l[1L] - 2L)]
    lines <- grep(paste0("^", head), lines, value = TRUE, useBytes = TRUE)
    lines <- grep("Warning: set address range perms", lines,
                  value = TRUE, useBytes = TRUE, invert = TRUE)
    pat <- paste0("packages/tests-vg/",
                  sub("-Ex.Rout$", "", basename(file)),
                  "/")
    if(any(grepl(pat, lines)) ||
       (basename(file) != "ifultools" && any(grepl("ifultools/src", lines)))) {
        ff <- sub("[.]Rcheck/.*", "", file)
        dest <- file.path("/data/ftp/pub/bdr/memtests/valgrind", ff)
        dir.create(dest, showWarnings = FALSE, recursive = TRUE)
        file.copy(paste0(ff, ".Rcheck/00check.log"), dest,
                  overwrite = TRUE, copy.date = TRUE)
        file.copy(file, file.path(dest, basename(file)),
                  overwrite = TRUE, copy.date = TRUE)
    }
    NULL
}

files <- Sys.glob("*.Rcheck/*.Rout")
junk <- sapply(files, massageFile)

massageFile2 <- function(file)
{
    lines <- readLines(file, warn = FALSE)
    head <- gsub("(==[0-9]+==) .*", "\\1", lines[1])
    lines <- lines[-(1:6)]
    l <- grep("HEAP SUMMARY:$", lines, useBytes = TRUE)
    if(length(l) && l[1L] > 2L) lines <- lines[seq_len(l[1L] - 2L)]
    l <- grep("Process terminating", lines, useBytes = TRUE)
    if(length(l) && l[1L] > 2L) lines <- lines[seq_len(l[1L] - 2L)]
    lines <- grep(paste0("^", head), lines, value = TRUE, useBytes = TRUE)
    lines <- grep("Warning: set address range perms", lines,
                  value = TRUE, useBytes = TRUE, invert = TRUE)
    ff <- sub("[.]Rcheck/.*", "", file)
    pat <- paste0("packages/tests-vg/", ff, "/")
    if(any(grepl(pat, lines))) {
        ff <- sub("[.]Rcheck/.*", "", file)
        dest <- file.path("/data/ftp/pub/bdr/memtests/valgrind", ff)
        dir.create(file.path(dest, "tests"),
                             showWarnings = FALSE, recursive = TRUE)
        file.copy(paste0(ff, ".Rcheck/00check.log"), dest,
                  overwrite = TRUE, copy.date = TRUE)
        f2 <- sub(".*[.]Rcheck/", "", file)
        file.copy(file, file.path(dest, f2), overwrite = TRUE, copy.date = TRUE)
    }
    NULL
}
files <- c(Sys.glob("*.Rcheck/tests/*.Rout"),
           Sys.glob("*.Rcheck/tests/*.Rout.fail"))
junk <- sapply(files, massageFile2)

massageFile3 <- function(file)
{
    lines <- readLines(file)
    head <- gsub("(==[0-9]+==) .*", "\\1", lines[1])
    lines <- lines[-(1:6)]
    l <- grep("HEAP SUMMARY:$", lines, useBytes = TRUE)
    if(length(l) && l[1L] > 2L) lines <- lines[seq_len(l[1L] - 2L)]
    l <- grep("Process terminating", lines, useBytes = TRUE)
    if(length(l) && l[1L] > 2L) lines <- lines[seq_len(l[1L] - 2L)]
    lines <- grep(paste0("^", head), lines, value = TRUE, useBytes = TRUE)
    lines <- grep("Warning: set address range perms", lines,
                  value = TRUE, useBytes = TRUE, invert = TRUE)
    ff <- sub("[.]Rcheck/.*", "", file)
    pat <- paste0("packages/tests-vg/", ff, "/")
    if(any(grepl(pat, lines))) {
        ff <- sub("[.]Rcheck/.*", "", file)
        dest <- file.path("/data/ftp/pub/bdr/memtests/valgrind", ff)
        dir.create(dest, showWarnings = FALSE, recursive = TRUE)
        file.copy(paste0(ff, ".Rcheck/00check.log"), dest,
                  overwrite = TRUE, copy.date = TRUE)
        f2 <- sub(".*[.]Rcheck/", "", file)
        file.copy(file, file.path(dest, f2), overwrite = TRUE, copy.date = TRUE)
    }
    NULL
}
files <- c(Sys.glob("*.Rcheck/*.[RSrs]nw.log"),
           Sys.glob("*.Rcheck/*.[RSrs]tex.log"),
	   Sys.glob("*.Rcheck/*.Rmd.log"))
junk <- sapply(files, massageFile3)


for(d in list.dirs('/data/ftp/pub/bdr/memtests/valgrind', TRUE, FALSE))
    Sys.setFileTime(d, file.info(paste0(basename(d), ".Rcheck"))$mtime)
