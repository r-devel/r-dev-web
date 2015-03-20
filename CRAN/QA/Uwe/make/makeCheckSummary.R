maj.version <- Sys.getenv("maj.version")
if(maj.version == "") stop("env.var maj.version is missing!!!")

source("d:/Rcompile/CRANpkg/make/CRANcheckSummaryWin.R")
source("d:/Rcompile/CRANpkg/make/maintainers.R")

options(warn=1)

checkSummaryWin(src = "d:\\Rcompile\\CRANpkg\\sources",
        cran = "cran.r-project.org",
        cran.url = "/src/contrib",
        checkLogURL = "./",
        windir = "d:\\Rcompile\\CRANpkg\\win",
        donotcheck = "d:\\Rcompile\\CRANpkg\\make\\config\\DoNotCheck",
        donotchecklong = "d:\\Rcompile\\CRANpkg\\make\\config\\DoNotCheckLong",
    donotcheckvignette = "d:\\Rcompile\\CRANpkg\\make\\config\\DoNotCheckVignette",
    maj.version = c("3.0", "3.1", "3.2"),
    maj.names = c("R-3.0.3", "3.1.3", "R-devel"))
