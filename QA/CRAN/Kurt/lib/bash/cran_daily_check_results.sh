check_dir="${HOME}/tmp/R.check"

## Rsync daily check results for the various "flavors" using KH's
## check-R layout.
sh ${HOME}/lib/bash/rsync_daily_check_flavor.sh \
     aragorn.wu-wien.ac.at::R.check/r-devel/ \
     ${check_dir}/r-devel-linux-ix86/
sh ${HOME}/lib/bash/rsync_daily_check_flavor.sh \
     r-forge.wu-wien.ac.at::R.check/r-devel/ \
     ${check_dir}/r-devel-linux-x86_64/
sh ${HOME}/lib/bash/rsync_daily_check_flavor.sh \
     anduin.wu-wien.ac.at::R.check/r-patched/ \
     ${check_dir}/r-patched-linux-ix86/
sh ${HOME}/lib/bash/rsync_daily_check_flavor.sh \
     anduin.wu-wien.ac.at::R.check/r-release/ \
     ${check_dir}/r-release-linux-ix86/

## Hand-crafted procedures for getting the results for other layouts.
mkdir -p "${check_dir}/r-patched-macosx-ix86/PKGS"
rsync --recursive --delete \
  --include="/*.Rcheck" \
  --include="/*.Rcheck/00*" \
  --exclude="*" \
  rsync://rosuda.org:8081/build-results/2.4.0/ \
  ${check_dir}/r-release-macosx-ix86/PKGS/

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
sh ${HOME}/lib/bash/check_R_cp_logs.sh
