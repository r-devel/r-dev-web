#! /bin/bash

# Check all CRAN packages from a local mirror. Expects an installed library
# of packages in pkgcheck/lib. R has to be on PATH.

MAXLOAD=40

# -----

SELF="$0"
UHOME=`pwd`

if [ "$#" == 0 ] ; then
  # uses GNU parallel
  #   checking of BIOC packages can be enabled here
  #
  #   check one package at a time to avoid the case that a stuck package
  #     prevents checking of another one
  parallel -l $MAXLOAD -n 1 $SELF -- $UHOME/mirror/CRAN/src/contrib/*.tar.gz

  # generate reports
  KIND=gcc10-UCRT
  URL=https://www.r-project.org/nosvn/winutf8/ucrt3

  for REPO in CRAN BIOC ; do
    RD=$UHOME/pkgcheck/results/$REPO/checks/$KIND
    mkdir -p $RD
    D=$UHOME/pkgcheck/$REPO

    if [ -d $D ] ; then
      cd $D
      echo Package,Version,kind,href >$RD/$KIND.csv
      egrep -l '(ERROR|WARNING)$' */*.out | cut -d/ -f1 | \
        while read P ; do
          VER=`grep "^* this is package.*version" $P/$P.out  | sed -e 's/.*version //g' | tr -d \'`
          echo $P,$VER,$KIND,$URL/$REPO/checks/$KIND/packages/$P/$P.out >>$RD/$KIND.csv
          mkdir -p $RD/packages/$P
          cp $P/$P.out $P/00check.log $P/00install.out $RD/packages/$P
        done
    fi
  done

  exit 0
fi

# recursively invoked to check specific packages

export R_BROWSER=false
export R_PDFVIEWER=false
export _R_CHECK_PKG_SIZES_=false
export _R_CHECK_FORCE_SUGGESTS_=false
export _R_CHECK_ELAPSED_TIMEOUT_=1800
export R_LIBS=`pwd`/pkgcheck/lib

for SRC in $* ; do
  PKG=`echo $SRC | sed -e 's/.*\/\([^_]*\)_.*$/\1/g'`
  REPO=`echo $SRC | sed -E -e 's/.*\/(CRAN|BIOC)\/.*/\1/g'`

  CDIR=$UHOME/pkgcheck/$REPO/$PKG
  mkdir -p $CDIR
  export TMPDIR=$CDIR/tmp
  mkdir -p $TMPDIR
  cd $CDIR
  set > env.log
  R CMD check $SRC >$PKG.out 2>&1
  echo "Checked $PKG"
done

