Sys.setenv(R_BIOC_VERSION="3.5")
#options(BioC_mirror="https://bioconductor.statistik.tu-dortmund.de")

setRepositories(ind=2:5)
repos <- getOption("repos")
repos[1] <- "file:///data/blackswan/ripley/R/packages/BioC/3.5"
options(repos = repos)

foo <- row.names(installed.packages(.libPaths()[1]))

Sys.setenv(DISPLAY = ':5',
           TMPDIR = "/data/blackswan/ripley/R/packages/BioC/3.5/tmp",
           RMPI_TYPE = "OPENMPI",
           RMPI_INCLUDE = "/usr/include/openmpi-x86_64",
           RMPI_LIB_PATH = "/usr/lib64/openmpi/lib")

ddir <- '~/R/packages/BioC/3.5/tmp/downloaded_packages'
dir.create(ddir, showWarnings = FALSE)
install.packages(foo, Ncpus = 30, destdir=ddir)
unlink(ddir, recursive = TRUE)
