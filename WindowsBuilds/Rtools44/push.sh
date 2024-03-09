#! /bin/bash

SRC=~/winutf8/ucrt3
TGT=~/rtools44.unsigned
#TGT=~/rtools44
TMPTGT=~/rtools44.tmp

# copy toolchain files

cd $SRC
RTEXE=`ls -1 rtools44-*.exe | grep -v aarch64 | head -1`
if [ "X$RTEXE" == X ] ; then
  echo "New Rtools44 installer not ready." >&2
  exit 1
fi

RTEXEA=`ls -1 rtools44-*.exe | grep aarch64 | head -1`
if [ "X$RTEXEA" == X ] ; then
  echo "New Rtools44-aarch64 installer not ready." >&2
  exit 1
fi

if [ -r $TGT/files/$RTEXE ] && [ -r $TGT/files/$RTEXEA ] ; then
  echo "Already have the latest version." >&2
  exit 0
fi

RTVER=`echo $RTEXE | cut -d- -f2,3 | sed -e 's/\.exe//g'`
TLVER=`echo $RTEXE | cut -d- -f2`

TBASE=gcc13_ucrt3_base_$TLVER.tar.zst
TFULL=gcc13_ucrt3_full_$TLVER.tar.zst
TCROSS=gcc13_ucrt3_cross_$TLVER.tar.zst

RTVERA=`echo $RTEXEA | cut -d- -f3,4 | sed -e 's/\.exe//g'`
TLVERA=`echo $RTEXEA | cut -d- -f3`

TBASEA=llvm17_ucrt3_base_aarch64_$TLVERA.tar.zst
TFULLA=llvm17_ucrt3_full_aarch64_$TLVERA.tar.zst
TCROSSA=llvm17_ucrt3_cross_aarch64_$TLVERA.tar.zst

TCLB=`ls -1 Tcl-$TLVER-*.zip | head -1`

if [ "X$TCLB" == X ] ; then
  echo "Tcl bundle not ready." >&2
  exit 1
fi

TCLBA=`ls -1 Tcl-aarch64-$TLVERA-*.zip | head -1`

if [ "X$TCLBA" == X ] ; then
  echo "Tcl-aarch64 bundle not ready." >&2
  exit 1
fi

rm -rf $TMPTGT
mkdir -p $TMPTGT

for F in $RTEXE $TBASE $TFULL $TCROSS $TCLB \
         $RTEXEA $TBASEA $TFULLA $TCROSSA $TCLBA ; do
  if [ ! -r $F ] ; then
    echo "File $F is missing." >&2
    exit 1
  fi
  cp -p $F $TMPTGT
done

for F in $RTEXE $TBASE $TFULL $TCROSS $TCLB \
         $RTEXEA $TBASEA $TFULLA $TCROSSA $TCLBA ; do
  if ! cmp $F $TMPTGT/$F ; then
    echo "Files changed while copying." >&2
    exit 2
  fi
done

# rename as needed

cd $TMPTGT
mkdir files

NRTEXE=`echo $RTEXE | sed -e 's/\.exe/-unsigned.exe/g'`
NTBASE=rtools44-toolchain-libs-base-$TLVER.tar.zst
NTFULL=rtools44-toolchain-libs-full-$TLVER.tar.zst
NTCROSS=rtools44-toolchain-libs-cross-$TLVER.tar.zst
NTCLB=`echo $TCLB | sed -e 's/Tcl-/tcltk-/g'`

NRTEXEA=`echo $RTEXEA | sed -e 's/\.exe/-unsigned.exe/g'`
NTBASEA=rtools44-toolchain-libs-base-aarch64-$TLVERA.tar.zst
NTFULLA=rtools44-toolchain-libs-full-aarch64-$TLVERA.tar.zst
NTCROSSA=rtools44-toolchain-libs-cross-aarch64-$TLVERA.tar.zst
NTCLBA=`echo $TCLBA | sed -e 's/Tcl-/tcltk-/g'`

mv $RTEXE files/$NRTEXE
mv $TBASE files/$NTBASE
mv $TFULL files/$NTFULL
mv $TCROSS files/$NTCROSS
mv $TCLB files/$NTCLB

mv $RTEXEA files/$NRTEXEA
mv $TBASEA files/$NTBASEA
mv $TFULLA files/$NTFULLA
mv $TCROSSA files/$NTCROSSA
mv $TCLBA files/$NTCLBA

# generate index file

svn cat https://svn.r-project.org/R-dev-web/trunk/WindowsBuilds/Rtools44/rtools.md | \
  sed -e 's/RTVER/'$RTVER'/g' | \
  sed -e 's/TLVER/'$TLVER'/g' | \
  pandoc -s -c "https://cran.r-project.org/R.css" > rtools.html
  
if [ $? -ne 0 ] || [ ! -r rtools.html ] ; then
  echo "Failed to generate index." >&2
  exit 1
fi

# generate news file

svn cat https://svn.r-project.org/R-dev-web/trunk/WindowsBuilds/Rtools44/news.md | \
  pandoc -s -c "https://cran.r-project.org/R.css" > news.html
  
if [ $? -ne 0 ] || [ ! -r news.html ] ; then
  echo "Failed to generate index." >&2
  exit 1
fi

rm -rf $TGT.old
if [ -d $TGT ] ; then
  mv $TGT $TGT.old
fi
mv $TMPTGT $TGT
