options(warn = 1L)
dest <- "/data/ftp/pub/bdr/LTO"
files <- dir(patt = "[.]out$")
for(f in files) {
   d <- file.path(dest, f)
   if(any(grepl("-Wlto", readLines(f), useBytes = TRUE))) file.copy(f, dest, overwrite = TRUE)
   else if (file.exists(d)) file.remove(d)
}


