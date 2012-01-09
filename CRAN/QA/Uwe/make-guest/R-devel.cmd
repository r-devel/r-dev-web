call d:\RCompile\CRANpkg\make\set_Env_215.bat 
call d:\RCompile\CRANpkg\make\set_devel64_Env.bat 
set R_LIBS=d:/Rcompile/CRANguest/R-devel/lib;%R_LIBS%


d:
cd d:\RCompile\CRANguest\make
mkdir d:\RCompile\CRANguest\R-devel
xcopy c:\Inetpub\ftproot\R-devel\*.tar.gz d:\RCompile\CRANguest\R-devel\ /Y
rm c:/Inetpub/ftproot/R-devel/*
R CMD BATCH --no-restore --no-save Auto-Pakete.R Auto-Pakete-R-devel.Rout

exit
