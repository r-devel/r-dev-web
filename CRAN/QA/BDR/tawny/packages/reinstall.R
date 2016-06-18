options(available_packages_filters =
     c("R_version", "OS_type", "subarch", "CRAN", "duplicates"))

foo <- row.names(installed.packages(.libPaths()[1]))

#options(BioC_mirror="http://mirrors.ebi.ac.uk/bioconductor/")
options(BioC_mirror="http://bioconductor.statistik.tu-dortmund.de")

setRepositories(ind = c(1:5, 7))
options(repos = c(getOption('repos'),
        INLA = 'https://www.math.ntnu.no/inla/R/stable/'))

Sys.setenv(DISPLAY = ':5', NOAWT = "1", RMPI_TYPE = "OPENMPI",
          RGL_USE_NULL = "true", PG_INCDIR = "libpq")

mosek <- "/opt/mosek/6"
Sys.setenv(MOSEKLM_LICENSE_FILE = "/opt/mosek/6/licenses/mosek.lic",
           PKG_MOSEKHOME = "/opt/mosek/6/tools/platform/osx64x86",
           PKG_MOSEKLIB = "mosek64")

tmp <- "PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/usr/lib/pkgconfig:/Library/Frameworks/GTK+.framework/Resources/lib/pkgconfig"
tmp2 <- "PKG_CONFIG_PATH=/opt/X11/lib/pkgconfig:/usr/local/lib/pkgconfig:/usr/lib/pkgconfig"
opts <- list(RGtk2 = tmp, cairoDevice = tmp, rcqp = tmp, Cairo = tmp2, gdtools = tmp2)

## fail if done with parallel make
ex <- c('nloptr', 'iplots', 'geoBayes', 'RxODE', 'ECOSolveR', "git2r", 'MonetDBLite')
install.packages(ex, Ncpus = 1)
foo <- setdiff(foo, c(ex, "ROracle"))
install.packages(foo, Ncpus = 10, configure.vars = opts)
