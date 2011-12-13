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
        maj.version = c("2.13", "2.14"),
        maj.names = c("R-2.13.2", "R-2.14.0"))
