call d:\RCompile\CRANpkg\make\set_Env_new.bat 
call d:\RCompile\CRANpkg\make\set_devel_Env.bat 

d:
cd d:\RCompile\CRANguest\make
mkdir d:\RCompile\CRANguest\R-devel
xcopy c:\Inetpub\ftproot\R-devel\*.tar.gz d:\RCompile\CRANguest\R-devel\ /Y
rm c:/Inetpub/ftproot/R-devel/*
R CMD BATCH --no-restore --no-save Auto-Pakete.R Auto-Pakete-R-devel.Rout

exit
