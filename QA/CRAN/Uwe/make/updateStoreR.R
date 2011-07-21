updateStoreR <- 
    function(computer = "\\\\store", 
        location = "C:\\export\\software\\windows\\library\\",
        lib.loc = "t:/library", repos,
        updateonly = FALSE)
{
    options(repos = repos)   
    openfiles <- shell(paste("T:\\smartmontools\\bin\\psfile", computer), wait = TRUE, intern = TRUE, minimize = TRUE)
    if(length(openfiles)){
        openfiles <- grep(location, openfiles, value = TRUE, fixed = TRUE)
    }
    if(length(openfiles)){
        openfiles <- sapply(strsplit(openfiles, location, fixed = TRUE), "[", 2)
        openfiles <- sapply(strsplit(openfiles, "\\", fixed = TRUE), "[", 1)
    }
    if(length(openfiles)){
        openpkg <- unique(openfiles)
    }
    pa <- old.packages(lib.loc = lib.loc)[,1]
    if(!updateonly){
        np <- new.packages(lib.loc = lib.loc)
        pa <- c(pa, np)
    }
    if(length(openfiles))
        pa <- pa[!(pa %in% openpkg)]
    if(length(pa))
        install.packages(pa, lib = lib.loc)
}


updateStoreR(
    repos = c(
        CRAN = "http://www.statistik.tu-dortmund.de/~ligges/CRAN/", 
        CRANextra = "http://www.stats.ox.ac.uk/pub/RWin",
        BioCsoft  = "http://bioconductor.statistik.tu-dortmund.de/packages/2.8/bioc"
    )
)

updateStoreR(
    repos = c(
        CRAN = "http://www.statistik.tu-dortmund.de/~ligges/CRAN/", 
        CRANextra = "http://www.stats.ox.ac.uk/pub/RWin",
        BioCsoft  = "http://bioconductor.statistik.tu-dortmund.de/packages/2.8/bioc",
        BioCann   = "http://bioconductor.statistik.tu-dortmund.de/packages/2.8/data/annotation",
        BioCexp   = "http://bioconductor.statistik.tu-dortmund.de/packages/2.8/data/experiment",
        BioCextra = "http://bioconductor.statistik.tu-dortmund.de/packages/2.8/extra"
    ), updateonly = TRUE)
