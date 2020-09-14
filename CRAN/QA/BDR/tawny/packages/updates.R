options(available_packages_filters =
     c("R_version", "OS_type", "subarch", "CRAN", "duplicates"))

source("common.R")
stoplist <- c(stoplist, noinstall)

Sys.setenv(DISPLAY = ':5', NOAWT = "1", RMPI_TYPE = "OPENMPI",
          RGL_USE_NULL = "true", PG_INCDIR = "libpq",
          R_MAX_NUM_DLLS = "150",
	  ODBC_INCLUDE = "/Users/ripley/Sources/iodbc/include")

tmp <- "PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/usr/lib/pkgconfig:/Library/Frameworks/GTK+.framework/Resources/lib/pkgconfig"
tmp2 <- "PKG_CONFIG_PATH=/opt/X11/lib/pkgconfig:/usr/local/lib/pkgconfig:/usr/lib/pkgconfig"
opts <- list(RGtk2 = tmp, cairoDevice = tmp, rcqp = tmp, Cairo = tmp2, gdtools = tmp2)

ex <- c()

chooseBioCmirror(ind=1)
setRepositories(ind = c(1:4))
old <- old.packages()
if(!is.null(old)) {
    old <- setdiff(rownames(old), ex)
    install.packages(old, type = "source", configure.vars = opts)
}
#update.packages(ask=FALSE, configure.vars = opts)

unused <- function() {
    av <- available.packages()
    t1 <- av[, 5:9]
    dim(t1) <- NULL
    t2 <- unlist(strsplit(t1, ", *"))
    t2 <- t2[!is.na(t2)]
    t2 <- t2[nzchar(t2)]
    t2 <- t2[!grepl("^R *\\(", t2)]
    t2 <- sub("\\n", "", t2)
    t2 <- sub(" .*", "", t2)
    t2 <- sub("\\(.*", "", t2)
    t2 <- sort(unique(t2))
    av <- rownames(av)
    setdiff(av, t2)
}

setRepositories(ind=1)
new <- new.packages()
new <- setdiff(new, stoplist)
#new <- new[! new %in% c(stoplist, unused())]
if(length(new)) {
    setRepositories(ind = c(1:4))
    install.packages(new, type = "source", configure.vars = opts)
}
