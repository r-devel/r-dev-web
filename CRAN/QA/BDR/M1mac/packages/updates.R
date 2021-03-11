options(available_packages_filters =
     c("R_version", "OS_type", "subarch", "CRAN", "duplicates"))
options(timeout = 300)

source("common.R")
stoplist <- c(stoplist, noinstall)

Sys.setenv(DISPLAY = ':5', NOAWT = "1", RMPI_TYPE = "OPENMPI",
          RGL_USE_NULL = "true", PG_INCDIR = "libpq",
          JAVA_HOME = "/Users/ripley/jdk11.0.9.1-macos_aarch64/zulu-11.jdk/Contents/Home",
	  ODBC_INCLUDE = "/Users/ripley/Sources/iodbc/include")

#tmp <- "PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/usr/lib/pkgconfig:/Library/Frameworks/GTK+.framework/Resources/lib/pkgconfig"
#tmp2 <- "PKG_CONFIG_PATH=/opt/X11/lib/pkgconfig:/usr/local/lib/pkgconfig:/usr/lib/pkgconfig"
#opts <- list(RGtk2 = tmp, cairoDevice = tmp, rcqp = tmp, Cairo = tmp2, gdtools = tmp2)

opts <- list(ROracle = "--fake",
      rJava = "--configure-args='--disable-jri'",
       udunits2 = "--configure-args='--with-udunits2-lib=/opt/R/arm64/lib'",
       RVowpalWabbit = "--configure-args='--with-boost=/opt/R/arm64'")

ex <- c('textshaping') # things not to be updated

chooseBioCmirror(ind=1)
setRepositories(ind = c(1:4))
old <- old.packages()
if(!is.null(old)) {
    old <- setdiff(rownames(old), ex)
    install.packages(old, type = "source", configure.vars = opts)
}
#update.packages(ask=FALSE, configure.vars = opts)

setRepositories(ind=1)
new <- new.packages()
new <- setdiff(new, stoplist)
if(length(new)) {
    setRepositories(ind = c(1:4))
    install.packages(new, type = "source", configure.vars = opts)
}
