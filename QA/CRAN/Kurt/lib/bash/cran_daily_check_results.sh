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
     gimli.wu.ac.at::R.check/r-devel/ \
     ${check_dir}/r-devel-linux-ix86/
sh ${HOME}/lib/bash/rsync_daily_check_flavor.sh \
     xmorthanc.wu.ac.at::R.check/r-devel/ \
     ${check_dir}/r-devel-linux-x86_64-gcc/
sh ${HOME}/lib/bash/rsync_daily_check_flavor.sh \
     gimli.wu.ac.at::R.check/r-patched/ \
     ${check_dir}/r-patched-linux-ix86/
sh ${HOME}/lib/bash/rsync_daily_check_flavor.sh \
     xmorthanc.wu.ac.at::R.check/r-patched/ \
     ${check_dir}/r-patched-linux-x86_64/
sh ${HOME}/lib/bash/rsync_daily_check_flavor.sh \
     xmgyges.wu.ac.at::R.check/r-release/ \
     ${check_dir}/r-release-linux-ix86/

## Hand-crafted procedures for getting the results for other layouts.

mkdir -p "${check_dir}/r-devel-linux-x86_64-sun"
(cd "${check_dir}/r-devel-linux-x86_64-sun";
  rsync -q \
    --password-file="${HOME}/lib/bash/rsync_password_file_gannet.txt" \
    r-proj@gannet.stats.ox.ac.uk::Rlogs/Sun.tar.bz2 .;
  rm -rf PKGS && mkdir PKGS && cd PKGS && tar jxf ../Sun.tar.bz2)

mkdir -p "${check_dir}/r-release-macosx-ix86/PKGS"
rsync --recursive --delete --times \
  --include="/*.Rcheck" \
  --include="/*.Rcheck/00*" \
  --include="/*VERSION" \
  --include="/00_*" \
  --exclude="*" \
  rsync://r.rsync.urbanek.info:8081/build-results/2.9/ \
  ${check_dir}/r-release-macosx-ix86/PKGS/

mkdir -p "${check_dir}/r-devel-windows-ix86/PKGS"
rsync --recursive --delete --times \
  129.217.206.10::CRAN-bin-windows-check/2.10/ \
  ${check_dir}/r-devel-windows-ix86/PKGS

mkdir -p "${check_dir}/r-release-windows-ix86/PKGS"
rsync --recursive --delete --times \
  129.217.206.10::CRAN-bin-windows-check/2.9/ \
  ${check_dir}/r-release-windows-ix86/PKGS

LANG=en_US.UTF-8 LC_COLLATE=C sh ${HOME}/lib/bash/check_R_summary.sh

LANG=en_US.UTF-8 LC_COLLATE=C sh ${HOME}/lib/bash/check_R_cp_logs.sh

