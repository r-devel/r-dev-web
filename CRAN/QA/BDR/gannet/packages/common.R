options(repos = c(CRAN="file://data/gannet/ripley/R"))

CUDA <- c("gpuR", "kmcudaR", "permGPU")

stoplist <- c(CUDA,
	      'Rhpc', 'littler', # R as a shared library
	      "REBayes", # reauire Rmosek, hence MOSEK
	      "Rcplex", "ROI.plugin.cplex", # require CPLEX
	      "ROracle", "ora", # reauire Oracle interfaces
	      'N2R', 'sccore', 'leidenAlg', 'pagoda2', 'conos', 'ingres',
	      "RcppAPT", # for systems with APT
	      "caRpools", # requires MAGeCK and bowtie2,
	      #"echo",
	      #"script",
	      "localsolver", # reauires LocalSolver
	      "FlexReg" # excessive installation time
	      )

## all C++ interfaces to external software
noclang <- c("RQuantLib", "opencv", "image.textlinedetector", "tesseract")

stan0 <- c("DCPO", "DeLorean", "MetaStan",  "OncoBayes2", "Rlgt", "YPPE",
	   "baggr", "bayes4psy",  "bayesdfa", "beanz", "bmlm", "cbq",
	   "conStruct",  "dfpk", "eggCounts", "gastempt", "glmmfields",
	   "hBayesDM", "idem", "mrbayes", "pcFactorStan", "publipha", "qmix",
	   "rmdcev",  "rstanemax", "stanette", "rstap", "spsurv",
	   "ssMousetrack", "survHE", "thurstonianIRT",  "visit", "walker")
stan1 <- c("AovBay", "BINtools", "BayesSenMC", "CNVRG", "EpiNow2", "FlexReg", 
"LMMELSM", "MIRES", "PandemicLP", "PoolTestR", "PosteriorBootstrap", 
"ProbReco", "StanMoMo", "TriDimRegression", "YPBP", "bayesGAM", 
"bayesZIB", "bayesbr", "bayesvl", "bellreg", "bistablehistory", 
"bmgarch", "bmggum", "bpcs", "bsem", "epidemia", 
"fishflux", "isotracer", "lgpr", "llbayesireg", "multinma", "psrwe", 
"rater", "rbioacc", "rcbayes", "rmBayes", "ubms")
stan2 <- c("BeeGUTS", "EloSteepness", "MADPop", "MapeBay", "RoBTT",
	  "bayesforecast",  "bmstdr", "disbayes", "fcirt", "geostan",
	  "glmmPen", "historicalborrowlong",  "hwep", "networkscaleup",
	  "pema", "phacking", "prome", "rPBK",  "rbmi", "rts2", "rxode2ll",
	  "rxode2parse", "surveil", "tipsae",  "truncnormbayes", "zoid")

stan0 <- c(stan0, stan1, stan2, 'CoTiMA', 'ctsemOMX')

V8 <- c('V8', 'datapackage.r', 'js', 'lawn', 'rmapshaper', 'shinyjs', 'tableschema.r')
noclang <- c(noclang, V8) 

noinstall <- c(stan0, 'lazyNumbers',  readLines('~/R/packages/noinst'), 'tok', 'string2path')

noinstall_clang <- c('htdp')
noinstall_pat <- c()

noupdate <- c('MSnbase')

#-------------------- functions ---------------------

av <- function(ver = "4.3.0")
{
    ## setRepositories(ind = 1) # CRAN
    options(available_packages_filters =
            c("R_version", "OS_type", "CRAN", "duplicates"))
    av <- available.packages()[, c("Package", "Version", "Repository", "NeedsCompilation", "Suggests")]
    av <- as.data.frame(av, stringsAsFactors = FALSE)
    path <- with(av, paste0(Repository, "/", Package, "_", Version, ".tar.gz"))
    av$Repository <- NULL
    av$Path <- sub(".*contrib/", "../contrib/", path)
    av$mtime <- file.info(av$Path)$mtime
    ans <- av[order(av$Package), ]
    ## Now merge in Recommended packages
    inst <- installed.packages(.Library, priority = "recommended")
    inst <- inst[, c("Package", "Version", "NeedsCompilation")]
    inst <- as.data.frame(inst, stringsAsFactors = FALSE)
    dpath <- file.path("..", "contrib", ver, "Recommended")
    rec <- dir(dpath, patt = "[.]tar[.]gz$")
    rec <- sub("[.]tar[.]gz$", "", rec)
    inst$Version <- sub("[[:alnum:]]*_([0-9_-]*)", "\\1", rec)
    inst$Path <- with(inst, paste0("../contrib/", ver, "/Recommended/",
                                   Package, "_", Version, ".tar.gz"))
    inst$mtime <- file.info(inst$Path)$mtime
    inst$Suggests <- NA_character_
    rec <- ans$Package %in% inst$Package
    rbind(tools:::.remove_stale_dups(rbind(inst, ans[rec, ])), ans[!rec, ])
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

do_it <- function(stoplist, compilation = FALSE, writeVer = FALSE, ...) {
	stoplist <- c(stoplist, "spatstat.core")
    Ver <- R.Version()
    ver <-
        if(Ver$status == "Under development (unstable)") {
            paste(Ver$major, Ver$minor, sep = ".")
        } else if (Ver$status == "Patched") {
	    paste0(Ver$major, ".", substr(Ver$minor, 1, 1), "-patched")
        } else paste(Ver$major, Ver$minor, sep = ".")
    tars <-  av(ver)
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
	if(writeVer) writeLines(tars[i, "Version"], paste0(nm[i], ".ver"))
    }
}


depends_on_BioC <- function()
{
	CRAN <- 'file:///data/gannet/ripley/R/packages/contrib'
        BioC <- "https://bioconductor.org/packages/3.7/bioc/src/contrib"
	available <- available.packages(contriburl = CRAN, filters = list())
        available <- available[!row.names(available) %in% "permGPU", ]
        av2 <- available.packages(BioC)[c('graph', 'Rgraphviz',
					  'BiocGenerics', 'RBGL'), ]
	available <- rbind(available, av2)
	nm <- row.names(available)
	DL <- utils:::.make_dependency_list(nm, available)
	have <- c("R", nm, dir(.Library))
	foo <- lapply(DL, function(x) setdiff(x, have))
	pass <- sort(names(foo)[sapply(foo, length) > 0])
        repeat {
            pass0 <- pass
            have <- c("R", setdiff(nm, pass), dir(.Library))
            foo <- lapply(DL, function(x) setdiff(x, have))
            pass <- sort(names(foo)[sapply(foo, length) > 0])
           if(identical(pass, pass0)) break
        }
        pass
}

