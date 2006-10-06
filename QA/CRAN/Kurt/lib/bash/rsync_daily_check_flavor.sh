rsync --recursive --delete \
  --exclude="/PKGS.prev" \
  --exclude="/build" \
  --exclude="/src" \
  --include="/*" \
  --include="/PKGS/*.Rcheck/" \
  --include="/PKGS/*.Rcheck/00*" \
  --include="/Results/**" \
  --exclude="*" \
  "${1}" "${2}"

## And then use along the lines of
## sh rsync_daily_check_flavor.sh \
##   aragorn.ci.tuwien.ac.at::R.check/r-devel/ ~/tmp/R.check/r-devel
