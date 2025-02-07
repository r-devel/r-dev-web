#! /bin/bash
set -x

export develstate=devel
export version=4.5
export Rtools=44

export PATH="/d/rtools$Rtools/x86_64-w64-mingw32.static.posix/bin:/d/rtools$Rtools/usr/bin:${PATH}"
export targetname_old=R_old
export targetname_prep=R_prep_$develstate
export targetname=R
export name=R-$develstate


if [ ! -f "/d/RCompile/lock/R-$develstate.ready" ]; then
    echo "No R-$develstate ready to move."
    exit 1
fi

PATTERN="/d/RCompile/lock/R-devel*.lock /d/RCompile/lock/${version}.lock"
if ls $PATTERN 1> /dev/null 2>&1; then
    echo "Lock files present: exit"
    exit 1
fi




rm /d/RCompile/lock/R-$develstate.ready
touch /d/RCompile/lock/R-devel.lock

rm -rf /d/RCompile/recent/$targetname_old
mv /d/RCompile/recent/$targetname /d/RCompile/recent/$targetname_old
mv /d/RCompile/recent/$targetname_prep /d/RCompile/recent/$targetname

# fix permissions of library and update library
mkdir /d/Rcompile/CRANpkg/lib/$version
cd /d/Rcompile/CRANpkg/lib/$version
cmd //c "FOR %a IN (KernSmooth base cluster grDevices lattice nlme spatial stats4 tools MASS boot datasets graphics methods nnet splines survival utils class foreign grid mgcv rpart stats tcltk codetools compiler Matrix parallel) DO SubInACL /subdirectories %a\*.* /setowner=fb05\ligges /grant=fb05\ligges=F > NUL"
for F in KernSmooth base cluster grDevices lattice nlme spatial stats4 tools MASS boot datasets graphics methods nnet splines survival utils class foreign grid mgcv rpart stats tcltk codetools compiler Matrix parallel ; do
  rm -rf $F
done

mkdir /d/RCompile/CRANpkg/check/$version
cp /d/RCompile/recent/$name/VERSION /d/RCompile/CRANpkg/check/$version
cmd //c "robocopy d:\Rcompile\recent\%targetname%\library d:\RCompile\CRANpkg\lib\%version% /E /NC /NS /NFL /NDL /NP /NJS /R:1 /W:1 > NUL"
cmd //c "FOR %a IN (KernSmooth base cluster grDevices lattice nlme spatial stats4 tools MASS boot datasets graphics methods nnet splines survival utils class foreign grid mgcv rpart stats tcltk codetools compiler Matrix parallel) DO SubInACL /subdirectories %a\*.* /grant=CRANwin3\CRAN=F > NUL"

rm /d/RCompile/lock/R-devel.lock
blat /d/RCompile/recent/blat.txt -to ligges@statistik.tu-dortmund.de -subject "R-devel moved"
