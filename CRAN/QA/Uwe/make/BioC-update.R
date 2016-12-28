Rver <- paste(strsplit(as.character(getRversion()), "\\.")[[1]][1:2], collapse=".")

BioCver <- switch(Rver,
    "3.4" = "3.5",
    "3.3" = "3.4",    
    "3.2" = "3.2"
)

options(install.packages.check.source = "no")
options("install.packages.compile.from.source"="never")

options(BioC_mirror=list("Dortmund (Germany)"="http://bioconductor.statistik.tu-dortmund.de"))
options(repos = structure(c(
    "http://www.stats.ox.ac.uk/pub/RWin", 
    file.path("http://bioconductor.statistik.tu-dortmund.de/packages", BioCver, "bioc"), 
    file.path("http://bioconductor.statistik.tu-dortmund.de/packages", BioCver, "data/annotation"), 
    file.path("http://bioconductor.statistik.tu-dortmund.de/packages", BioCver, "data/experiment"), 
    file.path("http://bioconductor.statistik.tu-dortmund.de/packages", BioCver, "extra")
), .Names = c("CRANextra", "BioCsoft", "BioCann", "BioCexp", "BioCextra")))
op <- old.packages(type="binary")
op

update.packages(ask=FALSE, type="binary")

options(repos = structure(c(
    "http://www.stats.ox.ac.uk/pub/RWin", 
    file.path("http://bioconductor.statistik.tu-dortmund.de/packages", BioCver, "bioc")
), .Names = c("CRANextra", "BioCsoft")))
np <- new.packages()
np

if(length(np)) install.packages(np)


###################

options(install.packages.check.source = "both")
options("install.packages.compile.from.source"="interactive")
op <- old.packages(type="binary")
op

update.packages(ask=FALSE)

np <- new.packages()
np

if(length(np)) install.packages(np)
