#! /bin/bash

mkdir -p mirror/CRAN/src/contrib

rsync -rtLzv --delete --exclude /contrib/Archive --exclude /contrib/00Archive \
      cran.r-project.org::CRAN/src/contrib mirror/CRAN/src

mkdir -p mirror/BIOC/bioc/src/contrib \
         mirror/BIOC/data/annotation/src/contrib \
         mirror/BIOC/data/experiment/src/contrib \
         mirror/BIOC/workflows/src/contrib

BVER=3.15
if [ "X${BIOC_MIRROR_BASE}" == X ] ; then
  BIOC_MIRROR_BASE="master.bioconductor.org::"
fi

rsync -rtlzv --delete ${BIOC_MIRROR_BASE}${BVER}/bioc/src/contrib mirror/BIOC/bioc/src
rsync -rtlzv --delete ${BIOC_MIRROR_BASE}${BVER}/data/annotation/src/contrib mirror/BIOC/data/annotation/src
rsync -rtlzv --delete ${BIOC_MIRROR_BASE}${BVER}/data/experiment/src/contrib mirror/BIOC/data/experiment/src
rsync -rtlzv --delete ${BIOC_MIRROR_BASE}${BVER}/workflows/src/contrib mirror/BIOC/workflows/src

# create empty indices for binary packages so that the mirror can be used
# as a repository (while checking packages)

for D in \
  CRAN \
  BIOC/bioc BIOC/data/annotation BIOC/data/experiment BIOC/workflows ; do

  D=mirror/$D/bin/windows/contrib/4.3  # R Version hardcoded here
  mkdir -p $D
  touch $D/PACKAGES
done

