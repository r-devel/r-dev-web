options(available_packages_filters =
     c("R_version", "OS_type", "subarch", "CRAN", "duplicates"))

source('common.R')

stoplist <- c(stoplist, CUDA, noclang, noinstall)

mosek <- path.expand("~/Sources/mosek/6")
Sys.setenv(MOSEKLM_LICENSE_FILE = file.path(mosek, "licenses/mosek.lic"),
           PKG_MOSEKHOME = file.path(mosek, "tools/platform/linux64x86"),
           PKG_MOSEKLIB = "mosek64",
	   R_MAX_NUM_DLLS = "150",
           LD_LIBRARY_PATH = file.path(mosek, "tools/platform/linux64x86/bin"))

opts <- list(Rserve = "--without-server",
             udunits2 = "--with-udunits2-include=/usr/include/udunits2")

if(grepl("R-[cf]lang", R.home())) {
    Sys.setenv(PKG_CONFIG_PATH = '/usr/local/clang/lib64/pkgconfig:/usr/local/lib64/pkgconfig:/usr/lib64/pkgconfig',
               JAGS_LIB = '/usr/local/clang/lib64',
               PATH = paste("/usr/local/clang/bin", Sys.getenv("PATH"), sep=":"))
    stoplist <- c(stoplist, noinstall_clang)
}

chooseBioCmirror(ind=1)
setRepositories(ind = c(1:4))
update.packages(ask=FALSE, configure.args = opts)
setRepositories(ind=1)
new <- new.packages()
new <- new[! new %in% stoplist]
if(length(new)) {
    setRepositories(ind = c(1:4))
    install.packages(new, configure.args = opts)
}
