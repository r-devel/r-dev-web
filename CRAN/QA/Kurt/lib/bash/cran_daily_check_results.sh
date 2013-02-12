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
    ${check_dir}/r-devel-linux-x86_64-debian/
sh ${HOME}/lib/bash/rsync_daily_check_flavor.sh \
    gimli.wu.ac.at:~hornik/tmp/R.check/r-devel-ng/ \
    ${check_dir}/r-devel-linux-x86_64-debian.new/
sh ${HOME}/lib/bash/rsync_daily_check_flavor.sh \
    xmeriador.wu.ac.at::R.check/r-devel/ \
    ${check_dir}/r-devel-linux-x86_64-debian.old/
sh ${HOME}/lib/bash/rsync_daily_check_flavor.sh \
    gimli.wu.ac.at::R.check/r-patched/ \
    ${check_dir}/r-patched-linux-x86_64/
sh ${HOME}/lib/bash/rsync_daily_check_flavor.sh \
    xmeriador.wu.ac.at::R.check/r-patched/ \
    ${check_dir}/r-patched-linux-x86_64.old/
sh ${HOME}/lib/bash/rsync_daily_check_flavor.sh \
    xmgyges.wu.ac.at::R.check/r-release/ \
    ${check_dir}/r-release-linux-ix86/

## Hand-crafted procedures for getting the results for other layouts.

mkdir -p "${check_dir}/r-devel-linux-x86_64-fedora"
(cd "${check_dir}/r-devel-linux-x86_64-fedora";
  rsync -q \
    --password-file="${HOME}/lib/bash/rsync_password_file_gannet.txt" \
    r-proj@gannet.stats.ox.ac.uk::Rlogs/gcc-times.tab .;
  rsync -q \
    --password-file="${HOME}/lib/bash/rsync_password_file_gannet.txt" \
    r-proj@gannet.stats.ox.ac.uk::Rlogs/gcc.tar.bz2 .;
  rm -rf PKGS && mkdir PKGS && cd PKGS && tar jxf ../gcc.tar.bz2)

mkdir -p "${check_dir}/r-devel-windows-ix86+x86_64/PKGS"
rsync --recursive --delete --times \
  129.217.206.10::CRAN-bin-windows-check/3.0/ \
  ${check_dir}/r-devel-windows-ix86+x86_64/PKGS

mkdir -p "${check_dir}/r-patched-solaris-sparc"
(cd "${check_dir}/r-patched-solaris-sparc";
  rsync -q \
    --password-file="${HOME}/lib/bash/rsync_password_file_gannet.txt" \
    r-proj@gannet.stats.ox.ac.uk::Rlogs/Sparc-times.tab .;
  rsync -q \
    --password-file="${HOME}/lib/bash/rsync_password_file_gannet.txt" \
    r-proj@gannet.stats.ox.ac.uk::Rlogs/Sparc.tar.bz2 .;
  rm -rf PKGS && mkdir PKGS && cd PKGS && tar jxf ../Sparc.tar.bz2)

mkdir -p "${check_dir}/r-patched-solaris-x86"
(cd "${check_dir}/r-patched-solaris-x86";
  rsync -q \
    --password-file="${HOME}/lib/bash/rsync_password_file_gannet.txt" \
    r-proj@gannet.stats.ox.ac.uk::Rlogs/Solx86-times.tab .;
  rsync -q \
    --password-file="${HOME}/lib/bash/rsync_password_file_gannet.txt" \
    r-proj@gannet.stats.ox.ac.uk::Rlogs/Solx86.tar.bz2 .;
  rm -rf PKGS && mkdir PKGS && cd PKGS && tar jxf ../Solx86.tar.bz2)

mkdir -p "${check_dir}/r-release-macosx-ix86/PKGS"
rsync --recursive --delete --times \
  --include="/*.Rcheck" \
  --include="/*.Rcheck/00[a-z]*" \
  --include="/*VERSION" \
  --include="/00_*" \
  --exclude="*" \
  rsync://r.rsync.urbanek.info:8081/build-results-leopard/2.15/ \
  ${check_dir}/r-release-macosx-ix86/PKGS/

mkdir -p "${check_dir}/r-release-windows-ix86+x86_64/PKGS"
rsync --recursive --delete --times \
  129.217.206.10::CRAN-bin-windows-check/2.15/ \
  ${check_dir}/r-release-windows-ix86+x86_64/PKGS

## mkdir -p "${check_dir}/r-oldrel-macosx-ix86/PKGS"
## rsync --recursive --delete --times \
##   --include="/*.Rcheck" \
##   --include="/*.Rcheck/00[a-z]*" \
##   --include="/*VERSION" \
##   --include="/00_*" \
##   --exclude="*" \
##   rsync://r.rsync.urbanek.info:8081/build-results-leopard/2.14/ \
##   ${check_dir}/r-oldrel-macosx-ix86/PKGS/

mkdir -p "${check_dir}/r-oldrel-windows-ix86+x86_64/PKGS"
rsync --recursive --delete --times \
  129.217.206.10::CRAN-bin-windows-check/2.14/ \
  ${check_dir}/r-oldrel-windows-ix86+x86_64/PKGS

## We used to do
##   LANG=en_US.UTF-8 LC_COLLATE=C \
##     sh ${HOME}/lib/bash/check_R_summary.sh

LANG=en_US.UTF-8 LC_COLLATE=en_US.UTF-8 \
  sh ${HOME}/lib/bash/check_R_summary.sh

## We used to do
##   LANG=en_US.UTF-8 LC_COLLATE=C \
##     sh ${HOME}/lib/bash/check_R_cp_logs.sh

LANG=en_US.UTF-8 LC_COLLATE=en_US.UTF-8 \
  sh ${HOME}/lib/bash/check_R_cp_logs.sh

## Manuals.
manuals_dir=/srv/ftp/pub/R/doc/manuals
for flavor in devel patched release; do
    rm -rf ${manuals_dir}/r-${flavor}
done    
cp -pr ${check_dir}/r-devel-linux-x86_64-debian/Manuals \
    ${manuals_dir}/r-devel
cp -pr ${check_dir}/r-patched-linux-x86_64/Manuals \
    ${manuals_dir}/r-patched
cp -pr ${check_dir}/r-release-linux-ix86/Manuals \
    ${manuals_dir}/r-release

### Local Variables: ***
### mode: sh ***
### sh-basic-offset: 2 ***
### End: ***
