## must contain training slash!
src.path <- "/Volumes/Builds/packages/CRAN/src/contrib/"
tmp <- "/Volumes/Temp/tmp"  ## tempdir()
wd <- "/Volumes/Builds/packages"
Ncpus <- 8

### --- just code below ...
setwd(wd)
if (!isTRUE(file.exists(tmp))) dir.create(tmp, mode="0770")
lib <- .libPaths()[1L]
available <- available.packages(paste0("file://", src.path), type='source')
pkgs <- rownames(available)
# pkgs <- getDependencies(pkgs, dependencies, available, lib)
upkgs <- unique(pkgs)
update <- (cbind(upkgs, lib))
colnames(update) <- c("Package", "LibPath")
m.pkg <- match(update[, "Package"], available[, "Package"])
update <- cbind(update, file = paste0(src.path, available[m.pkg, "Package"], "_", available[m.pkg, "Version"], ".tar.gz"))

getConfigureArgs <- function(pkg) ''
getConfigureVars <- function(pkg) ''

bin.chk.dir <- ""
if (nzchar(e <- Sys.getenv("UPDATE")) && file.exists(e))
   bin.chk.dir <- e

# cmd0 <- paste(cmd0, "--pkglock")
tmpd <- file.path(tmp, "make_packages")
if (!file.exists(tmpd) && !dir.create(tmpd)) 
            stop(gettextf("unable to create temporary directory %s", 
               sQuote(tmpd)), domain = NA)
       mfile <- file.path(tmpd, "Makefile")
       conn <- file(mfile, "wt")
            deps <- paste(paste0(update[, 1L], ".ts"), collapse = " ")
            deps <- strwrap(deps, width = 75, exdent = 2)
            deps <- paste(deps, collapse = " \\\n")
            cat("all: ", deps, "\n", sep = "", file = conn)
            aDL <- utils:::.make_dependency_list(upkgs, available, recursive = TRUE)
            for (i in seq_len(nrow(update))) {
                pkg <- update[i, 1L]
		cmd <- paste0("PKGLOCK=", shQuote(pkg)," ./should_build ", pkg, " ./mk.chk ", pkg)
#                cmd <- paste(cmd0, "-l", shQuote(update[i, 2L]), 
#                  getConfigureArgs(update[i, 3L]), getConfigureVars(update[i, 
#                    3L]), shQuote(update[i, 3L]), ">", paste0(pkg, 
#                    ".out"), "2>&1")
                deps <- aDL[[pkg]]
                deps <- deps[deps %in% upkgs]
                deps <- if (length(deps)) 
                  paste(paste0(deps, ".ts"), collapse = " ")
                  else ""
		  
		if (nzchar(bin.chk.dir))
 		   cmd <- paste0("if [ ! -e '",
		            file.path(bin.chk.dir, gsub(".tar.gz", ".tgz", gsub(".*/", "", update[i, 3L]), fixed=TRUE)),
			    "' ]; then ", cmd, "; fi")

                cat(paste0(pkg, ".ts: ", deps), paste("\t@echo begin installing package", 
                  sQuote(pkg)), paste0("\t@(cd ", shQuote(wd), "; ", cmd, ") && touch ", 
                  pkg, ".ts"), # paste0("\t@cat ", pkg, ".out"), 
                  "", sep = "\n", file = conn)
            }
            close(conn)
            cwd <- setwd(tmpd)
	    q("no")

            on.exit(setwd(cwd))
            status <- system(paste(Sys.getenv("MAKE", "make"), "-k -j", Ncpus))
            if (status > 0L) {
                pkgs <- update[, 1L]
                tss <- sub("\\.ts$", "", dir(".", pattern = "\\.ts$"))
                failed <- pkgs[!pkgs %in% tss]
                for (pkg in failed) system(paste0("cat ", pkg, 
                  ".out"))
                warning(gettextf("installation of one of more packages failed,\n  probably %s", 
                  paste(sQuote(failed), collapse = ", ")), domain = NA)
            }
            setwd(cwd)
#            on.exit()
#            unlink(tmpd, recursive = TRUE)
