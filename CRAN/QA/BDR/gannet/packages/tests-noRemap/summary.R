options(warn = 1L)
dest <- "/data/ftp/pub/bdr/noRemap"
files <- dir(patt = "[.]out$")
patt <- " was not declared in this scope"
for(f in files) {
   d <- file.path(dest, f)
   if(any(grepl(patt, readLines(f), useBytes = TRUE)))
	file.copy(f, dest, overwrite = TRUE, copy.date = TRUE)
   else if (file.exists(d)) file.remove(d)
}


