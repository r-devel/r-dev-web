check_dir="${HOME}/tmp/R.check"

## <NOTE>
## Keeps this in sync with
##   lib/bash/check_R_cp_logs.sh
##   lib/R/Scripts/check.R
## as well as
##   CRAN-package-list
## (or create a common data base eventually ...)
## </NOTE>

## Rsync daily check results for the various "flavors" using KH's
## check-R layout.
sh ${HOME}/lib/bash/rsync_daily_check_flavor.sh \
     aragorn.wu-wien.ac.at::R.check/r-devel/ \
     ${check_dir}/r-devel-linux-ix86/
sh ${HOME}/lib/bash/rsync_daily_check_flavor.sh \
     xmaragorn64.wu-wien.ac.at::R.check/r-devel/ \
     ${check_dir}/r-devel-linux-x86_64/
sh ${HOME}/lib/bash/rsync_daily_check_flavor.sh \
     anduin.wu-wien.ac.at::R.check/r-patched/ \
     ${check_dir}/r-patched-linux-ix86/
sh ${HOME}/lib/bash/rsync_daily_check_flavor.sh \
     xmaragorn64.wu-wien.ac.at::R.check/r-patched/ \
     ${check_dir}/r-patched-linux-x86_64/
sh ${HOME}/lib/bash/rsync_daily_check_flavor.sh \
     eragon.wu-wien.ac.at::R.check/r-release/ \
     ${check_dir}/r-release-linux-ix86/

## Hand-crafted procedures for getting the results for other layouts.

## mkdir -p "${check_dir}/r-oldrel-macosx-ix86/PKGS"
## rsync --recursive --delete \
##   --include="/*.Rcheck" \
##   --include="/*.Rcheck/00*" \
##   --include="/*VERSION" \
##   --include="/00_*" \
##   --exclude="*" \
##   rsync://r.rsync.urbanek.info:8081/build-results/2.6/ \
##   ${check_dir}/r-oldrel-macosx-ix86/PKGS/
mkdir -p "${check_dir}/r-patched-macosx-ix86/PKGS"
rsync --recursive --delete \
  --include="/*.Rcheck" \
  --include="/*.Rcheck/00*" \
  --include="/*VERSION" \
  --include="/00_*" \
  --exclude="*" \
  rsync://r.rsync.urbanek.info:8081/build-results/2.7/ \
  ${check_dir}/r-patched-macosx-ix86/PKGS/

## mkdir -p "${check_dir}/r-oldrel-windows-x86_64/PKGS"
## rsync --recursive --delete \
##   129.217.206.10::CRAN-bin-windows-check/2.6/ \
##   ${check_dir}/r-oldrel-windows-x86_64/PKGS
mkdir -p "${check_dir}/r-patched-windows-x86_64/PKGS"
rsync --recursive --delete \
  129.217.206.10::CRAN-bin-windows-check/2.7/ \
  ${check_dir}/r-patched-windows-x86_64/PKGS
## mkdir -p "${check_dir}/r-devel-windows-x86_64/PKGS"
## rsync --recursive --delete \
##   129.217.206.10::CRAN-bin-windows-check/2.7/ \
##   ${check_dir}/r-devel-windows-x86_64/PKGS

sh ${HOME}/lib/bash/check_R_summary.sh

## Copy logs.
## <NOTE>
## We currently use LANG=C to ensure that we don't get invalid multibyte
## strings.  Log files can be invalid in MBCS, and we typically do not
## know their encoding.  R 2.7.0 has added recording the session charset
## in the log file, so we could/should use this info eventually ...
env LANG=C sh ${HOME}/lib/bash/check_R_cp_logs.sh
## </NOTE>
