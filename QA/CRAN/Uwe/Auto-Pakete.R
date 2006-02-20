maj.version <- Sys.getenv("maj.version")
if(maj.version == "") stop("env.var maj.version is missing!!!")

source("d:/Rcompile/CRANpkg/make/CRANbinaries.R")
source("d:/Rcompile/CRANpkg/make/CRANcheckSummaryWin.R")
source("d:/Rcompile/CRANpkg/make/maintainers.R")

options(warn=1)

CRANbinaries(srcdir = "d:\\Rcompile\\CRANpkg\\sources",
    cran.url = "http://cran.r-project.org/src/contrib",
    localdir = "d:\\Rcompile\\CRANpkg\\local",
    checkdir = "d:\\Rcompile\\CRANpkg\\check", 
    libdir = "d:\\Rcompile\\CRANpkg\\lib",
    windir = "d:\\Rcompile\\CRANpkg\\win",
    donotcheck = "d:\\Rcompile\\CRANpkg\\make\\DoNotCheck",
    donotcompile = paste("d:\\Rcompile\\CRANpkg\\make\\DoNotCompile", maj.version, sep = ""),
    check = TRUE, check.only = FALSE, upload = TRUE, install.only = FALSE,  # Normal
#    check = TRUE, check.only = TRUE, upload = TRUE, install.only = FALSE,   # check.only
#    check = FALSE, check.only = FALSE, upload = FALSE, install.only = TRUE, # Vorbereitung
#    check = TRUE, check.only = FALSE, upload = FALSE, install.only = FALSE, # erstes build ohne upload
#    check = TRUE, check.only = FALSE, upload = TRUE, install.only = FALSE, rebuild = TRUE,
    putty.PKK = "ThePKKFile",
    server = "TheWebServer...",
    serverdir = "TheServerDir",
    maj.version = maj.version,
    username = "TheUserName", 
#    mailMaintainer = TRUE,
    mailMaintainer = (maj.version == "2.2"),
#    mailMaintainer = FALSE,
    email = "Uwe.Ligges@R-Project.org")


checkSummaryWin(src = "d:\\Rcompile\\CRANpkg\\sources",
        cran = "cran.r-project.org",
        cran.url = "/src/contrib",
        checkLogURL = "./",
        windir = "d:\\Rcompile\\CRANpkg\\win",
        donotcheck = "d:\\Rcompile\\CRANpkg\\make\\DoNotCheck",
        upload = TRUE,
        putty.PKK = "d:\\Rcompile\\CRANpkg\\make\\id_rsa.PPK",
        serverdir = "amadeus.statistik.uni-dortmund.de:/home/ligges/public_html/CRAN/bin/windows/contrib",
        username = "ligges",
        maj.version = c("2.3", "2.2"),
        maj.names = c("R-devel", "R-2.2.1"))

q("no")
