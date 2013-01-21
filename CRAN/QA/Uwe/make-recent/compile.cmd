set targetname=R
set name=R32
set version=3.0
set state=devel

set Path=.;d:\compiler\bin;d:\Compiler\gcc-4.6.3\bin;%SystemRoot%\system32;%SystemRoot%;%SystemRoot%\System32\Wbem;D:\compiler\texmf\miktex\bin;d:\compiler\perl-basic\bin
rem set R_INSTALL_TAR=tar.exe
set CYGWIN=nodosfilewarning
set TAR_OPTIONS=--no-same-owner --no-same-permissions

set R_LIBS=
set LANGUAGE=en

d:
cd \Rcompile\recent

svn.exe update R-%state%

xxcopy R-%state% %name% /Q1 /Q2 /Q3 /CLONE /YY | grep -v "Deleted"

copy /Y d:\RCompile\r-compiling\MkRules.dist-%version% d:\RCompile\recent\%name%\src\gnuwin32\MkRules.local

xxcopy d:\RCompile\r-compiling\bitmap d:\Rcompile\recent\%name%\src\gnuwin32\bitmap  /Q1 /Q2 /Q3 /BU
xxcopy d:\RCompile\r-compiling\tcl85 .\%name%\tcl  /Q1 /Q2 /Q3 /BU


rem ######## make it!
set Path=%PATH%;d:\Rcompile\recent\%name%\bin
cd %name%\src\gnuwin32
make -j8 all
make bitmapdll
make cairodevices

rem ### recommended packages ...
make rsync-recommended
make -j8 recommended
rem make vignettes
rem make manuals

rem ## fix permissions
cd \Rcompile\recent
cacls %name% /T /E /G VORDEFINIERT\Benutzer:R > NUL

mkdir c:\Inetpub\wwwroot\Rdevelcompile

rem ### 32 bit checks
rem cd \Rcompile\recent\%name%\src\gnuwin32
rem make check-all > check0-32.log 2>&1 
rem diff ..\..\..\check0-32.log check0a.log > check0-32dif.log
rem copy /y check0-32.log c:\Inetpub\wwwroot\Rdevelcompile\
rem copy /y check0-32dif.log c:\Inetpub\wwwroot\Rdevelcompile\

rem ########################
rem # finished 32-bit
rem ########################

set name=R64
set Path=.;d:\compiler\bin;d:\compiler\gcc-4.6.3\bin;%SystemRoot%\system32;%SystemRoot%;%SystemRoot%\System32\Wbem;D:\compiler\texmf\miktex\bin;d:\compiler\perl-basic\bin

d:
cd \Rcompile\recent

xxcopy R-%state% %name%  /Q1 /Q2 /Q3 /CLONE /YY | grep -v "Deleted"

copy /Y d:\RCompile\r-compiling\MkRules.dist64-%version% d:\RCompile\recent\%name%\src\gnuwin32\MkRules.local
xxcopy d:\RCompile\r-compiling\bitmap d:\Rcompile\recent\%name%\src\gnuwin32\bitmap  /Q1 /Q2 /Q3 /BU
xxcopy d:\RCompile\r-compiling\Tcl85_64 .\%name%\tcl  /Q1 /Q2 /Q3 /BU

rem ######## make it!
set Path=%PATH%;d:\Rcompile\recent\%name%\bin
cd %name%\src\gnuwin32
make -j8 all
make bitmapdll
make cairodevices

rem ### recommended packages ...
make rsync-recommended
make -j8 recommended
make vignettes
make manuals

cd installer
make imagedir
make fixups
make 32bit
rm -rf d:/RCompile/recent/%targetname%
rem mv R-%version%.0dev d:/RCompile/recent/%targetname%
mv R-devel d:/RCompile/recent/%targetname%

cd ..
make rinstaller
make crandir

copy /Y d:\RCompile\r-compiling\Makevars.site32 d:\RCompile\recent\%targetname%\etc\i386\Makevars.site
copy /Y d:\RCompile\r-compiling\Renviron.site32 d:\RCompile\recent\%targetname%\etc\i386\Renviron.site

copy /Y d:\RCompile\r-compiling\Makevars.site64 d:\RCompile\recent\%targetname%\etc\x64\Makevars.site
copy /Y d:\RCompile\r-compiling\Renviron.site64 d:\RCompile\recent\%targetname%\etc\x64\Renviron.site


rem ## fix permissions of library and update library
cd d:\Rcompile\CRANpkg\lib\%version%
FOR %%a IN (KernSmooth base cluster grDevices lattice nlme spatial stats4 tools MASS boot datasets graphics methods nnet splines survival utils class foreign grid mgcv rpart stats tcltk codetools compiler Matrix parallel) DO SubInACL /subdirectories %%a\*.* /setowner=fb05\ligges /grant=fb05\ligges=F > NUL
FOR %%a IN (KernSmooth base cluster grDevices lattice nlme spatial stats4 tools MASS boot datasets graphics methods nnet splines survival utils class foreign grid mgcv rpart stats tcltk codetools compiler Matrix parallel) DO rm -r -f %%a
rem ### manuell:
rem FOR %a IN (KernSmooth base cluster grDevices lattice nlme spatial stats4 tools MASS boot datasets graphics methods nnet splines survival utils class foreign grid mgcv rpart stats tcltk codetools compiler Matrix parallel) DO SubInACL /subdirectories %a\*.* /setowner=fb05\ligges /grant=fb05\ligges=F > NUL
rem FOR %a IN (KernSmooth base cluster grDevices lattice nlme spatial stats4 tools MASS boot datasets graphics methods nnet splines survival utils class foreign grid mgcv rpart stats tcltk codetools compiler Matrix parallel) DO rm -r -f %a
copy /y d:\Rcompile\recent\%name%\VERSION d:\RCompile\CRANpkg\check\%version%
xxcopy d:\Rcompile\recent\%targetname%\library d:\RCompile\CRANpkg\lib\%version%  /Q1 /Q2 /Q3 /BU
rem ## fix permissions of R
cd \Rcompile\recent
cacls %targetname% /T /E /G VORDEFINIERT\Benutzer:R > NUL

cd \Rcompile\recent\%name%\src\gnuwin32
make check-all > check0.log 2>&1 
diff ..\..\..\check0.log check0.log > check0dif.log
copy /y check0.log c:\Inetpub\wwwroot\Rdevelcompile\
copy /y check0dif.log c:\Inetpub\wwwroot\Rdevelcompile\
copy /y d:\RCompile\recent\compile0.log c:\Inetpub\wwwroot\Rdevelcompile\
blat d:\Rcompile\recent\blat.txt -to ligges@statistik.tu-dortmund.de -subject "R-devel"


rem ########################
rem # finished!
rem ########################
