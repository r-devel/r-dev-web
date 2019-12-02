options(warn = 1L)
dest <- "/data/ftp/pub/bdr/gcc10"
files <- dir(patt = "[.]log$")
for(f in files) {
   d <- file.path(dest, f)
   if(any(grepl("multiple definition of", readLines(f), useBytes = TRUE)))
	file.copy(f, dest, overwrite = TRUE, copy.date = TRUE)
#   else if (file.exists(d)) file.remove(d)
}


