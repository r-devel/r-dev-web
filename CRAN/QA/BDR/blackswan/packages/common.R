CUDA <-c("CARramps", "HiPLARM", "RAppArmor", "RDieHarder", "ROI.plugin.cplex", "ROracle", "RSAP", "Rcplex", "Rhpc", "WideLM", "cplexAPI",  "cudaBayesreg", "gmatrix", "gputools", "magma", "ora", "permGPU", "rJavax", "rpud", "localsolver", "iFes", "kmcudaR")

Windows <- c('BiplotGUI', 'MDSGUI', 'R2MLwiN', 'R2PPT', 'R2wd', 'RPyGeo',
              'RWinEdt', 'blatr', 'excel.link', 'installr', 'spectrino',
              'rzmq', 'RcppAPT', 'caRpools', 'RInno')
stoplist <- c("RcppOctave", "OpenCL", "CARrampsOcl", "gpuR",
              "rLindo", "RQuantLib", "TSMySQL",
	      "sodium", "safer", "homomorpheR", "remoter",
	      "Rmosek", "REBayes",
	      "Boom", "BoomSpikeSlab", "bsts",
	      "RDocumentation", # wipes out ~/.Rprofile
	      "RmecabKo",
	      "littler", "gpuR", "bayesCL", "tesseract", "IRATER")

noinstall <- c("littler", 'Rcriticor', "keyring", "humarray", "s2", "PReMiuM", "AMIAS")

stoplist <- c(stoplist, Windows, CUDA)

#-------------------- functions ---------------------

av <- function()
{
    ## setRepositories(ind = 1) # CRAN
    options(available_packages_filters =
            c("R_version", "OS_type", "CRAN", "duplicates"))
    av <- available.packages()[, c("Package", "Version", "Repository", "NeedsCompilation")]
    av <- as.data.frame(av, stringsAsFactors = FALSE)
    path <- with(av, paste0(Repository, "/", Package, "_", Version, ".tar.gz"))
    av$Repository <- NULL
    av$Path <- sub(".*contrib/", "../contrib/", path)
    av$mtime <- file.info(av$Path)$mtime
    av[order(av$Package), ]
}

### NB: this assumes UTF-8 quotes
get_vers <- function(nm) {
    ## read already-checked versions
    vers <- sapply(nm, function(n) {
        if (file.exists(f <- paste0(n, ".out"))) {
            ver <- grep("^[*] this is package", readLines(f, warn = FALSE),
                        value = TRUE,  useBytes = TRUE)
            if(length(ver)) sub(".*version ‘([^’]+)’.*", "\\1", ver) else "10000.0.0"
        } else "10000.0.0"
    })
    package_version(vers)
}

do_it <- function(stoplist, compilation = FALSE) {
    tars <-  av()
    tars <- tars[!tars$Package %in% stoplist, ]
    if(compilation) tars <- tars[tars$NeedsCompilation %in% "yes", ]
    nm <- tars$Package
    time0 <- file.info(paste0(nm, ".in"))$mtime
    vers <- get_vers(nm)
    unpack <- is.na(time0) | (tars$mtime > time0) | (tars$Version > vers)
    for(i in which(unpack)) {
        if(nm[i] %in% stoplist) next
        cat(nm[i], "\n", sep = "")
        unlink(nm[i], recursive = TRUE)
        unlink(paste0(nm[i], ".out"))
        system(paste("tar -zxf", tars[i, "Path"]))
        system(paste("touch -r", tars[i, "Path"], paste0(nm[i], ".in")))
    }
}
