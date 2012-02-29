source("d:/Rcompile/CRANpkg/make/check_diffs.R")

save_results("2.14")
save_results("2.15")
try(check_results_diffs("2.14"))
try(check_results_diffs("2.15"))

shell(paste("blat d:\\Rcompile\\CRANpkg\\win\\2.14\\stats\\checkdiff-", Sys.Date(), "-", Sys.Date()-1, ".txt ", 
    "-to ligges@statistik.tu-dortmund.de -subject checkdiffs_2.14_", 
    Sys.Date()-1, "_", Sys.Date(), " -f ligges@statistik.tu-dortmund.de", sep=""))
shell(paste("blat d:\\Rcompile\\CRANpkg\\win\\2.15\\stats\\checkdiff-", Sys.Date(), "-", Sys.Date()-1, ".txt ", 
    "-to ligges@statistik.tu-dortmund.de", if(Sys.getenv("Kurt") == "Kurt") " -cc Kurt.Hornik@R-Project.org,Martin.Maechler@R-project.org", " -subject checkdiffs_2.15_", 
    "svn_", R.version[["svn rev"]], "_", Sys.Date()-1, "_", Sys.Date(), " -f ligges@statistik.tu-dortmund.de", sep=""))


#check_results_diffs("2.11", date.old = Sys.Date()-6)
#shell(paste("blat d:\\Rcompile\\CRANpkg\\win\\2.11\\stats\\checkdiff-", Sys.Date(), "-", Sys.Date()-6, ".txt ", 
#    "-to ligges@statistik.tu-dortmund.de", if(Sys.getenv("Kurt") == "Kurt") " -cc Kurt.Hornik@R-Project.org,Martin.Maechler@R-project.org", " -subject checkdiffs_2.11_", 
#    "svn_", R.version[["svn rev"]], "_", Sys.Date()-6, "_", Sys.Date(), " -f ligges@statistik.tu-dortmund.de", sep=""))
