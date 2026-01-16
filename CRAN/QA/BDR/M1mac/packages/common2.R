options(available_packages_filters =
     c("R_version", "OS_type", "subarch", "CRAN", "duplicates"))

options(BioC_mirror = "https://bioconductor.org")
options(timeout = 300)

Sys.setenv(DISPLAY = ':5', NOAWT = "1", RMPI_TYPE = "OPENMPI",
          RGL_USE_NULL = "true")

opts <-
    list(ROracle = "--fake",
         sf = "--configure-args='--with-data-copy --with-proj-data=/opt/R/arm64/share/proj'"),
         terra = "--configure-args='--with-data-copy --with-proj-data=/opt/R/arm64/share/proj'"),
         vapour = "--configure-args='--with-data-copy --with-proj-data=/opt/R/arm64/share/proj'")
         )


## things not to be updated as source packages
noupdate <- c('INLA')
