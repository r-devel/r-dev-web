Rver <- paste(strsplit(as.character(getRversion()), "\\.")[[1]][1:2], collapse=".")

BioCver <- switch(Rver,
    "3.0" = "2.12",
    "2.15" = "2.11",
    "2.14" = "2.9"
)

options(install.packages.check.source = "no")
options(BioC_mirror=list("Dortmund (Germany)"="http://bioconductor.statistik.tu-dortmund.de"))
options(repos = structure(c(
    "http://www.stats.ox.ac.uk/pub/RWin", 
    file.path("http://bioconductor.statistik.tu-dortmund.de/packages", BioCver, "bioc"), 
    file.path("http://bioconductor.statistik.tu-dortmund.de/packages", BioCver, "data/annotation"), 
    file.path("http://bioconductor.statistik.tu-dortmund.de/packages", BioCver, "data/experiment"), 
    file.path("http://bioconductor.statistik.tu-dortmund.de/packages", BioCver, "extra")
), .Names = c("CRANextra", "BioCsoft", "BioCann", "BioCexp", "BioCextra")))
update.packages(ask=FALSE)

options(repos = structure(c(
    "http://www.stats.ox.ac.uk/pub/RWin", 
    file.path("http://bioconductor.statistik.tu-dortmund.de/packages", BioCver, "bioc")
), .Names = c("CRANextra", "BioCsoft")))
x <- new.packages()
if(length(x)) install.packages(x)
