## Argument handling.
args <- commandArgs(trailingOnly = TRUE)
args <- gsub("_.*", "", basename(args))

## Now build a package db from the source packages in the working
## directory (but only if there is none already).
if(file.exists("PACKAGES")
   || !length(list.files(pattern = "\\.tar\\.gz$"))) {
    dir <- NULL
} else {
    dir <- getwd()
    tools::write_PACKAGES(dir)
    ## on.exit(unlink(file.path(dir, c("PACKAGES", "PACKAGES.gz"))))
    dir <- sprintf("file://%s", dir)
}

## Use default filtering for available packages.
options(available_packages_filters = NULL)

for(a in args)
    install.packages(a, lib = .libPaths()[1L], dependencies = TRUE,
                     contriburl = c(dir, contrib.url(getOption("repos"))))
