#! /usr/local/bin/Rscript
p <- file.path("/home/ripley/R/packages/keep", Sys.Date())
dir.create(p)
setwd(file.path("/home/ripley/R/packages", "tests32"))
ff <- system("egrep 'Status.*(ERROR|WARN)' *.out", intern = TRUE)
ff <- sub(":.*$", "", ff)
junk <- file.copy(ff, p, copy.date = TRUE)
ff <- sub("out$", "log", ff)
junk <- file.copy(ff, p, copy.date = TRUE)

p2 <- file.path("/home/ripley/R/packages/keep", Sys.Date() - 1)
z <- suppressWarnings(system(paste("diff -rs", p, p2),  intern = TRUE))
z <- grep("are identical$", z, value = TRUE)
z <- sub("Files ", "", z)
z <- sub(" and.*", "", z)

unlink(z)
