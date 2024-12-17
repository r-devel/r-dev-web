options(warn = 1L)
dest <- "/data/ftp/pub/bdr/gcc15"
files <- dir(patt = "[.]out$")
for(f in files) {
   if (f %in% c("sparsevb.out", "WeightedTreemaps.out")) next
   d <- file.path(dest, f)
   if(any(grepl("-W(lto|odr)", readLines(f), useBytes = TRUE)))
	file.copy(f, dest, overwrite = TRUE, copy.date = TRUE)
   else if (any(grepl("^ERROR", 
		      readLines(f), useBytes = TRUE)))
        file.copy(f, dest, overwrite = TRUE, copy.date = TRUE)
   else if (file.exists(d)) file.remove(d)
}


