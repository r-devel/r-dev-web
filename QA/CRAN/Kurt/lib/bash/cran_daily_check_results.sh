check_dir="${HOME}/tmp/R.check"

## <NOTE>
## Keeps this in sync with
##   lib/bash/check_R_cp_logs.sh
##   lib/R/Scripts/check.R
## (or create a common data base eventually ...)
## </NOTE>

## Rsync daily check results for the various "flavors" using KH's
## check-R layout.
sh ${HOME}/lib/bash/rsync_daily_check_flavor.sh \
     eragon.wu-wien.ac.at::R.check/r-devel/ \
     ${check_dir}/r-devel-linux-ix86/
sh ${HOME}/lib/bash/rsync_daily_check_flavor.sh \
     r-forge.wu-wien.ac.at::R.check/r-devel/ \
     ${check_dir}/r-devel-linux-x86_64/
sh ${HOME}/lib/bash/rsync_daily_check_flavor.sh \
     anduin.wu-wien.ac.at::R.check/r-patched/ \
     ${check_dir}/r-patched-linux-ix86/
sh ${HOME}/lib/bash/rsync_daily_check_flavor.sh \
     r-forge.wu-wien.ac.at::R.check/r-patched/ \
     ${check_dir}/r-patched-linux-x86_64/
sh ${HOME}/lib/bash/rsync_daily_check_flavor.sh \
     anduin.wu-wien.ac.at::R.check/r-release/ \
     ${check_dir}/r-release-linux-ix86/

## Hand-crafted procedures for getting the results for other layouts.
mkdir -p "${check_dir}/r-patched-macosx-ix86/PKGS"
rsync --recursive --delete \
  --include="/*.Rcheck" \
  --include="/*.Rcheck/00*" \
  --include="/*VERSION" \
  --exclude="*" \
  rsync://r.rsync.urbanek.info:8081/build-results/2.5/ \
  ${check_dir}/r-patched-macosx-ix86/PKGS/

mkdir -p "${check_dir}/r-release-windows-x86_64/PKGS"
rsync --recursive --delete \
  129.217.206.10::CRAN-bin-windows-check/2.5/ \
  ${check_dir}/r-release-windows-x86_64/PKGS
## mkdir -p "${check_dir}/r-patched-windows-x86_64/PKGS"
## rsync --recursive --delete \
##   129.217.206.10::CRAN-bin-windows-check/2.5/ \
##   ${check_dir}/r-patched-windows-x86_64/PKGS


## Summarize results.
## <FIXME>
## Is this still needed?
## <NOTE>
## We currently use LANG=C to ensure that we don't get invalid multibyte
## strings (e.g., from maintainer names in the DESCRIPTION metadata).
env LANG=C sh ${HOME}/lib/bash/check_R_summary.sh
## </NOTE>
## </FIXME>

## Copy logs.
env LANG=C sh ${HOME}/lib/bash/check_R_cp_logs.sh

