checkSummaryWin <- function(
        src = "d:\\Rcompile\\CRANpkg\\sources",
        cran = "cran.r-project.org",
        cran.url = "/src/contrib",
        checkLogURL = "./",
        windir = "d:\\Rcompile\\CRANpkg\\win",
        donotcheck = "d:\\Rcompile\\CRANpkg\\make\\DoNotCheck",
        upload = TRUE,
        putty.PKK = "ThePKKFiles",
        serverdir = "TheServerDir",
        username = "TheUserName",
        maj.version = c("2.1"),
        maj.names = NULL){

    require(xtable)
    Sys.setlocale("LC_COLLATE", "C")

    system(paste("rsync -rtlzv --delete ", cran, "::CRAN", cran.url, "/Descriptions/*.DESCRIPTION ", 
        file.path(src, "Descriptions", fsep = "\\"), sep=""))
    maintainer <- sapply(strsplit(maintainers(src), " <"), "[", 1)
    maintainer <- data.frame(Package = names(maintainer), Maintainer = maintainer)
    
    cran.url <- paste("http://", cran, cran.url, sep="")
    if(is.null(maj.names)) maj.names <- maj.version
    fields <- c("Package", "Priority")
    globalcon <- url(file.path(cran.url, "PACKAGES"))
    global <-  read.dcf(globalcon, fields = fields)
    close(globalcon)
    donotcheck <- 
        if(file.exists(donotcheck)) 
            scan(donotcheck, what = character(0)) 
        else ""
    global[global[,1] %in% donotcheck, 2] <- "[--install:no]"

    for(i in maj.version){
        pstatus <- read.table(file.path(windir, i, "Status", fsep = "\\"), 
            as.is = TRUE, header = TRUE)
        names(pstatus)[1:2] <- c("Package", i)
        lastpkg <- list.files(file.path(windir, i, "last", fsep = "\\"), pattern = "\.zip$")
        lastpkg <- sapply(strsplit(lastpkg, "_"), "[", 1)

        idx <- which(pstatus[, 2] %in% c("ERROR", "WARNING"))
        idx2 <- which((pstatus[, 2] == "ERROR") & (pstatus[, 1] %in% lastpkg))
        pstatus[idx, 2] <- paste('<a href=\"', checkLogURL, i, "/check/",
              pstatus[idx, 1], '-check.log\">',
              pstatus[idx, 2], "</a>", sep = "")
        if(length(idx2))
            pstatus[idx2, 2] <- paste(pstatus[idx2, 2], 
                '<br><a href=\"', checkLogURL, i, '/last/ReadMe\">Note</a>', sep = "")
        srcdir <- dir(file.path(src, i), pattern="\.tar\.gz$")
        pinfo <- matrix(
            unlist(strsplit(sub(".tar.gz", "", srcdir), "_")), , 2, byrow = TRUE)
        colnames(pinfo) <- c("Package", "Version")
        pinfo <- as.matrix(merge(pinfo, pstatus[,1:2], all = TRUE))
        idx <- which(is.na(pinfo[, i]))
        pinfo[idx, i] <- paste('<a href=\"', checkLogURL, i, 
            '/ReadMe\">ReadMe</a>', sep = "")
        if(exists("results")) 
            results <- as.matrix(
                merge(results, pinfo, by = c("Package", "Version"), all = TRUE))
        else results <- pinfo
    }
    results <- as.matrix(merge(results, global, by = "Package", all.x = TRUE))
    results <- as.matrix(merge(results, pstatus[,c(1,3,4)], by = "Package", all.x = TRUE))
    results <- as.matrix(merge(results, maintainer, by = "Package", all.x = TRUE))

    results <- results[ , 
        c("Package", "Version", "Priority", "Maintainer", maj.version, "insttime", "checktime")]
    colnames(results) <- c("Package", "Version", "Priority / Comment", "Maintainer", 
                            maj.names, "Inst. timing", "Check timing")
    results <- rbind(results, c("SUM", "in hours (!)", "on a Xeon 3.06 GHz", "", rep("", length(maj.version)),
        round(sum(as.numeric(results[,ncol(results)-1]), na.rm = TRUE)/3600, 2), 
        round(sum(as.numeric(results[,ncol(results)]), na.rm = TRUE)/3600, 2)))

    outfile <- file.path(windir, "checkSummaryWin.html", fsep = "\\")
    out <- file(outfile, "w")
    writeLines(c("<html><head>", 
            "<title>CRAN Windows Binaries' Package Check</title>", "</head>",
            "<body>", "<h1>CRAN Windows Binaries' Package Check</h1>",
            "<p>", paste("Last updated on", format(Sys.time())), "<p>"), 
        out)
    print(xtable(results, align = rep(c("r", "l", "r"), c(1, 4 + length(maj.version), 2))), 
        type = "html", file = out, append = TRUE)
    writeLines(c("</body>", "</html>"), out)
    close(out)
    ## Clean up xtable html (remove blanks and 'align="left"' stuff):
    #temp <- readLines(outfile)
    #temp <- gsub("  *", " ", temp)
    #temp <- gsub(" align=\"left\"", "", temp)
    #writeLines(temp, con=outfile)
    if(upload) 
        print(shell(paste("pscp -q -l", username, "-i", putty.PKK, 
            "-batch", outfile, serverdir), intern = TRUE))
    return("finished!")
}
