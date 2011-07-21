call d:\RCompile\CRANpkg\make\set_Env_new.bat 
call d:\RCompile\CRANpkg\make\set_recent_Env.bat 

d:
cd d:\RCompile\CRANguest\make
mkdir d:\RCompile\CRANguest\R-release
xcopy c:\Inetpub\ftproot\R-release\*.tar.gz d:\RCompile\CRANguest\R-release\ /Y
rm c:/Inetpub/ftproot/R-release/*
R CMD BATCH --no-restore --no-save Auto-Pakete.R Auto-Pakete-R-release.Rout

exit
