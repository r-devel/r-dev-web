check_dir="${HOME}/tmp/R.check"

## Used for the manuals ... adjust as needed.
##   flavors="prerel patched release"
flavors="patched release"
## <NOTE>
## This needed 
##   flavors="patched"
## prior to the 3.0.2 release.
## </NOTE>

## <NOTE>
## Keeps this in sync with
##   lib/bash/check_R_cp_logs.sh
##   lib/R/Scripts/check.R
## as well as
##   CRAN-package-list
## (or create a common data base eventually ...)
## </NOTE>

## Rsync daily check results for the various "flavors" using KH's
## check-R/check-R-ng layout.

## r-devel-linux-x86_64-debian-clang
sh ${HOME}/lib/bash/rsync_daily_check_flavor.sh \
  gimli.wu.ac.at::R.check/r-devel-clang/ \
  ${check_dir}/r-devel-linux-x86_64-debian-clang/

## r-devel-linux-x86_64-debian-gcc
sh ${HOME}/lib/bash/rsync_daily_check_flavor.sh \
  gimli.wu.ac.at::R.check/r-devel-gcc/ \
  ${check_dir}/r-devel-linux-x86_64-debian-gcc/

## r-patched-linux-x86_64
sh ${HOME}/lib/bash/rsync_daily_check_flavor.sh \
  gimli.wu.ac.at::R.check/r-patched-gcc/ \
  ${check_dir}/r-patched-linux-x86_64/

## r-release-linux-x86_64
sh ${HOME}/lib/bash/rsync_daily_check_flavor.sh \
  gimli.wu.ac.at::R.check/r-release-gcc/ \
  ${check_dir}/r-release-linux-x86_64/

## r-release-linux-ix86
sh ${HOME}/lib/bash/rsync_daily_check_flavor.sh \
  xmgyges.wu.ac.at::R.check/r-release-gcc/ \
  ${check_dir}/r-release-linux-ix86/

## Hand-crafted procedures for getting the results for other layouts.

## r-devel-linux-x86_64-fedora-clang
mkdir -p "${check_dir}/r-devel-linux-x86_64-fedora-clang"
(cd "${check_dir}/r-devel-linux-x86_64-fedora-clang";
  rsync -q --times \
    --password-file="${HOME}/lib/bash/rsync_password_file_gannet.txt" \
    r-proj@gannet.stats.ox.ac.uk::Rlogs/clang-times.tab .;
  rsync -q --times \
    --password-file="${HOME}/lib/bash/rsync_password_file_gannet.txt" \
    r-proj@gannet.stats.ox.ac.uk::Rlogs/clang.tar.bz2 .;
  test clang.tar.bz2 -nt PKGS && \
    rm -rf PKGS && mkdir PKGS && cd PKGS && tar jxf ../clang.tar.bz2)

## r-devel-linux-x86_64-fedora-gcc
mkdir -p "${check_dir}/r-devel-linux-x86_64-fedora-gcc"
(cd "${check_dir}/r-devel-linux-x86_64-fedora-gcc";
  rsync -q --times \
    --password-file="${HOME}/lib/bash/rsync_password_file_gannet.txt" \
    r-proj@gannet.stats.ox.ac.uk::Rlogs/gcc-times.tab .;
  rsync -q --times \
    --password-file="${HOME}/lib/bash/rsync_password_file_gannet.txt" \
    r-proj@gannet.stats.ox.ac.uk::Rlogs/gcc.tar.bz2 .;
  test gcc.tar.bz2 -nt PKGS && \
    rm -rf PKGS && mkdir PKGS && cd PKGS && tar jxf ../gcc.tar.bz2)

## r-devel-macosx-x86_64-clang
mkdir -p "${check_dir}/r-devel-macosx-x86_64-clang"
(cd "${check_dir}/r-devel-macosx-x86_64-clang";
  rsync -q --times \
    --password-file="${HOME}/lib/bash/rsync_password_file_gannet.txt" \
    r-proj@gannet.stats.ox.ac.uk::Rlogs/mavericks-times.tab .;
  rsync -q --times \
    --password-file="${HOME}/lib/bash/rsync_password_file_gannet.txt" \
    r-proj@gannet.stats.ox.ac.uk::Rlogs/mavericks.tar.bz2 .;
  test mavericks.tar.bz2 -nt PKGS && \
    rm -rf PKGS && mkdir PKGS && cd PKGS && tar jxf ../mavericks.tar.bz2)

## r-devel-macosx-x86_64-gcc
mkdir -p "${check_dir}/r-devel-macosx-x86_64-gcc/PKGS"
rsync --recursive --delete --times \
  --include="/*.Rcheck" \
  --include="/*.Rcheck/00[a-z]*" \
  --include="/*VERSION" \
  --include="/00_*" \
  --exclude="*" \
  rsync://r.rsync.urbanek.info:8081/build-all/snowleopard-x86_64/results/3.1/ \
  ${check_dir}/r-devel-macosx-x86_64-gcc/PKGS/

## r-devel-windows-ix86+x86_64
mkdir -p "${check_dir}/r-devel-windows-ix86+x86_64/PKGS"
rsync --recursive --delete --times \
  129.217.206.10::CRAN-bin-windows-check/3.1/ \
  ${check_dir}/r-devel-windows-ix86+x86_64/PKGS

## r-patched-solaris-sparc
mkdir -p "${check_dir}/r-patched-solaris-sparc"
(cd "${check_dir}/r-patched-solaris-sparc";
  rsync -q --times \
    --password-file="${HOME}/lib/bash/rsync_password_file_gannet.txt" \
    r-proj@gannet.stats.ox.ac.uk::Rlogs/Sparc-times.tab .;
  rsync -q --times \
    --password-file="${HOME}/lib/bash/rsync_password_file_gannet.txt" \
    r-proj@gannet.stats.ox.ac.uk::Rlogs/Sparc.tar.bz2 .;
  test Sparc.tar.bz2 -nt PKGS && \
    rm -rf PKGS && mkdir PKGS && cd PKGS && tar jxf ../Sparc.tar.bz2)

## r-patched-solaris-x86
mkdir -p "${check_dir}/r-patched-solaris-x86"
(cd "${check_dir}/r-patched-solaris-x86";
  rsync -q --times \
    --password-file="${HOME}/lib/bash/rsync_password_file_gannet.txt" \
    r-proj@gannet.stats.ox.ac.uk::Rlogs/Solx86-times.tab .;
  rsync -q --times \
    --password-file="${HOME}/lib/bash/rsync_password_file_gannet.txt" \
    r-proj@gannet.stats.ox.ac.uk::Rlogs/Solx86.tar.bz2 .;
  test Solx86.tar.bz2 -nt PKGS && \
    rm -rf PKGS && mkdir PKGS && cd PKGS && tar jxf ../Solx86.tar.bz2)

## r-release-macosx-x86_64
mkdir -p "${check_dir}/r-release-macosx-x86_64/PKGS"
rsync --recursive --delete --times \
  --include="/*.Rcheck" \
  --include="/*.Rcheck/00[a-z]*" \
  --include="/*VERSION" \
  --include="/00_*" \
  --exclude="*" \
  rsync://r.rsync.urbanek.info:8081/build-all/snowleopard-x86_64/results/3.0/ \
  ${check_dir}/r-release-macosx-x86_64/PKGS/

## r-release-windows-ix86+x86_64
mkdir -p "${check_dir}/r-release-windows-ix86+x86_64/PKGS"
rsync --recursive --delete --times \
  129.217.206.10::CRAN-bin-windows-check/3.0/ \
  ${check_dir}/r-release-windows-ix86+x86_64/PKGS

## r-oldrel-macosx-ix86
## mkdir -p "${check_dir}/r-oldrel-macosx-ix86/PKGS"
## rsync --recursive --delete --times \
##   --include="/*.Rcheck" \
##   --include="/*.Rcheck/00[a-z]*" \
##   --include="/*VERSION" \
##   --include="/00_*" \
##   --exclude="*" \
##   rsync://r.rsync.urbanek.info:8081/build-all/leopard-universal/results/2.15/ \
##   ${check_dir}/r-oldrel-macosx-ix86/PKGS/

## r-oldrel-windows-ix86+x86_64
mkdir -p "${check_dir}/r-oldrel-windows-ix86+x86_64/PKGS"
rsync --recursive --delete --times \
  129.217.206.10::CRAN-bin-windows-check/2.15/ \
  ${check_dir}/r-oldrel-windows-ix86+x86_64/PKGS

## BDR memtests
mkdir -p "${check_dir}/bdr-memtests"
rsync -q --recursive --delete --times \
  --password-file="${HOME}/lib/bash/rsync_password_file_gannet.txt" \
  r-proj@gannet.stats.ox.ac.uk::Rlogs/memtests/ \
  ${check_dir}/bdr-memtests

## Summaries and logs.

LANG=en_US.UTF-8 LC_COLLATE=en_US.UTF-8 \
  sh ${HOME}/lib/bash/check_R_summary.sh

LANG=en_US.UTF-8 LC_COLLATE=en_US.UTF-8 \
  sh ${HOME}/lib/bash/check_R_cp_logs.sh

## Manuals.
manuals_dir=/srv/ftp/pub/R/doc/manuals
for flavor in devel ${flavors} ; do
    rm -rf ${manuals_dir}/r-${flavor}
done    
cp -pr ${check_dir}/r-devel-linux-x86_64-debian-clang/Manuals \
    ${manuals_dir}/r-devel
for flavor in ${flavors} ; do
  cp -pr ${check_dir}/r-${flavor}-linux-x86_64/Manuals \
    ${manuals_dir}/r-${flavor}
done  

### Local Variables: ***
### mode: sh ***
### sh-basic-offset: 2 ***
### End: ***
