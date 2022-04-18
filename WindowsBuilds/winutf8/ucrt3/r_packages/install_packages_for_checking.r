
# Install all packages to create a library for checking packages against
# it. Re-use binary versions from "build" as normally this is run just
# after updating the local mirror and building packages, hence re-use
# will reduce network traffic.

# --- customize below

#CRAN_mirror <- "https://cran.r-project.org"
#BIOC_mirror <- "https://master.bioconductor.org/packages/3.12"

CRAN_mirror <- paste0("file:///", getwd(), "/mirror/CRAN")
BIOC_mirror <- paste0("file:///", getwd(), "/mirror/BIOC")

CRAN_bins <- paste0("file:///", getwd(), "/build/CRAN")
BIOC_bins <- paste0("file:///", getwd(), "/build/BIOC")

onlycran <- TRUE # only CRAN packages will be explicitly installed
                 # some BIOC dependencies will be installed implicitly
#Ncpus <- 50
Ncpus <- 30

# --- customize above

# binary packages (most CRAN, few BIOC dependencies, local mirror)
repos_bin <- c(CRAN_bins, BIOC_bins)

repos_src <- c(CRAN_mirror,
        paste0(BIOC_mirror, "/bioc"),
        paste0(BIOC_mirror, "/data/annotation"),
        paste0(BIOC_mirror, "/data/experiment"),
        paste0(BIOC_mirror, "/workflows"))

curls_src <- paste0(repos_src, "/src/contrib")
           
mkdir <- function(d)
  if (!dir.exists(d))
    dir.create(d, recursive = TRUE)

mkdir("pkgcheck/lib")
mkdir("pkgcheck/install_out")
owd <- setwd("pkgcheck/install_out")

ap <- available.packages(curls_src)
if (onlycran) {
  iscran <- grepl(CRAN_mirror, ap[,"Repository"])
  toinst <- ap[iscran, "Package"]
} else 
  toinst <- ap[, "Package"]

toinst_last <- -1
iter <- 1

repos <- c(repos_bin, repos_src)
libdir <- paste0(owd, "/pkgcheck/lib")

options(install.packages.check.source = "no")
options(install.packages.compile.from.source = "yes")
Sys.setenv("_R_INSTALL_PACKAGES_ELAPSED_TIMEOUT_"=2000)

while(TRUE) {
  ip <- installed.packages(lib.loc=libdir)[,"Package"]
  toinst <- toinst[ !(toinst %in% ip) ]

  cat("Iteration", iter, "packages left to install",
      length(toinst), "already installed", length(ip), "\n")

  if (length(toinst) == 0) {
    cat("All packages were installed.\n")
    break # unlikely
  }
  if (length(toinst) == toinst_last) {
    cat("No new packages were installed in last iteration.\n")
    break
  }
  if (iter > 10) {
    cat("Maximum number of iterations reached.\n")
    break
  }

  cat("Iteration", iter, "installing packages...\n")
  toinst_last <- length(toinst)
  iter <- iter + 1

  # explicitly adding dependencies=TRUE to reduce the number
  # of problems due to under-specified dependencies for
  # building.
  install.packages(pkgs=toinst, repos=repos, Ncpus=Ncpus, 
    keep_outputs=TRUE, type="both", lib=libdir,
    dependencies=TRUE)
}

setwd(owd)

