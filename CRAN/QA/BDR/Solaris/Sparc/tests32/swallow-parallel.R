stoplist <- c("maxent", "RTextTools",
              "rpvm", "GDD", "aroma.apd", "calmate",
              "aroma.cn", "aroma.core", "aroma.affymetrix", "ACNE", "MAMA",
              "PKgraph", "WMTregions", "beadarrayMSV", "clusterfly",
              "magnets", "StochaTR", "topologyGSA", "ppiPre", "NSA", "SNPMaP",
              "highlight", "xterm256")

fakes <-
    c("GridR", "cmprskContin", "RDieHarder", "RMark", "ROracle", "RQuantLib",
      "RScaLAPACK", "Rcplex", "cudaBayesreg", "gputools",
      "magma", "rpud", "rscproxy",  "gWidgetsrJava",
      "RMySQL", "TSMySQL", "VBmix", "ROAuth", "SV", "RBerkeley", "psgp",
      "clpAPI", "glpkAPI", "OpenCL", "rJavax", "rpvm", "mpc", "cplexAPI",
      "Rmosek", "RProtoBuf", "rzmq", "RMongo", "RDF", "RiDMC")

recommended <-
    c("KernSmooth", "MASS", "Matrix", "boot", "class", "cluster",
      "codetools", "foreign", "lattice", "mgcv", "nlme", "nnet",
      "rpart", "spatial", "survival")

gcc <- c("MCMCpack", "RGtk2", "glmnet", "revoIPC", "tgp")

options(warn = 1)

rlib <- "~/R/Lib32"

list_tars <- function(dir='.')
{
    files <- list.files(dir, pattern="\\.tar\\.gz", full.names=TRUE)
    nm <- sub("_.*", "", basename(files))
    data.frame(name = nm, path=files, mtime = file.info(files)$mtime,
               row.names = nm, stringsAsFactors = FALSE)
}

foo1 <- list_tars('../contrib')
foo <- list_tars('../2.14-patched/Recommended')
foo <- rbind(foo, foo1)
tars <- foo[!duplicated(foo$name), ]

logs <- list.files('.', pattern = "\\.log$")
logs <- logs[logs != "script.log"]
fi <- file.info(logs)
nm <- sub("\\.log$", "", logs)
logs <- data.frame(name = nm, mtime = fi$mtime, stringsAsFactors = FALSE)
old <- nm[! nm %in% tars$name]
for(f in old) {
    cat('removing ', f, '\n', sep='')
    unlink(c(f, Sys.glob(paste(f, ".*", sep=""))), recursive = TRUE)
    unlink(file.path(rlib, f),  recursive = TRUE)
}

inst <- basename(dirname(Sys.glob(file.path(rlib, "*", "DESCRIPTION"))))

foo <- merge(logs, tars, by='name', all.y = TRUE)
row.names(foo) <- foo$name
keep <- with(foo, mtime.x < mtime.y)
old <- foo[keep %in% TRUE, ]

new <- foo[is.na(foo$mtime.x), ]
nm <- c(row.names(old), row.names(new))
nm <- nm[! nm %in% stoplist]
available <-
    available.packages(contriburl="file:///home/ripley/R/packages/contrib",
                       filters = list())
nm <- nm[nm %in% rownames(available)]
nmr <- nm[nm %in% recommended]
nm <- nm[!nm %in% recommended]
if(length(nm)) {
DL <- utils:::.make_dependency_list(nm, available)
nm <- utils:::.find_install_order(nm, DL)
}

Sys.setenv(R_LIBS = "/home/ripley/R/Lib32", DISPLAY=':5')
Sys.setenv(PVM_ROOT='/home/ripley/tools/pvm3', CPPFLAGS='-I/usr/local/include')
Sys.setenv(RMPI_TYPE="OPENMPI",
           RMPI_INCLUDE="/opt/SUNWhpc/HPC8.2.1c/sun/include",
           RMPI_LIB_PATH="/opt/SUNWhpc/HPC8.2.1c/sun/lib")
Sys.setenv(LC_CTYPE="en_GB.UTF-8")

do_one <- function(f)
{
    unlink(f, recursive = TRUE)
    try(system2("gtar", c("xf", tars[f, "path"]))) # in case it changes in //
    cat(sprintf('installing %s\n', f))
    opt <- ""; env <- ""
    if(f == "Rserve") opt <- '--configure-args=--without-server'
    desc <- read.dcf(file.path(f, "DESCRIPTION"), "SystemRequirements")[1L, ]
    if(grepl("GNU make", desc, ignore.case = TRUE)) env <- "MAKE=gmake"
    if(f %in% fakes) opt <- "--fake"
    opt <- c("--pkglock", opt)
    cmd <- ifelse(f %in% gcc, "/home/ripley/R/gcc/bin/R CMD INSTALL",
                  "R CMD INSTALL")
    args <- c(cmd, opt, tars[f, "path"])
    logfile <- paste(f, ".log", sep = "")
    res <- system2("time", args, logfile, logfile, env = env)
    if(res) cat(sprintf('  %s failed\n', f))
    else    cat(sprintf('  %s done\n', f))
}

do_many <- function(pkgs) for(f in pkgs) do_one(f)

M <- 10
library(parallel)
unlink("install_log")
cl <- makeCluster(M, outfile = "install_log")
clusterExport(cl, c("tars", "fakes", "gcc"))
do_many <- function(pkgs) clusterApplyLB(cl, pkgs, do_one)

make_dependency_list <-
    function (pkgs, available,
              dependencies = c("Depends", "Imports", "LinkingTo"))
{
    if (!length(pkgs)) return(NULL)
    if (is.null(available))
        stop(gettextf("%s must be supplied", sQuote(available)), domain = NA)
    info <- available[ , dependencies, drop = FALSE]
    known <- row.names(info)
    x <- vector("list", length(pkgs))
    names(x) <- pkgs
    for (i in pkgs) {
        p <- utils:::.clean_up_dependencies(info[i, ])
        p <- p[p %in% known]; p1 <- p
        repeat {
            extra <- unlist(lapply(p1, function(i) utils:::.clean_up_dependencies(info[i, ])))
            extra <- extra[extra != i]
            extra <- extra[extra %in% known]
            deps <- unique(c(p, extra))
            if (length(deps) <= length(p)) break
            p1 <- deps[!deps %in% p]
            p <- deps
        }
        x[[i]] <- p[p %in% pkgs]
    }
    x
}

if(length(nm)) {
    DL <- make_dependency_list(nm, available)
    lens <- sapply(DL, length)
    if (all(lens > 0L))
        stop("every package depends on at least one other")
    done <- names(DL[lens == 0L])
    do_many(done)
    DL <- DL[lens > 0L]
    while (length(DL)) {
        OK <- sapply(DL, function(x) all(x %in% done))
        pkgs <- names(DL[OK])
        do_many(pkgs)
        done <- c(done, pkgs)
        DL <- DL[!OK]
    }
}

## used for recommended packages
do_one_r <- function(f, tars)
{
    unlink(f, recursive = TRUE)
    logfile <- paste(f, ".log", sep = "")
    system2("touch", logfile)
    system2("gtar", c("xf", tars[f, "path"]))
    args <- c("R CMD check", tars[f, "path"])
    outfile <- paste(f, ".out", sep = "")
    system2("time", args, outfile, outfile, wait = FALSE)
}

for(f in nmr) do_one_r(f, tars)
