maj.version <- Sys.getenv("maj.version")
if(maj.version == "") stop("env.var maj.version is missing!!!")

flavour <- paste(
    "R", 
    if(maj.version == "3.3") "-release" else "-devel",
    sep = "")

source("d:/RCompile/CRANguest/make/CRANguest.R")
source("d:/RCompile/CRANguest/make/maintainers.R")

options(warn=1)

CRANguest(
    workdir = file.path("d:\\RCompile\\CRANguest", flavour, fsep="\\"),
    uploaddir = "C:\\Inetpub\\wwwroot",
    maj.version = maj.version,
    mailMaintainer = TRUE,
    email = "Uwe.Ligges@R-Project.org")


q("no")
