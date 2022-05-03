#! /bin/bash

# Check all CRAN packages from a local mirror. Expects an installed library
# of packages in pkgcheck/lib. R has to be on PATH.

#MAXLOAD=40

#MAXJOBS=60 maybe too much
#MAXJOBS=50 overall faster, but some tex processes killed by timeout
MAXJOBS=30

CHECK_ELAPSED_TIMEOUT=6000
CHECK_TIMER_TIMEOUT=7000
CHECK_FINISH_TIMEOUT=400

# https://docs.microsoft.com/en-us/sysinternals/downloads/handle
# HANDLE_TOOL=handle64.exe

# A Windows debugging tool (part e.g. of Windows SDK)
# https://docs.microsoft.com/en-us/windows-hardware/drivers/debugger/tlist-commands
# TLIST_TOOL=tlist.exe

# -----

SELF="$0"
UHOME=`pwd`

  # by default, check all packages in the repository (CRAN, possibly BIOC)
if [ "$#" == 0 ] ; then

  # run timer that periodically terminates stuck processes
  rm -f $UHOME/pkgcheck/stop_timer $UHOME/pkgcheck/timer_stopped
  echo "Starting timer process."
  $SELF TIMER & 
  echo "The timer process PID is $!."

  # uses GNU parallel
  #   checking of BIOC packages can be enabled here

  PKGLIST=/tmp/pkglist.$$
  cat <<EOF | R --no-echo >$PKGLIST
    dir <- paste0(getwd(), "/mirror/CRAN/src/contrib")
    ap <- available.packages(paste0("file:///", dir))
    cat(paste0(dir, "/", ap[,"Package"], "_", ap[,"Version"], ".tar.gz"))
EOF

  NPKGS=`cat $PKGLIST | wc -w`
  echo "Number of source packages (CRAN) in local mirror: $NPKGS"
  echo "Source packages to check: "
  cat $PKGLIST | tr -t ' ' '\n'

  #   check one package at a time to avoid the case that a stuck package
  #     prevents checking of another one
  #
  #   experience shows that -l is not working well, either, that the checking
  #     can get stuck by a single package getting stuck, perhaps the load
  #     is not computed correctly?
  #
  # -l $MAXLOAD does not seem to be working well, it gets stuck
  #  when one of the processes leaves behind a spawned process...


  parallel -j $MAXJOBS -n 1 $SELF -- `cat $PKGLIST`
  rm -f $PKGLIST
  echo "Done checking packages."

  touch $UHOME/pkgcheck/stop_timer
  echo "Waiting for timer to stop."

  # still needed?
  sleep $CHECK_FINISH_TIMEOUT

  while [ ! -r $UHOME/pkgcheck/timer_stopped ] ; do
    sleep 4
  done

  echo "Generating reports."

  # generate reports
  KIND=gcc10-UCRT
  URL=https://www.r-project.org/nosvn/winutf8/ucrt3

  for REPO in CRAN BIOC ; do
    RD=$UHOME/pkgcheck/results/$REPO/checks/$KIND
    mkdir -p $RD
    D=$UHOME/pkgcheck/$REPO

    if [ -d $D ] ; then
      cd $D
#      export in "additional kind" format
#
#      echo Package,Version,kind,href >$RD/$KIND.csv
#
#      TMPR=/tmp/report_pkgs.$$
#  
#     # report packages with errors, warnings, and succesfully applied patches
#
#      egrep -l '(ERROR|WARNING)$' */*.out | cut -d/ -f1 > $TMPR
#      grep -l 'Applied installation-time patch' */00install.out | cut -d/ -f1 >> $TMPR
#      
#     # report all packages
#      ls -1 > $TMPR
#
#      cat $TMPR | sort -u | \
#        while read P ; do
#
#          export in "additional kind" format
#
#          VER=`grep "^* this is package.*version" $P/$P.out  | sed -e 's/.*version //g' | tr -d \'`
#          echo $P,$VER,$KIND,$URL/$REPO/checks/$KIND/packages/$P/$P.out.txt >>$RD/$KIND.csv
#          mkdir -p $RD/packages/$P
#          cp $P/$P.out $RD/packages/$P/$P.out.txt
#          cp $P/$P.Rcheck/00check.log $RD/packages/$P/00check.log.txt
#          cp $P/$P.Rcheck/00install.out $RD/packages/$P/00install.out.txt
#
#          # export for CRAN pages
#          mkdir -p $RD/export/$P.Rcheck
#          cp $P/$P.Rcheck/00check.log $RD/export/$P.Rcheck
#          cp $P/$P.Rcheck/00install.out $RD/export/$P.Rcheck
#          cp $P/$P.Rcheck/00_pkg_src/$P/DESCRIPTION \
#             $RD/export/$P.Rcheck/00package.dcf
#        done
#      rm -f $TMPR


      # Processing files one-by-one in bash on Windows has been too slow, so 
      # using "tar" to copy and rename files.

      mkdir -p $RD/export
      find . -maxdepth 3 -mindepth 3 -name "00install.out" -o -name "00check.log" | \
        tar --transform 's|^\./[^/]*||g' -cf - -T- | \
        tar x -C $RD/export

      find . -maxdepth 5 -mindepth 5 -name "DESCRIPTION" | \
        tar --transform 's|^\./\([^/]*\)/.*|\1.Rcheck/00package.dcf|g' -cf - -T- | \
        tar x -C $RD/export
      
      cp $UHOME/README_checks $RD/README.txt
    fi
  done
  
#  # translate references to 00check.log, 00install.out files in the outputs
#  # also remove local directory prefix
#  
#  cd $UHOME/pkgcheck
#  PCDIR=$(cygpath -m $(pwd))
#  PCDDIR=$(cygpath -md $(pwd))
#  
#  translated URLs in export in "additional kind" format
#
#  find $UHOME/pkgcheck/results -name "*.txt" | while read F ; do
#    sed -E -i -e 's!'"$PCDIR"'/(CRAN|BIOC)/([^/]+)/\2\.Rcheck/(00check\.log|00install\.out)!https://www.r-project.org/nosvn/winutf8/ucrt3/\1/checks/gcc10-UCRT/packages/\2/\3.txt!g' $F
#    sed -E -i -e 's!'"$PCDIR"'/(CRAN|BIOC)/!\1/!g' $F
#  done
#
#  find $UHOME/pkgcheck/results -type f | \
#    while read F ; do
#      sed -E -i -e 's!'"$PCDIR"'!!g' $F
#      sed -E -i -e 's!'"$PCDDIR"'!!g' $F
#    done
#
  exit 0
fi

#  check given tarball or its revdeps
#    (running in parallel, reporting results for debugging, etc)
#
#  TARBALL ... check the given tarball
#  REVDEPS ... install the given tarball and check it
#              including its reverse dependencies
if [ "$1" == TARBALL ] || [ "$1" == REVDEPS ] ; then
  
  SRC=$2
  if [ "X$SRC" == X ] ; then
    echo "No tarballs to check."
    exit 0
  fi
  if [ ! -r "$SRC" ] ; then
    echo "Package tarball $SRC does not exist." >&2
    exit 1
  fi

  PKG=`basename $SRC | sed -e 's/\.tar.gz//g'`
  PKGN=`echo $PKG | sed -e 's/_.*//g'` # there may be no version
  JOB=${PKG}_`date -r $SRC +%Y%m%d_%H%M%S`
  RD=$UHOME/pkgcheck/qresults/00_$JOB
  LOG=$RD/outputs.txt
  rm -rf $RD $UHOME/pkgcheck/qresults/$JOB
  mkdir -p $RD/package

  cp $SRC $RD/package

  # install the package

  echo "Installing package $PKG."
  echo "Installing $PKGN..." >>$LOG

  mkdir -p $UHOME/pkgcheck/qlib
  export CP_R_LIBS=$UHOME/pkgcheck/qlib:$UHOME/pkgcheck/lib
    # FIXME add as argument to support BIOC?
  export CP_REPO=CRAN

  cd $RD/package
  env R_LIBS=$CP_R_LIBS \
    R CMD INSTALL $SRC --build 2>&1 | tee install.out
  cd $UHOME

  if tail -1 $RD/package/install.out | grep -q " DONE " ; then

    echo "   DONE." >>$LOG
    echo >>$LOG
    # check the package or its reverse dependencies
    export CP_CHECK_DIR=$UHOME/pkgcheck/qchecks/$JOB
    rm -rf $CP_CHECK_DIR

    # run timer that periodically terminates stuck processes
    echo "Starting timer process."
    $SELF TIMER &

    if [ "$1" == TARBALL ] ; then
      echo "Checking package $SRC."
      echo "Checking $PKG." >>$LOG
      $SELF $SRC
    else
      # see comments on parallel above about the number of jobs/load
      echo "Calculating reverse dependencies for $PKGN."
      TMPRD=/tmp/rd.$$
      env R_LIBS=$CP_R_LIBS Rscript find_revdeps.r $PKGN >$TMPRD 2>/dev/null
      echo "Reverse depednecies for $PKGN are:"
      cat $TMPRD
      NREV=`cat $TMPRD | wc -l`
      if [ "$NREV" == 0 ] ; then
        echo "Checking $PKG (which has no reverse dependencies)." >>$LOG
      else
        echo "Checking $PKG and its $NREV reverse dependencies" >>$LOG
        cat $TMPRD | sed -e 's/.*\///g' | sed -e 's/\.tar\.gz//g' | \
                     sed -e 's/^/   /g' >>$LOG
      fi
      echo >>$LOG
      parallel -j $MAXJOBS -n 1 $SELF -- $SRC `cat $TMPRD`
      rm $TMPRD
    fi
    echo "Done checking packages."

    touch $CP_CHECK_DIR/stop_timer
    echo "Waiting for timer to stop."
    #sleep $CHECK_FINISH_TIMEOUT

    while [ ! -r $CP_CHECK_DIR/timer_stopped ] ; do
      sleep 4
    done

    # extract check results
    echo "Generating reports."

    for REPO in CRAN BIOC ; do
      D=$CP_CHECK_DIR/$REPO

      if [ -d $D ] ; then
        cd $D
        mkdir -p $RD/package/export
        find . -maxdepth 3 -mindepth 3 -name "00install.out" -o -name "00check.log" | \
          tar --transform 's|^\./[^/]*\/|rdepends_|g' -cf - -T- | \
          tar x -C $RD/package/export

        find . -maxdepth 5 -mindepth 5 -name "DESCRIPTION" | \
          tar --transform 's|^\./[^/]*\/|rdepends_|g' -cf - -T- | \
          tar x -C $RD/package/export

        if [ -x $RD/package/export/rdepends_${PKGN}.Rcheck ] ; then
          mv $RD/package/export/rdepends_${PKGN}.Rcheck \
             $RD/package/export/${PKGN}.Rcheck

          cp $RD/package/export/${PKGN}.Rcheck/00install.out $RD/package 
          cp $RD/package/export/${PKGN}.Rcheck/00check.log $RD/package
        fi        
      fi
      cd $UHOME
    done

    if [ -d $RD/package/export ] ; then
      PMD=`cygpath -m $RD/package/export`
      echo "Depends:" >>$LOG
      cat <<EOF | R --no-echo >>$LOG
        tools::summarize_check_packages_in_dir_depends("$PMD")
EOF
      echo >>$LOG
      # FIXME: no timings available

      echo "Results:" >>$LOG
      cat <<EOF | R --no-echo >>$LOG
        tools::summarize_check_packages_in_dir_results("$PMD")
EOF
      echo >>$LOG

      # generate changes.txt
      # FIXME: there may be errors due to different check conditions
      #        for various reasons; several check iterations would be
      #        useful
      # FIXME: now only supports CRAN
      if [ "$1" == REVDEPS ] ; then
        cat <<EOF | R --no-echo >>$RD/package/changes.txt
          old <- "`cygpath -m $UHOME/pkgcheck/CRAN/checks/gcc10-UCRT/export`"
          new <- "`cygpath -m $RD/package/export`"
          changes <- tools:::check_packages_in_dir_changes(new, old)
          if (NROW(changes)) {
            writeLines("Check results changes:")
            print(changes)
          }
EOF
      fi
    fi

    # generate summary.txt
    L=$RD/package/00check.log
    if [ -r $L ] ; then
      cat <<EOF | R --no-echo
        log <- "`cygpath -m $L`"
        results <- tools:::check_packages_in_dir_results(logs = log)
        status <- results[["package"]][["status"]]
        out <- sprintf("Package check result: %s\n", status)
        if(status != "OK") {
            details <- tools:::check_packages_in_dir_details(logs = log)
            out <- c(out,
                     sprintf("Check: %s, Result: %s\n  %s\n",
                             details[["Check"]],
                             details[["Status"]],
                             gsub("\n", "\n  ", details[["Output"]], 
                                  perl = TRUE, useBytes = TRUE)))
        }    
        writeLines(out, "`cygpath -m $RD/summary.txt`")
EOF
    fi
    if [ "$1" == REVDEPS ] ; then
      if [ -s $RD/changes.txt ] ; then
        echo "Changes to worse in reverse depends:" >>$RD/summary.txt
        cat $RD/changes.txt >>$RD/summary.txt
        echo >>$RD/summary.txt
      elif [ -r $RD/changes.txt ] ; then
        echo "No changes to worse in reverse depends." >>$RD/summary.txt
      fi
    fi
    
    #rm -rf $RD/package/export  #now used (it has the results)
    rm -rf $CP_CHECK_DIR
  else
    echo "   FAILED." >>$LOG
  fi

  mv $RD $UHOME/pkgcheck/qresults/$JOB
  exit 0
fi


if [ "$1" == TIMER ] ; then
  if [ "X$HANDLE_TOOL" == X ] || [ ! -x "$HANDLE_TOOL" ] ; then
    echo "Timer: handle tool is not available, so it won't be used." >&2
  fi
  if [ ! -x "$TLIST_TOOL" ] ; then
    echo "Timer: tlist tool is not available." >&2
    exit 2
  fi
  # recursively invoked to periodically terminate checking processes
  #   that are taking too long
  TMPHANDLE=/tmp/timer_handle.$$
  TMPTLIST=/tmp/timer_tlist.$$
  TMPPROCS=/tmp/timer_procs.$$
  CHECK_DIR=$UHOME/pkgcheck
  if [ "X$CP_CHECK_DIR" != X ] ; then
    CHECK_DIR=$CP_CHECK_DIR
  fi
  MATCH_DIR0=`cygpath -m $CHECK_DIR`
 
# This was for behavior observed on WS2016 (yet it might have been caused
# instead by earlier msys2 version)
#
# There, cygpath -m $CHECK_DIR for a subst'd drive would return path on that
# subst'd drive, so we had to create MATCH_DIR1, which would have the
# expanded variant (for the real drive).  We need both, because the outputs
# from TLIST/HANDLE may have either, because some external processes are run
# after normalization
#
# However, the behavior changed later.
#
#  
#  # normalizePath() also follows drive mappings (subst), which is useful
#  # as some packages seem to normalize before executing external processes
#  MATCH_DIR1=`cat <<EOF | R --no-echo
#    cat(normalizePath("${MATCH_DIR0}"))
#EOF
#`
#  MATCH_DIR1=`cygpath -m "${MATCH_DIR1}"`

# With WS2022 preview (but possibly due to newer Msys2?), the behavior of
# cygpath -m is different.  cygpath -m $CHECK_DIR for a subst'd drive would
# return path with expanded drive letter.  So, we then need MATCH_DIR1 to
# have the original with the subst'd drive, and it appears one can do it by
# this trick, using cygpath -m on a directory that does not exist.

  MATCH_DIR1=`cygpath -m "$UHOME/pkgcheck_nonexistent" | sed -e 's/pkgcheck_nonexistent/pkgcheck/g'`

  echo "MATCH_DIR0 is $MATCH_DIR0"
  echo "MATCH_DIR1 is $MATCH_DIR1"

  while true ; do
    if [ -r $CHECK_DIR/stop_timer ] ; then
      echo "Timer: signalled to stop soon."
      NO_MORE_CHECKS=yes     
    else
      NO_MORE_CHECKS=no
    fi
    sleep 30s
    NOW=`date +%s`

    # handle tool seems rather slow when run on a loaded system
    #   it also sometimes gets stuck 
    # if [ "X$HANDLE_TOOL" != X ] && [ -x "$HANDLE_TOOL" ] ; then
    #   "$HANDLE_TOOL" >$TMPHANDLE 2>/dev/null
    # fi  
    rm -f $TMPHANDLE
    touch $TMPHANDLE

    "$TLIST_TOOL" "*.*" >$TMPTLIST 2>/dev/null
    rm -f $TMPPROCS
    touch $TMPPROCS

    for MATCH_DIR in "${MATCH_DIR0}" "${MATCH_DIR1}" ; do
      # identify package checking processes by open file handles for
      # path names including "pkgcheck"
      cat $TMPHANDLE | tr -s ' ' | \
        awk '/ pid: / { PID=$3 } / File / { print PID " " $3 }' | \
        grep pkgcheck | tr -t '\\' '/' | \
        grep -i " ${MATCH_DIR}" | \
        sed -e 's!'"${MATCH_DIR}/\([^/]*\)/\([^/]*\)/.*"'!\1/\2!gi' | \
        grep -E '( CRAN/| BIOC/)' | \
        sort | uniq >>$TMPPROCS

      # identify package checking processes by their command lines and
      # current working directory
      cat $TMPTLIST | \
        awk '/^ *[0-9]+ .*\.exe/ { PID=$1 } /^ *CWD:/ { print PID " " $0 } /^ *CmdLine:/ { print PID " " $0 }' | \
        grep pkgcheck | tr -t '\\' '/' | \
        grep -i " ${MATCH_DIR}" | \
        sed -e 's!\(^[0-9]\+\).*'"${MATCH_DIR}/\([^/]*\)/\([^/]*\)/.*"'!\1 \2/\3!gi' | \
        grep -E '( CRAN/| BIOC/)' | \
        sort | uniq >>$TMPPROCS
    done

    cat $TMPPROCS | sort | uniq | \
      while read CPID CPKG ; do
        # PID of a Windows process and "repo/pkgname" where repo is
        #   "CRAN" or "BIOC"
        PKG=`basename $CPKG`
        STARTTS=$CHECK_DIR/$CPKG/started_ts
        FINISHEDTS=$CHECK_DIR/$CPKG/finished_ts
        TERMINATEDTS=$CHECK_DIR/$CPKG/timer_terminated_ts
        if [ -r $STARTTS ] ; then
          STARTTS=`cat $STARTTS`
          REASON=ok
          if [ `expr $STARTTS + $CHECK_TIMER_TIMEOUT` -lt $NOW ] ; then
            REASON="due to time out (`expr $NOW - $STARTTS`s since checking started)"
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
            if [ "X$HANDLE_TOOL" != X ] && [ -x "$HANDLE_TOOL" ] ; then
              "$HANDLE_TOOL" -p $CPID >$CHECK_DIR/$CPKG/timer_terminating_$CPID.handle 2>/dev/null
            fi
            if [ -x "$TLIST_TOOL" ] ; then
              "$TLIST_TOOL" /p $CPID >$CHECK_DIR/$CPKG/timer_terminating_$CPID.tlist
            fi
            if taskkill //F //PID $CPID >/dev/null 2>&1 ; then
              date +%s >$TERMINATEDTS
              echo "Timer: terminated $CPID ($PKG) $REASON."
              cp $TMPHANDLE $CHECK_DIR/$CPKG/timer_terminating_$CPID.handle_system
              cp $TMPTLIST $CHECK_DIR/$CPKG/timer_terminating_$CPID.tlist_system
            else
              echo "Timer: could not terminate $CPID ($PKG) $REASON: taskkill failed."
              rm -f $CHECK_DIR/$CPKG/timer_terminating_$CPID.handle
              rm -f $CHECK_DIR/$CPKG/timer_terminating_$CPID.tlist
            fi
          fi
        else 
          echo "Timer: package without valid time stamp: $PKG (process $CPID)"
        fi
      done
    if [ -r $TMPPROCS ] ; then
      CPROC=`cat $TMPPROCS | cut -d' ' -f1 | sort -u | wc -l`
      CPKGS=`cat $TMPPROCS | cut -d' ' -f2 | sort -u | wc -l`
      echo "Timer: $CPROC processes ${CPKGS} packages"
    else
      echo "Timer: no package processes"
    fi
    if [ $NO_MORE_CHECKS == yes ] ; then
      echo "Timer: exitting"
      touch $CHECK_DIR/timer_stopped
      break
    fi
  done
  rm -f $TMPHANDLE $TMPTLIST $TMPPROCS
  exit 0
fi

# recursively invoked to check specific packages

# particularly needed for outputs from tests using unitizer,
#   perhaps but worth showing more context in either case
export _R_CHECK_TESTS_NLINES_=0
export _R_CHECK_VIGNETTES_NLINES_=0

# needed e.g. for commonsMath
export R_DEFAULT_INTERNET_TIMEOUT=300

export _R_CHECK_XREFS_USE_ALIASES_FROM_CRAN_=true

# for UCRT invalid parameter checks (ignored by MinGW-w64 default)
export _R_WIN_CHECK_INVALID_PARAMETERS_=TRUE

# part of --as-cran, to check HTML5 using tidy
export _R_CHECK_RD_VALIDATE_RD2HTML_=true

export R_BROWSER=false
export R_PDFVIEWER=false
export _R_CHECK_PKG_SIZES_=false
export _R_CHECK_FORCE_SUGGESTS_=false
export _R_CHECK_ELAPSED_TIMEOUT_=$CHECK_ELAPSED_TIMEOUT
export R_LIBS=$UHOME/pkgcheck/lib

if [ "X$CP_R_LIBS" != X ] ; then
  export R_LIBS=$CP_R_LIBS
fi

for SRC in $* ; do
  if [ ! -r $SRC ] ; then
    echo "Package $SRC not found."
    exit 2
  fi
       # version may not be present
  PKG=`echo $SRC | sed -e 's/.*\///g' | \
                   sed -e 's/\.tar.gz//g' | sed -e 's/_.*//g'`
  if [ "X$CP_REPO" == X ] ; then
    REPO=`echo $SRC | sed -E -e 's/.*\/(CRAN|BIOC)\/.*/\1/g'`
  else
    REPO=$CP_REPO
  fi
  
  # retrieve extra arguments (stoplist)
  SLIST=$UHOME/check_stoplist
  EXTARGS=""
  if [ -r $SLIST ] ; then
    EXTARGS=`cat $SLIST | grep '^'$PKG' ' | sed -e 's/^[^ ]\+ //g'` 
  fi

  CDIR=$UHOME/pkgcheck/$REPO/$PKG
  if [ "X$CP_CHECK_DIR" != X ] ; then
    CDIR=$CP_CHECK_DIR/$REPO/$PKG
  fi
  if [ -d $CDIR ] ; then
    echo "ERROR: (?) Directory $CDIR already exists."
  fi
  mkdir -p $CDIR
  # This way we end up with pretty long path names, some packages then
  # fail because of 260-byte path limit.
  export TMPDIR=$CDIR/tmp
  ## export TMPDIR=/c/tmp/${PKG}.$$
  mkdir -p $TMPDIR
  cd $CDIR
  set > env.log
  echo $PKG > pkgname
  if [ "X$EXTARGS" != X ] ; then
    echo "$EXTARGS" > extra_args
  fi
  date +%s > started_ts
  # --as-cran would report insufficient package version
  # (incoming feasibility), at least
  R CMD check $EXTARGS $SRC >$PKG.out 2>&1
  if grep -q 'ERROR[[:cntrl:]]$' $PKG.out ; then
    STATUS=ERROR
  elif grep -q 'WARNING[[:cntrl:]]$$' $PKG.out ; then
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
  echo "Checked $PKG: $STATUS"
  cd /tmp # prevent timer from killing this
  date +%s > $CDIR/finished_ts
  ## mkdir $CDIR/tmp
  ## mv $TMPDIR $CDIR/tmp
done
