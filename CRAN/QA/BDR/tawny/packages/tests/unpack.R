stoplist <-
    c("BRugs", "CARramps", "HiPLARM", "RAppArmor", "RDieHarder",
      "REBayes", "RMark", "RMongo", "ROracle", "RProtoBuf", "RQuantLib", "RSAP",
      "RVowpalWabbit", "Rcplex", "RcppOctave", "Rmosek", "Rpoppler", "VBmix",
      "WideLM", "cplexAPI", "cudaBayesreg", "gputools", "magma", "ora",
      "pbdMPI","permGPU", "qtbase", "qtpaint", "qtutils", "rLindo", "rpud",
      "sprint",
      "RMySQL", "Causata", "TSMySQL",  "dbConnect"
      )

tars <- dir("../contrib", full = TRUE, pattern = "[.]tar[.]gz$")
nm <- sub("_.*$", "", basename(tars))
time1 <- file.info(tars)$mtime
time2 <- file.info(paste0(nm, ".in"))$mtime
unpack <- is.na(time2) | (time1 > time2)
for(i in which(unpack)) {
    if(nm[i] %in% stoplist) next
    cat(nm[i], "\n", sep = "")
    unlink(nm[i], recursive = TRUE)
    system(paste("tar zxf", tars[i]))
    system(paste("touch -r", tars[i], paste0(nm[i], ".in")))
}
