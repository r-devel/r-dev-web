source("common.R")

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
    Sys.unsetenv("R_HOME")
    res <- system2("time", args, logfile, logfile, env = env)
    if(res) cat(sprintf('  %s failed\n', f))
    else    cat(sprintf('  %s done\n', f))
}

M <- min(length(nm), 16)
library(parallel)
unlink("install_log")
cl <- makeCluster(M, outfile = "install_log")
clusterExport(cl, c("tars", "fakes", "gcc"))

if(length(nm)) {
    available2 <-
        available.packages(c("file:///home/ripley/R/packages/contrib",
"http://bioconductor.statistik.tu-dortmund.de/packages/2.9/bioc/src/contrib"),
                           filters=list())
    DL <- utils:::.make_dependency_list(nm, available2, recursive = TRUE)
    DL <- lapply(DL, function(x) x[x %in% nm])
    lens <- sapply(DL, length)
    if (all(lens > 0L)) stop("every package depends on at least one other")
    ready <- names(DL[lens == 0L])
    done <- character()
    n <- length(ready)
    submit <- function(node, pkg)
        parallel:::sendCall(cl[[node]], do_one, list(pkg), tag = pkg)
    for (i in 1:min(n, M)) submit(i, ready[i])
    DL <- DL[!names(DL) %in% ready[1:min(n, M)]]
    av <- if(n < M) (n+1L):M else integer()
    while(length(done) < length(nm)) {
        d <- parallel:::recvOneResult(cl)
        av <- c(av, d$node)
        done <- c(done, d$tag)
        OK <- unlist(lapply(DL, function(x) all(x %in% done) ))
        if (!any(OK)) next
        pkgs <- names(DL)[OK]
        m <- min(length(pkgs), length(av))
        for (i in 1:m) submit(av[i], pkgs[i])
        av <- av[-(1:m)]
        DL <- DL[!names(DL) %in% pkgs[1:m]]
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
