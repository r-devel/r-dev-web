#! /bin/bash

# Check all CRAN packages from a local mirror. Expects an installed library
# of packages in pkgcheck/lib. R has to be on PATH.

MAXLOAD=40
MAXJOBS=60

CHECK_ELAPSED_TIMEOUT=1800
CHECK_TIMER_TIMEOUT=2000
CHECK_FINISH_TIMEOUT=200

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
  echo "Done checking packages, generating reports."

  # -l $MAXLOAD does not seem to be working well, it gets stuck
  #  when one of the processes leaves behind a spawned process...

  parallel -j $MAXJOBS -n 1 $SELF -- $UHOME/mirror/CRAN/src/contrib/*.tar.gz
  echo "Done checking packages, generating reports."

  touch $UHOME/pkgcheck/stop_timer
  echo "Waiting for timer to stop."
  sleep $CHECK_FINISH_TIMEOUT

  while [ ! -r $UHOME/pkgcheck/timer_stopped ] ; do
    sleep 4
  done

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

if [ "$1" == TIMER ] ; then
  if [ ! -x "$HANDLE_TOOL" ] ; then
    echo "Timer: handle tool is not available." >&2
    exit 2
  fi
  # recursively invoked to periodically terminate checking processes
  #   that are taking too long
  TMPHANDLE=/tmp/timer_handle.$$
  TMPPROCS=/tmp/timer_procs.$$
  MATCH_DIR=`cygpath -m $UHOME/pkgcheck`

  while true ; do
    if [ -r $UHOME/pkgcheck/stop_timer ] ; then
      echo "Timer: signalled to stop soon."
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
      grep pkgcheck | tr -t '\\' '/' | \
      grep -i " $MATCH_DIR" | \
      sed -e 's!'"$MATCH_DIR/\([^/]*\)/\([^/]*\)/.*"'!\1/\2!gi' | \
      grep -E '( CRAN/| BIOC/)' | \
      sort | uniq | \
      while read CPID CPKG ; do
        # PID of a Windows process and "repo/pkgname" where repo is
        #   "CRAN" or "BIOC"
        PKG=`basename $CPKG`
        echo "$CPID $PKG" >>$TMPPROCS
        STARTTS=$UHOME/pkgcheck/$CPKG/started_ts
        FINISHEDTS=$UHOME/pkgcheck/$CPKG/finished_ts
        if [ -r $STARTTS ] ; then
          STARTTS=`cat $STARTTS`
          REASON=ok
          if [ `expr $STARTTS + $CHECK_TIMER_TIMEOUT` -lt $NOW ] ; then
            REASON="due to time out STARTTS=$STARTTS CHECK_TIMER_TIMEOUT=$CHECK_TIMER_TIMEOUT NOW=$NOW (`expr $NOW - $STARTTS`s since checking started)"
          elif [ -r $FINISHEDTS ] ; then
            FIN=`cat $FINISHEDTS`
            if [ `expr $FIN + $CHECK_FINISH_TIMEOUT` -lt $NOW ] ; then
              # processes are exitting asynchronously, so give 2
              # minute grace period
              REASON="because the main checking process already finished"
            fi
          elif [ $NO_MORE_CHECKS == yes ] ; then
            REASON="because checking all packages already finished"
          fi 
          if [ "$REASON" != ok ] ; then
            "$HANDLE_TOOL" -p $CPID >$UHOME/pkgcheck/$CPKG/timer_terminating_$CPID.handle 2>/dev/null
            if [ -x "$TLIST_TOOL" ] ; then
              "$TLIST_TOOL" /p $CPID >$UHOME/pkgcheck/$CPKG/timer_terminating_$CPID.tlist
            fi
            if taskkill //F //PID $CPID >/dev/null 2>&1 ; then
              date +%s >$UHOME/pkgcheck/$CPKG/timer_terminated_ts
              echo "Timer: terminated $CPID ($PKG) $REASON."
            else
              rm -f $UHOME/pkgcheck/$CPKG/timer_terminating_$CPID.handle
              rm -f $UHOME/pkgcheck/$CPKG/timer_terminating_$CPID.tlist
            fi
          fi
        else 
          echo "Timer: package without valid time stamp: $PKG (process $CPID)"
        fi
      done
    if [ -r $TMPPROCS ] ; then
      CPROC=`cat $TMPPROCS | wc -l`
      CPKGS=`cat $TMPPROCS | cut -d' ' -f2 | wc -l`
      echo "Timer: $CPROC processes ${CPKGS} packages"
    else
      echo "Timer: no package processes"
    fi
    if [ $NO_MORE_CHECKS == yes ] ; then
      echo "Timer: exitting"
      touch $UHOME/pkgcheck/timer_stopped
      break
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
  echo $PKG > pkgname
  date +%s > started_ts
  R CMD check $SRC >$PKG.out 2>&1
  if grep -q 'ERROR$' $PKG.out ; then
    STATUS=ERROR
  elif grep -q 'WARNING$' $PKG.out ; then
    STATUS=WARNING
  elif grep -q '^Status:' $PKG.out ; then
    STATUS=OK
  else
    STATUS=CRASHED
  fi
  if [ $STATUS == CRASHED ] ; then
    # to make it clearer also for the summarization script
    echo "Crashed or did not get results ...ERROR" >> $PKG.out
  fi
  echo "Checked $PKG $STATUS"
  cd /tmp # prevent timer from killing this
  date +%s > $UHOME/pkgcheck/$REPO/$PKG/finished_ts
done

