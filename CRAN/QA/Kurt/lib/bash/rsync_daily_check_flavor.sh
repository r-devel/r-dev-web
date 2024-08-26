rsync --recursive --times --delete \
  --exclude="/PKGS.prev" \
  --exclude="/build" \
  --exclude="/src" \
  --include="/*" \
  --include="/PKGS/*.Rcheck/" \
  --include="/PKGS/*.Rcheck/00*" \
  --include="/Manuals/**" \
  --exclude="*" \
  "${1}" "${2}"

## Results may move from one check server to another, so get these
## without deleting.
rsync --recursive --times \
  --include="/Results/" \
  --include="/Results/**" \
  --exclude="*" \
  "${1}" "${2}"

## And then use along the lines of
## sh rsync_daily_check_flavor.sh \
##   aragorn.ci.tuwien.ac.at::R.check/r-devel/ ~/tmp/R.check/r-devel

### Local Variables: ***
### mode: sh ***
### sh-basic-offset: 2 ***
### End: ***
