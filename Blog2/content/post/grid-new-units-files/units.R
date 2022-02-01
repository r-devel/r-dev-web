
source("grid-new-units-files/units-src.R")

result <- bench::mark(simple = simpleUnit(), 
                      standard = stdUnit(), 
                      check = FALSE)
result$version <- gsub(" .+", "", paste(getRversion(), result$expression))
saveRDS(result, paste0("grid-new-units-files/units-timing-", getRversion(), ".rds"))
