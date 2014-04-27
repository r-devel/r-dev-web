options(available_packages_filter =
     c("R_version", "OS_type", "subarch", "CRAN", "duplicates"))

stoplist <-
c("CARramps", "HiPLARM", "DeducerMMR", "RAppArmor", "RDF", "RDieHarder", "RMark", "RMongo", "ROracle", "ROracleUI", "RQuantLib", "RSAP", "RScaLAPACK", "Rcplex", "Rhpc", "Rmosek", "WideLM", "cplexAPI", "cudaBayesreg", "gputools", "magma", "ora", "permGPU", "rJavax", "gmatrix", "rpud", "rscproxy", "Rpoppler", "rLindo")

stoplist <- c(stoplist, "RcppOctave", "OpenCL", "CARrampsOcl")

mosek <- path.expand("~/extras/mosek/6")
Sys.setenv(MOSEKLM_LICENSE_FILE = file.path(mosek, "licenses/mosek.lic"),
           PKG_MOSEKHOME = file.path(mosek, "tools/platform/linux64x86"),
           PKG_MOSEKLIB = "mosek64",
           LD_LIBRARY_PATH = file.path(mosek, "tools/platform/linux64x86/bin"))

setRepositories(ind = c(1:5,7))
update.packages(ask=FALSE)
setRepositories(ind = 1)
new <- new.packages()
new <- new[! new %in% stoplist]
if(length(new)) {
    setRepositories(ind = c(1:5,7))
    install.packages(new)
}
