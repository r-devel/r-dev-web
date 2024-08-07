Sys.setenv(R_BIOC_VERSION="3.13")
options(BioC_mirror="http://bioconductor.org")

setRepositories(ind=2:4)
repos <- getOption("repos")
repos[1] <- "file:///data/blackswan/ripley/R/packages/BioC/3.13"
options(repos = repos, timeout = 1200)

args <- commandArgs()[-(1:3)]
foo <- if(la <- length(args)) {
	    if(la == 1L) {
		            if(file.exists(args)) readLines(args) else args
    } else args
} else row.names(installed.packages(.libPaths()[1L]))

#foo <- setdiff(foo, c("Rgraphviz", "Rhdf5lib"))

Sys.setenv(DISPLAY = ':5',
           TMPDIR = "/data/blackswan/ripley/R/packages/BioC/3.13/tmp",
           RMPI_TYPE = "OPENMPI",
           RMPI_INCLUDE = "/usr/include/openmpi-x86_64",
           RMPI_LIB_PATH = "/usr/lib64/openmpi/lib")

ddir <- '~/R/packages/BioC/3.13/tmp/downloaded_packages'
dir.create(ddir, showWarnings = FALSE)
install.packages(foo, Ncpus = 10, destdir=ddir)
unlink(ddir, recursive = TRUE)
