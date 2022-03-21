#! /bin/bash

SRC=~/winutf8/ucrt3
TGT=~/rtools42
TMPTGT=~/rtools42.tmp

# copy toolchain files

cd $SRC
RTEXE=`ls -1 rtools42-*.exe | head -1`
if [ "X$RTEXE" == X ] ; then
  echo "New Rtools42 installer not ready." >&2
  exit 1
fi

if [ -r $TGT/files/$RTEXE ] ; then
  echo "Already have the latest version." >&2
  exit 0
fi

RTVER=`echo $RTEXE | cut -d- -f2,3 | sed -e 's/\.exe//g'`
TLVER=`echo $RTEXE | cut -d- -f2`

TBASE=gcc10_ucrt3_base_$TLVER.tar.zst
TFULL=gcc10_ucrt3_full_$TLVER.tar.zst
TCROSS=gcc10_ucrt3_cross_$TLVER.tar.zst

TCLB=`ls -1 Tcl-$TLVER-*.zip | head -1`

if [ "X$TCLB" == X ] ; then
  echo "Tcl bundle not ready." >&2
  exit 1
fi

rm -rf $TMPTGT
mkdir -p $TMPTGT

for F in $RTEXE $TBASE $TFULL $TCROSS $TCLB ; do
  if [ ! -r $F ] ; then
    echo "File $F is missing." >&2
    exit 1
  fi
  cp -p $F $TMPTGT
done

for F in $RTEXE $TBASE $TFULL $TCROSS $TCLB ; do
  if ! cmp $F $TMPTGT/$F ; then
    echo "Files changed while copying." >&2
    exit 2
  fi
done

# rename as needed

cd $TMPTGT
mkdir files

NTBASE=rtools42-toolchain-libs-base-$TLVER.tar.zst
NTFULL=rtools42-toolchain-libs-full-$TLVER.tar.zst
NTCROSS=rtools42-toolchain-libs-cross-$TLVER.tar.zst
NTCLB=`echo $TCLB | sed -e 's/Tcl-/tcltk-/g'`

mv $RTEXE files
mv $TBASE files/$NTBASE
mv $TFULL files/$NTFULL
mv $TCROSS files/$NTCROSS
mv $TCLB files/$NTCLB

# generate index file

svn cat https://svn.r-project.org/R-dev-web/trunk/WindowsBuilds/Rtools42/rtools.md | \
  sed -e 's/RTVER/'$RTVER'/g' |
  pandoc -s -c "https://cran.r-project.org/R.css" > rtools.html
  
if [ $? -ne 0 ] || [ ! -r rtools.html ] ; then
  echo "Failed to generate index." >&2
  exit 1
fi

rm -rf $TGT.old
if [ -d $TGT ] ; then
  mv $TGT $TGT.old
fi
mv $TMPTGT $TGT
