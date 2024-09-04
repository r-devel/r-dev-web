options(warn = 1L)
dest <- "/data/ftp/pub/bdr/Strict"
files <- dir(patt = "[.]out$")
ex <- c("Rserve")
file <- setdiff(files, paste0(ex, ".out"))
#patt <- "^ERROR: "
patt <- "^ERROR: compilation failed for package"
#patt <- "error: (implicit declaration|'PI' undeclared|.* was not declared in this scope|.* a declaration of .*must be available)"
for(f in files) {
   d <- file.path(dest, f)
   if(any(grepl(patt, readLines(f), useBytes = TRUE)))
	file.copy(f, dest, overwrite = TRUE, copy.date = TRUE)
   else if (file.exists(d)) file.remove(d)
}


