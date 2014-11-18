chooseBioCmirror(ind = 3)
setRepositories(ind=2:5)
repos <- getOption("repos")
repos[1] <- "file:///data/blackswan/ripley/R/packages/BioC/3.1"
options(repos = repos)

foo <- row.names(installed.packages(.libPaths()[1]))

Sys.setenv(DISPLAY = ':5',
           TMPDIR = "~/R/packages/BioC/3.1/tmp",
           RMPI_TYPE = "OPENMPI",
           RMPI_INCLUDE = "/usr/include/openmpi-x86_64",
           RMPI_LIB_PATH = "/usr/lib64/openmpi/lib")

install.packages(foo, Ncpus = 30, destdir='~/R/packages/BioC/3.1/tmp/downloaded_packages')
