### TO DO: change name R-devel of the installer to what it is actually called.
## log files to separate dir
## test !!!!!


#! /bin/bash
set -x

MISDIR="C:/Program Files (x86)/Inno Setup 6"
MIKDIR="/c/Program Files/MiKTeX/miktex/bin/x64"

export Rtools=44
export PATH="/d/rtools$Rtools/x86_64-w64-mingw32.static.posix/bin:/d/rtools$Rtools/usr/bin:${MIKDIR}:${PATH}"
export TAR="/usr/bin/tar"
export TAR_OPTIONS="--force-local --no-same-owner --no-same-permissions"
export LC_CTYPE=
export R_LIBS=
export LANGUAGE=en

export state=patched
export targetname_prep=R_prep_$state
export name=R-$state


#export CYGWIN=nodosfilewarning
#export MSYS=winsymlinks:lnk


cd /d/RCompile/recent
mkdir log
mkdir log/$state
# svn checkout https://svn.r-project.org/R/branches/R-4-4-branch Rsvn-$state
svn up Rsvn-$state

cmd //c "robocopy Rsvn-$state %name% /MIR /NC /NS /NFL /NDL /NP /NJS /R:1 /W:1 > NUL"

export fullname="$(sed 's/\(.*\) \(.*\)/R-\L\1\L\2/' $name/VERSION)"

# apply patches to R
cd $name
unzip ../Tcl.zip

# patches from Tomas no longer needed:
# for F in ../patches/r_*.diff ; do
#   patch --binary -p0 < $F
# done

# for reference
svn info --show-item revision > ../log/svn_revision

# get certificates
# Not needed as we use Schannel - https://curl.se/docs/sslcerts.html
cd etc
wget https://curl.se/ca/cacert.pem
mv cacert.pem curl-ca-bundle.crt
cd ..

cd src/gnuwin32
cat <<EOF >MkRules.local
ISDIR = ${MISDIR}
EOF


make rsync-recommended
make -j 10 all 2>&1 | tee make_all.out
make cairodevices 2>&1 | tee make_cairodevices.out

make -j 10 recommended 2>&1 | tee make_recommended.out
make -j 10 vignettes 2>&1 | tee make_vignettes.out
make -j 10 manuals 2>&1 | tee make_manuals.out

cd installer
make imagedir 2>&1 | tee make_imagedir.out
make fixups 2>&1 | tee make_fixups.out

rm -rf /d/RCompile/recent/$targetname_prep
mv $fullname /d/RCompile/recent/$targetname_prep

sed -i -r "s/^CFLAGS *= */CFLAGS = -pedantic -Wstrict-prototypes /" /d/RCompile/recent/$targetname_prep/etc/x64/Makeconf
sed -i -r "s/^CXXFLAGS *= */CXXFLAGS = -pedantic /" /d/RCompile/recent/$targetname_prep/etc/x64/Makeconf
sed -i -r "s/^CXX1XFLAGS *= */CXX1XFLAGS = -pedantic /" /d/RCompile/recent/$targetname_prep/etc/x64/Makeconf
sed -i -r "s/^FFLAGS *= */FFLAGS = -pedantic /" /d/RCompile/recent/$targetname_prep/etc/x64/Makeconf
sed -i -r "s/^FCFLAGS *= */FCFLAGS = -pedantic /" /d/RCompile/recent/$targetname_prep/etc/x64/Makeconf

cd ..
make rinstaller 2>&1 | tee make_rinstaller.out

# make crandir
svn up /d/RCompile/recent/WindowsBuilds
cp -r /d/RCompile/recent/WindowsBuilds/crandir cran/
cd cran
make 2>&1 | tee ../make_crandir.out

# copy files to the CRAN rsync entry point
cp r$state.html NEWS.$fullname.html md5sum.$fullname.txt README.$fullname rw-FAQ.$fullname.html SVN-REVISION.$fullname $fullname-win.exe //store/ligges/public_html/CRAN/bin/windows/base
cd ..


mkdir //CRANwin2/inetpub/wwwroot/Rdevelcompile
mkdir //CRANwin2/inetpub/wwwroot/Rdevelcompile/$state
cp *.out //CRANwin2/inetpub/wwwroot/Rdevelcompile/$state
cp *.out ../../../log/$state


cd /d/RCompile/recent

# fix permissions of R
cmd //c "cacls %targetname_prep% /T /E /G VORDEFINIERT\Benutzer:R > NUL"

touch /d/RCompile/lock/R-$state.ready
blat /d/RCompile/recent/blat.txt -to ligges@statistik.tu-dortmund.de -subject "R-$state ready!"

cd /d/RCompile/recent/$name/src/gnuwin32

set _R_CHECK_ALL_NON_ISO_C_=TRUE
set _R_CHECK_CODE_ASSIGN_TO_GLOBALENV_=TRUE
set _R_CHECK_CODE_ATTACH_=TRUE
set _R_CHECK_CODE_DATA_INTO_GLOBALENV_=TRUE
set _R_CHECK_CODETOOLS_PROFILE_=suppressPartialMatchArgs=false
set _R_CHECK_DOC_SIZES2_=TRUE
set _R_CHECK_DOT_INTERNAL_=TRUE
set _R_CHECK_INSTALL_DEPENDS_=TRUE
set _R_CHECK_LICENSE_=TRUE
set _R_CHECK_NO_RECOMMENDED_=TRUE
set _R_CHECK_RD_EXAMPLES_T_AND_F_=TRUE
set _R_CHECK_SRC_MINUS_W_IMPLICIT_=TRUE
set _R_CHECK_SUBDIRS_NOCASE_=TRUE
set _R_CHECK_SUGGESTS_ONLY_=TRUE
set _R_CHECK_UNSAFE_CALLS_=TRUE
set _R_CHECK_WALL_FORTRAN_=TRUE
set _R_CHECK_RD_LINE_WIDTHS_=TRUE
set _R_CHECK_REPLACING_IMPORTS_=TRUE
set _R_CHECK_TOPLEVEL_FILES_=TRUE
set _R_CHECK_FF_DUP_=TRUE
set _R_SHLIB_BUILD_OBJECTS_SYMBOL_TABLES_=TRUE
set _R_CHECK_CODE_USAGE_WITHOUT_LOADING_=TRUE
set _R_CHECK_S3_METHODS_NOT_REGISTERED_=TRUE


# make check-devel 2>&1 | tee checkdevel.out
# cp checkdevel.out ../../../log
make check-all 2>&1 | tee checkall.out
cp checkall.out ../../../log/$state

# COMSPEC= for texi2dvi is a work-around for a bug in texi2dvi in Msys2,
# which uses COMSPEC to detect path separator and does that incorrectly
# when running from the Msys2 terminal

cd ../../../log/$state
diff checkall.out checkall_0.out > check0dif.out

cp *.out //CRANwin2/inetpub/wwwroot/Rdevelcompile/$state
blat /d/RCompile/recent/blat.txt -to ligges@statistik.tu-dortmund.de -subject "R-$state checked"
