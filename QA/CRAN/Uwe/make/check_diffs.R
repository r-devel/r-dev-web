save_results <- function(maj.version, windir = "d:\\Rcompile\\CRANpkg\\win"){
    windir <- file.path(windir, maj.version, fsep="\\")
    if(!file.exists(windir)) shell(paste("mkdir", windir))
    statusdir <- file.path(windir, "stats", fsep="\\")
    if(!file.exists(statusdir)) shell(paste("mkdir", statusdir))
    file.copy(file.path(windir, "Status"), file.path(statusdir, paste("Status", Sys.Date(), sep="_")), overwrite=TRUE)
}


check_results_diffs <- function(maj.version, date.new = Sys.Date(), date.old = Sys.Date()-1, windir = "d:\\Rcompile\\CRANpkg\\win"){
    library("utils")
    windir <- file.path(windir, maj.version, fsep="\\")
    statusdir <- file.path(windir, "stats", fsep="\\")
    stats.new <- read.table(file.path(statusdir, paste("Status", date.new, sep="_")), header=TRUE, as.is=TRUE)[,1:3]
    stats.old <- read.table(file.path(statusdir, paste("Status", date.old, sep="_")), header=TRUE, as.is=TRUE)[,1:3]    
    stats <- merge(stats.new, stats.old, by = "packages", all = TRUE)
    names(stats) <- c("packages", "V_New", "S_New", "V_Old", "S_Old")
    nas <- is.na(stats$S_New == stats$S_Old)
    stats$S <- ifelse(nas | (stats$S_New != stats$S_Old), "*", "") 
    stats$V <- ifelse(nas | (stats$V_New != stats$V_Old), "*", "") 
    stats <- stats[stats$S=="*" | stats$V=="*", c(1,6,7,5,3,4,2)]
    stats <- stats[order(stats[,2], stats[,3]), ]
    nas <- is.na(stats$S_New == stats$S_Old)
    stats <- rbind(stats[!nas,], stats[is.na(stats$S_New),], stats[is.na(stats$S_Old),])
    capture.output(print(stats, row.names = FALSE,  right = FALSE), 
        file = file.path(statusdir, paste("checkdiff-", date.new, "-", date.old, ".txt", sep="")))       
}

#
#check_results_diffs("2.11", date.new = Sys.Date(), date.old = Sys.Date()-26, windir = "z:\\Rcompile\\CRANpkg\\win")
#check_results_diffs("2.12", date.new = Sys.Date(), date.old = Sys.Date()-26, windir = "z:\\Rcompile\\CRANpkg\\win")
#check_results_diffs("2.11", date.new = Sys.Date(), date.old = Sys.Date()-26, windir = "z:\\Rcompile\\CRANpkg\\win64")
