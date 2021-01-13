options(available_packages_filters =
     c("R_version", "OS_type", "subarch", "CRAN", "duplicates"))

args <- commandArgs()[-(1:3)]
foo <- if(la <- length(args)) {
    if(la == 1L) {
        if(file.exists(args)) readLines(args) else args
    } else args
} else row.names(installed.packages(.libPaths()[1L]))

foo <- setdiff(foo, c('proj4', 'tiff', 'RcppParallel'))

#options(BioC_mirror="http://mirrors.ebi.ac.uk/bioconductor/")
#options(BioC_mirror="http://bioconductor.statistik.tu-dortmund.de")
options(BioC_mirror = "https://bioconductor.org")
options(timeout = 300)

setRepositories(ind = 1:4)
options(repos = c(getOption('repos'),
		Omegahat = "http://www.omegahat.net/R"))
#        	INLA = 'https://inla.r-inla-download.org/R/stable/'))

Sys.setenv(DISPLAY = ':5', NOAWT = "1", RMPI_TYPE = "OPENMPI",
          RGL_USE_NULL = "true", PG_INCDIR = "libpq",
          JAVA_HOME = "/Users/ripley/jdk11.0.9.1-macos_aarch64/zulu-11.jdk/Contents/Home",
	  ODBC_INCLUDE = "/Users/ripley/Sources/iodbc/include")

opts2 <- list(ROracle = "--fake",
	      rJava = "--configure-args='--disable-jri'",
              udunits2 = "--configure-args='--with-udunits2-lib=/opt/R/arm64/lib'",
	      RVowpalWabbit = "--configure-args='--with-boost=/opt/R/arm64'",
              rgdal = "--configure-args='--with-data-copy --with-proj-data=/usr/local/share/proj'",
              sf = "--configure-args='--with-data-copy --with-proj-data=/usr/local/share/proj'")

install.packages(foo, Ncpus = 10, type="source", INSTALL_opts = opts2)
