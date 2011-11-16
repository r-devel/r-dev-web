cleanupCRANbin <- function(delete = FALSE, 
    srcdir = "d:\\Rcompile\\CRANpkg\\sources",
    checkdir = "d:\\Rcompile\\CRANpkg\\check", 
    windir = "d:\\Rcompile\\CRANpkg\\win",
    olddir = "d:\\Rcompile\\CRANpkg\\old",
    maj.version = maj.version)
{
    windir <- file.path(windir, maj.version, fsep = "\\")
    olddir <- file.path(olddir, maj.version, fsep = "\\")
    srcdir <- file.path(srcdir, maj.version, fsep = "\\")
    checklogpath <- file.path(checkdir, maj.version, fsep = "\\")

    packages <- dir(srcdir, patter = ".tar.gz$")
    pck <- strsplit(unlist(strsplit(packages, ".tar.gz")), "_")
    pcknames <- sapply(pck, "[", 1)

    wincheckdir <- file.path(windir, "check", fsep = "\\")
    wincheckdircont <- dir(wincheckdir, patter = "-check.log$")
    wincheckdirnames <- sapply(strsplit(wincheckdircont, "-check.log"), "[", 1)
    remove1 <- wincheckdircont[!(wincheckdirnames %in% pcknames)]
    if(delete && length(remove1)){
        owd <- setwd(wincheckdir)
        on.exit(setwd(owd))
        file.remove(remove1)
    }

    wincheckdircont2 <- dir(checklogpath, patter = ".Rcheck$")
    wincheckdirnames2 <- sapply(strsplit(wincheckdircont2, ".Rcheck"), "[", 1)
    remove2 <- wincheckdircont2[!(wincheckdirnames2 %in% pcknames)]
    if(delete && length(remove2)){
        setwd(checklogpath)
        unlink(remove2, recursive=TRUE)
    }
    
    return(list(remove1, remove2))
}


cleanupCRANbin(srcdir = "w:\\CRANpkg\\sources",
    checkdir = "w:\\CRANpkg\\check", 
    windir = "w:\\CRANpkg\\win",
    olddir = "w:\\CRANpkg\\old",
    maj.version="2.14")
