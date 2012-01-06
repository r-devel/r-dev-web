maj.version <- Sys.getenv("maj.version")
if(maj.version == "") stop("env.var maj.version is missing!!!")

source("d:/Rcompile/CRANpkg/make/CRANbinaries.R")
source("d:/Rcompile/CRANpkg/make/CRANcheckSummaryWin.R")
source("d:/Rcompile/CRANpkg/make/maintainers.R")
source("d:/Rcompile/CRANpkg/make/check_diffs.R")

options(warn=1)
mailMaintainer <- Sys.getenv("mailMaintainer")


CRANdependsOnPkg <- CRANbinaries(
    srcdir = "d:\\Rcompile\\CRANpkg\\sources",
    localdir = "d:\\Rcompile\\CRANpkg\\local",
    checkdir = "d:\\Rcompile\\CRANpkg\\check",
    libdir = "d:\\Rcompile\\CRANpkg\\lib",
    windir = "d:\\Rcompile\\CRANpkg\\win",
    olddir = "d:\\Rcompile\\CRANpkg\\old",
    
    donotcompile = paste("d:\\Rcompile\\CRANpkg\\make\\config\\DoNotCompile", maj.version, sep = ""),
    check = TRUE, check.only = FALSE, install.only = FALSE,  # normal
#    check = TRUE, check.only = FALSE, install.only = FALSE, rebuild = TRUE, # prepare
#    check = TRUE, check.only = TRUE, install.only = FALSE,   # check.only
    maj.version = maj.version,
    mailMaintainer = mailMaintainer,# "yes" "error" "no"
    email = "Uwe.Ligges@R-Project.org")


if(length(CRANdependsOnPkg)) 
    CRANbinaries(
        srcdir = "d:\\Rcompile\\CRANpkg\\sources",
        localdir = "d:\\Rcompile\\CRANpkg\\local",
        checkdir = "d:\\Rcompile\\CRANpkg\\check",
        libdir = "d:\\Rcompile\\CRANpkg\\lib",
        windir = "d:\\Rcompile\\CRANpkg\\win",
        olddir = "d:\\Rcompile\\CRANpkg\\old",
    
        donotcompile = paste("d:\\Rcompile\\CRANpkg\\make\\config\\DoNotCompile", maj.version, sep = ""),
        check = TRUE, check.only = FALSE, install.only = FALSE,
        maj.version = maj.version, 
        mailMaintainer = "no", email = "Uwe.Ligges@R-Project.org",
        recursiveChecks = TRUE, recursivePackages = CRANdependsOnPkg)


checkSummaryWin(
    src = "d:\\Rcompile\\CRANpkg\\sources",
    windir = "d:\\Rcompile\\CRANpkg\\win",
    cran = "cran.r-project.org",
    cran.url = "/src/contrib",
    checkLogURL = "./",
    donotcheck = "d:\\Rcompile\\CRANpkg\\make\\config\\DoNotCheck",
    donotchecklong = "d:\\Rcompile\\CRANpkg\\make\\config\\DoNotCheckLong",
    donotcheckvignette = "d:\\Rcompile\\CRANpkg\\make\\config\\DoNotCheckVignette",
    maj.version = c("2.13", "2.14", "2.15"),
    maj.names = c("R-2.13.2", "R-2.14.1", "R-devel"))


save_results(maj.version, windir = "d:\\Rcompile\\CRANpkg\\win")
check_results_diffs(maj.version, windir = "d:\\Rcompile\\CRANpkg\\win")

if(length(CRANdependsOnPkg)){
    shell(paste("blat d:\\Rcompile\\CRANpkg\\win\\", maj.version, "\\stats\\checkdiff-", Sys.Date(), "-", Sys.Date()-1, ".txt", 
        " -to ligges@statistik.tu-dortmund.de", 
        " -subject checkdiffs_", maj.version, "_svn", R.version[["svn rev"]], "_", Sys.Date()-1, "_", Sys.Date(), 
        " -f ligges@statistik.tu-dortmund.de", sep=""))
}
q("no")
