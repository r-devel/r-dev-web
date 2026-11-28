ex <- dir("/vols/ftp/pub/bdr/donttest", patt = "[.]out")

for(f in ex){
    if(!file.exists(f)) {
## skip archived packages
	next
    }
    if(f == "filteRjsats.out") next
    lines <- readLines(f)
    if(any(grepl("with --run-donttest.*(ERROR|WARNING)", lines, useBytes = TRUE))) {
        file.copy(f, "/vols/ftp/pub/bdr/donttest", overwrite = TRUE, copy.date = TRUE)
    } else if(any(grepl("other directories ... NOTE", lines, useBytes = TRUE))) {
	    ## leave alone
    } else if(any(grepl("non-standard.* NOTE", lines, useBytes = TRUE))) {
            ## leave alone
    } else if(any(grepl("installed.*ERROR", lines, useBytes = TRUE))) {
            ## leave alone
    } else if(any(grepl("examples.*ERROR", lines, useBytes = TRUE))) {
	    ## leave alone
    } else if(any(grepl("FAILURE REPORT", lines, useBytes = TRUE))) {
            ## leave alone
    } else if(any(grepl("Found the following files/directories", lines, useBytes = TRUE))) {

    } else {
        message("removing ", f)
        unlink(file.path("/vols/ftp/pub/bdr/donttest", f))
    }
}
