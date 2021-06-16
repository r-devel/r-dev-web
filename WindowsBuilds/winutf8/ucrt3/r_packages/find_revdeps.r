
# Find source packages of reverse dependencies for given package(s). Only installed
# packages are considered.

pkgs <- commandArgs(trailingOnly=TRUE)

# --- customize below (also in install_packages_for_checking.r)

#CRAN_mirror <- "https://cran.r-project.org"
#BIOC_mirror <- "https://master.bioconductor.org/packages/3.12"

CRAN_mirror <- paste0("file:///", getwd(), "/mirror/CRAN")
BIOC_mirror <- paste0("file:///", getwd(), "/mirror/BIOC")

CRAN_bins <- paste0("file:///", getwd(), "/build/CRAN")
BIOC_bins <- paste0("file:///", getwd(), "/build/BIOC")

onlycran <- TRUE

# --- customize above

repos_src <- c(CRAN_mirror,
        paste0(BIOC_mirror, "/bioc"),
        paste0(BIOC_mirror, "/data/annotation"),
        paste0(BIOC_mirror, "/data/experiment"),
        paste0(BIOC_mirror, "/workflows"))

curls_src <- paste0(repos_src, "/src/contrib")

deps <- tools::dependsOnPkgs(pkgs, c("Depends", "Imports", "LinkingTo"))
           
ap <- available.packages(curls_src)
found <- ap[ ap[,"Package"] %in% deps, c("Repository", "Package", "Version")]

if (nrow(found)) {
  if (onlycran) {
    iscran <- grepl(CRAN_mirror, found[,"Repository"])
    found <- found[iscran,]
  }

  dummy <- apply(found, 1, function(x)
    cat(paste0(gsub("^file:///", "", x["Repository"]),
               "/",
               x["Package"], "_", x["Version"], ".tar.gz\n"))
  )
}
