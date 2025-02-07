# action nach Plummer:

set -x
export Rtools=44

export PATH="/d/rtools$Rtools/x86_64-w64-mingw32.static.posix/bin:/d/rtools$Rtools/usr/bin:${PATH}"
export LANGUAGE=en
export LC_TIME="en_US.UTF-8"

export datum="$(date +"%B, %Y")"
export state=release
export targetname_prep=R_prep_$state

cd /d/RCompile/recent
export name=R-$state
export version="$(sed 's/ .*//' $name/VERSION)"
export fullname=R-$version  

cd /d/RCompile/recent/R-release/src/gnuwin32/cran

## needs passwort entry!!!
scp root@bioconductor:/home/plummer/signed/$fullname-win.exe ../installer/

make 2>&1 | tee ../make_crandir.out
cp release.html index.html NEWS.$fullname.html md5sum.$fullname.txt README.$fullname rw-FAQ.$fullname.html SVN-REVISION.$fullname $fullname-win.exe //store/ligges/public_html/CRAN/bin/windows/base
mkdir //store/ligges/public_html/CRAN/bin/windows/base/old/$version
cp NEWS.$fullname.html md5sum.$fullname.txt README.$fullname rw-FAQ.$fullname.html SVN-REVISION.$fullname $fullname-win.exe //store/ligges/public_html/CRAN/bin/windows/base/old/$version
cp //store/ligges/public_html/CRAN/bin/windows/base/R.css //store/ligges/public_html/CRAN/bin/windows/base/old/$version
## Link in old/index.html einfügen:
sed -i -r "s_<\!--auto-insert-comment-->_<\!--auto-insert-comment-->\n<a href=\"$version\">R $version</a> ($datum)<br>_" //store/ligges/public_html/CRAN/bin/windows/base/old/index.html

## create appropriate links
## needs passwort entry!!!
ssh ligges@shell.statistik.tu-dortmund.de bash << EOF
export version=$version
cd ~/public_html/CRAN/bin/windows/base
rm R-release.exe R-patched.exe rw-FAQ.html
ln -s R-$version-win.exe R-release.exe
ln -s R-${version}patched-win.exe R-patched.exe
ln -s rw-FAQ.R-$version.html rw-FAQ.html
ls -lta
EOF
