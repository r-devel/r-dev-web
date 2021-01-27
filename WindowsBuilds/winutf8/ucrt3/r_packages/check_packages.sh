#! /bin/bash

# Check all CRAN packages from a local mirror. Expects an installed library
# of packages in pkgcheck/lib. R has to be on PATH.

MAXLOAD=40

CHECK_ELAPSED_TIMEOUT=1800
CHECK_TIMER_TIMEOUT=2000

# https://docs.microsoft.com/en-us/sysinternals/downloads/handle
# HANDLE_TOOL=handle64.exe

# A Windows debugging tool
# https://docs.microsoft.com/en-us/windows-hardware/drivers/debugger/tlist-commands
# TLIST_TOOL=tlist.exe

# -----

SELF="$0"
UHOME=`pwd`

if [ "$#" == 0 ] ; then

  # run timer that periodically terminates stuck processes
  echo "Starting timer process."
  $SELF TIMER &

  # uses GNU parallel
  #   checking of BIOC packages can be enabled here

  NPKGS=`ls -1 $UHOME/mirror/CRAN/src/contrib/*.tar.gz | wc -l`
  echo "Number of source packages (CRAN) in local mirror: $NPKGS"

  #   check one package at a time to avoid the case that a stuck package
  #     prevents checking of another one
  #
  #   experience shows that -l is not working well, either, that the checking
  #     can get stuck by a single package getting stuck, perhaps the load
  #     is not computed correctly?
  parallel -l $MAXLOAD -n 1 $SELF -- $UHOME/mirror/CRAN/src/contrib/*.tar.gz
  echo "Done checking packages, generating reports."

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

  touch $UHOME/pkgcheck/stop_timer
  exit 0
fi

if [ "$1" == TIMER ] ; then
  if [ ! -x "$HANDLE_TOOL" ] ; then
    echo "Handle tool is not available." >&2
    exit 2
  fi
  # recursively invoked to periodically terminate checking processes
  #   that are taking too long
  TMPHANDLE=/tmp/timer_handle.$$
  TMPPROCS=/tmp/timer_procs.$$
  MATCH_DIR=`cygpath -m $UHOME/pkgcheck | tr -t '[:upper:]' '[:lower:]'`

  while true ; do
    if [ -r $UHOME/pkgcheck/stop_timer ] ; then
      NO_MORE_CHECKS=yes     
    else
      NO_MORE_CHECKS=no
    fi
    sleep 30s
    NOW=`date +%s`
 
    "$HANDLE_TOOL" >$TMPHANDLE 2>/dev/null
    rm -f $TMPPROCS
    cat $TMPHANDLE | tr -s ' ' | \
      awk '/ pid: / { PID=$3 } / File / { print PID " " $3 }' | \
      grep pkgcheck | tr -t '\\' '/' | tr -t '[:upper:]' '[:lower:]' | \
      grep " $MATCH_DIR" | \
      sed -e 's!'"$MATCH_DIR/\([^/]*\)/\([^/]*\)/.*"'!\1/\2!g' | \
      grep -E '( cran/| bioc/)' | \
      sort | uniq | \
      while read CPID CPKG ; do
        # PID of a Windows process and "repo/pkgname" where repo is
        #   "cran" or "bioc"

        # restore case
        CPKG=`( cd $UHOME/pkgcheck/$CPKG ; pwd | \
                sed -e 's!.*/\([^/]*/[^.*]\)!\1!g' )`
        PKG=`basename $CPKG`
        echo "$CPID $PKG" >>$TMPPROCS
        STARTTS=$UHOME/pkgcheck/$CPKG/started_ts
        if [ -r $STARTTS ] ; then
          STARTTS=`cat $STARTTS`
          if [ `expr $STARTTS + $CHECK_TIMER_TIMEOUT` -lt $NOW ] ; then
            echo "Timer terminated $CPID ($PKG)"
            "$HANDLE_TOOL" -p $CPID >$UHOME/pkgcheck/$CPKG/timer_terminating_$CPID.handle 2>/dev/null
            if [ -x "$TLIST_TOOL" ] ; then
              "$TLIST_TOOL" /p $CPID >$UHOME/pkgcheck/$CPKG/timer_terminating_$CPID.tlist
            fi
            date +%s >$UHOME/pkgcheck/$CPKG/timer_terminated_ts
            taskkill //F //PID $CPID
          fi
        else 
          echo "Package without valid time stamp: $CPKG (process $CPID)"
        fi
      done
    if [ $NO_MORE_CHECKS = yes ] ; then
      if [ -r $TMPPROCS ] ; then
        echo "Done running new checks, but "`wc -l $TMPPROCS`" processes are still running, so timer keeps running."
      else
        echo "Done running new checks, no more processes, exitting timer."
        break
      fi
    fi
  done
  rm -f $TMPHANDLE $TMPPROCS
  exit 0
fi

# recursively invoked to check specific packages

export R_BROWSER=false
export R_PDFVIEWER=false
export _R_CHECK_PKG_SIZES_=false
export _R_CHECK_FORCE_SUGGESTS_=false
export _R_CHECK_ELAPSED_TIMEOUT_=$CHECK_ELAPSED_TIMEOUT
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
  date +%s > started_ts
  R CMD check $SRC >$PKG.out 2>&1
  date +%s > finished_ts
  if grep -q 'ERROR$' $PKG.out ; then
    STATUS=ERROR
  elif grep -q 'WARNING$' $PKG.out ; then
    STATUS=WARNING
  else
    STATUS=OK
  fi
  echo "Checked $PKG $STATUS"
done

