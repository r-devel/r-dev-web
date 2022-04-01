#
# Builds index of patches (patches_idx.rds), which is used by R when 
# installing packages for find out which, if any, patches need to be
# applied. The index is just a list with elements named by packages,
# each element is a list of relative paths to the diff files. There can
# be a single diff per package (named <package>.diff) or multiple, taken
# in alphabetical order, named <package>_<suffix>.diff, where suffix can
# be anything by is intended to be numerical value (yet note the alphabetical
# ordering).
#

dirs <- c("patches/CRAN", "patches/BIOC")

idx <- list()
for(d in dirs) {
  filenames <- list.files(d, pattern="*.diff")
  diffnames <- gsub("\\.diff$", "", filenames)
  pkgnames <- gsub("_.*", "", diffnames)

  dups <- pkgnames[ pkgnames %in% names(idx) ]
  if (length(dups) > 0) {
    stop("duplicate package(s) in repositories: ", dups)
  }

  for(i in seq_along(filenames)) {
    p <- pkgnames[i]
    f <- paste0(d, "/", filenames[i])
    idx[[p]] <- append(idx[[p]], f)
  }
}

if (length(idx) == 0)
  # may be ok
  cat("NOTE: no patches found")

saveRDS(idx, file="patches_idx.rds")

