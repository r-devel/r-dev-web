maj.version <- Sys.getenv("maj.version")
if(maj.version == "") stop("env.var maj.version is missing!!!")
source("d:/Rcompile/CRANpkg/make/check_diffs.R")

save_results("2.12")
save_results("2.13")
check_results_diffs("2.12")
check_results_diffs("2.13")


shell(paste("blat d:\\Rcompile\\CRANpkg\\win\\2.12\\stats\\checkdiff-", Sys.Date(), "-", Sys.Date()-1, ".txt ", 
    "-to ligges@statistik.tu-dortmund.de -subject checkdiffs_2.12_", 
    Sys.Date()-1, "_", Sys.Date(), " -f ligges@statistik.tu-dortmund.de", sep=""))
shell(paste("blat d:\\Rcompile\\CRANpkg\\win\\2.13\\stats\\checkdiff-", Sys.Date(), "-", Sys.Date()-1, ".txt ", 
    "-to ligges@statistik.tu-dortmund.de", if(Sys.getenv("Kurt") == "Kurt") " -cc Kurt.Hornik@R-Project.org,Martin.Maechler@R-project.org", " -subject checkdiffs_2.13_", 
    "svn_", R.version[["svn rev"]], "_", Sys.Date()-1, "_", Sys.Date(), " -f ligges@statistik.tu-dortmund.de", sep=""))

#check_results_diffs("2.11", date.old = Sys.Date()-6)
#shell(paste("blat d:\\Rcompile\\CRANpkg\\win\\2.11\\stats\\checkdiff-", Sys.Date(), "-", Sys.Date()-6, ".txt ", 
#    "-to ligges@statistik.tu-dortmund.de", if(Sys.getenv("Kurt") == "Kurt") " -cc Kurt.Hornik@R-Project.org,Martin.Maechler@R-project.org", " -subject checkdiffs_2.11_", 
#    "svn_", R.version[["svn rev"]], "_", Sys.Date()-6, "_", Sys.Date(), " -f ligges@statistik.tu-dortmund.de", sep=""))
